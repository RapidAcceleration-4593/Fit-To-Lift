from PySide6.QtCore import QObject, Slot
import asyncio
import serialmanager
import personaldata
import testmanager
from printing import PersonPrinter
from asynchelper import create_task

class Services(QObject):
    """ An interface to QML which exposes Fit to Lift's functionality.

        All its methods with the @Slot() annotation are in camelCase, in order to match QML's style.
    """
    def __init__(self, serial_manager: serialmanager.SerialManager, test_manager: testmanager.TestManager, printer: PersonPrinter):
        QObject.__init__(self)
        self.measuring = False
        self.serial_manager = serial_manager
        self.test_manager = test_manager
        self.printer = printer
        self.subject = personaldata.Person()

    # Device functionality

    @Slot()
    def bumpArmUp(self):
        create_task(self.serial_manager.command("u"))
    
    @Slot()
    def bumpArmDown(self):
       create_task(self.serial_manager.command("d"))
    
    @Slot()
    def goToTestingHeight(self):
        height = self.subject.get_height()
        setpoint_inches = self.test_manager.get_current_test()["setpoint-calculator"](height) # Don't ask
        self.set_arm_setpoint(setpoint_inches)

    def set_arm_setpoint(self, setpoint):
        create_task(self.serial_manager.command("sp " + str(setpoint)))

    @Slot(int)
    def beginMeasuring(self, timeout):
        self.measuring = True

        # Get lift name now in case it changes before measuring is over.
        current_lift = self.test_manager.get_current_test()["name"]

        create_task(
            self.run_measurement(timeout),
            callback = lambda future : self.subject.add_measurement(current_lift, future.result())
        )

    @Slot()
    def finishMeasuring(self):
        self.measuring = False

    async def run_measurement(self, timeout: float) -> float:
        measurer = create_task(self.measure_lift())

        done, pending = await asyncio.wait([measurer], timeout=timeout)      
        if measurer in pending:
            self.finishMeasuring()
        return await measurer

    async def measure_lift(self) -> float:
        measurements = 0
        sum = 0
        while self.measuring:
            try:
                result = float(await self.serial_manager.query("r", read_timeout = 4))
                sum += result
                measurements += 1
            except TimeoutError:
                break
        if not measurements: return 0
        return sum / measurements

    def measure_lift_handler(self, future: asyncio.Future):
        # TODO: Write results to data manager
        print(future.result())

    @Slot()
    def emergencyStop(self):
        create_task(self.serial_manager.command("e"))
    
    # Test Management

    @Slot()
    def nextTest(self):
        self.test_manager.next_test()

    @Slot(result = str)
    def getCurrentTestName(self):
        return self.test_manager.get_current_test()["name"]
    
    @Slot(result = str)
    def getCurrentTestInstructions(self):
        return self.test_manager.get_current_test()["instructions"]

    @Slot(result = int)
    def getCurrentRepetition(self):
        return self.test_manager.get_current_repetition()
    
    @Slot(result = bool)
    def isTestingComplete(self):
        return self.test_manager.is_testing_complete()
    
    # Data Management

    @Slot(str)
    def setSubjectName(self, name):
        self.subject.set_name(name)

    @Slot(int)
    def setSubjectHeight(self, height):
        self.subject.set_height(height)

    @Slot()
    def exportSubject(self):
        """Exports the subject data, then deletes all data."""
        create_task(self.export_subject_async())

    async def export_subject_async(self):
        """Waits for the device to stop measuring, then exports data."""
        while self.measuring:
            await asyncio.sleep(0.01)
        await asyncio.sleep(0.1) # Magic wait to ensure all data is written to self.subject

        self.printer.print(self.subject)
        self.subject = personaldata.Person()
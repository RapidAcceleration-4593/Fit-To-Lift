from PySide6.QtCore import QObject, Slot
import serial
import atexit
import signal
import sys
import platform

def getSerialPortName():
    if platform.system() == "Windows":
        return "COM4"
    elif platform.system() == "Linux":
        return "/dev/tty/USB0"
    elif platform.system() == "Darwin": # Mac
        return "no/effing/clue"

ser = serial.Serial(getSerialPortName(), 115200)

# Handle closing the serial port, even if the program is killed
def exit_handler():
    ser.close()

def kill_handler(*args):
    sys.exit(0)

atexit.register(exit_handler)
signal.signal(signal.SIGINT, kill_handler)
signal.signal(signal.SIGTERM, kill_handler)

ser.open()

class Arduino(QObject):

    def __init__(self):
        QObject.__init__(self)

    @Slot()
    def bumpUp(self):
       print("Bumped Up!")
    
    @Slot()
    def bumpDown(self):
       print("Bumped Down!")
    
    @Slot(int)
    def goToSetpoint(self, setpoint):
        pass # Probably add some async stuff that confirms that the bar has reached the setpoint

    @Slot()
    def readLoadCell(self):
        pass # Definitely some async magic that I have no clue how to implement

    @Slot()
    def getStatus(self):
        pass # More fun async stuff where we await the Arduino returning its status, timing out and returning an error if it doesn't respond

    @Slot()
    def emergencyStop(self):
        pass # Easy to implement, not that I'm going to right now
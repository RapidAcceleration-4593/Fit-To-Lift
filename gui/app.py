import sys, os

from PySide6.QtWidgets import QApplication 
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl
from PySide6.QtPrintSupport import QPrinter, QPrinterInfo
import PySide6.QtAsyncio as QtAsyncio

import service
import serialmanager
import testmanager
import printing
from personaldata import Person

MOCK_SERIAL = False
NUM_REPETITIONS = 1

def main():
    os.environ["QT_QUICK_CONTROLS_CONF"] = os.path.join(os.path.dirname(__file__), "themes/qtquickcontrols2.conf")

    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    serial_connection = serialmanager.create_serial_connection(mock = MOCK_SERIAL)
    serial_manager = serialmanager.SerialManager(serial_connection)
    test_manager = testmanager.TestManager(reps_per_test = NUM_REPETITIONS)
    person_printer = printing.PersonPrinter()

    services = service.Services(serial_manager, test_manager, person_printer)

    engine.rootContext().setContextProperty("services", services)
    engine.load(QUrl.fromLocalFile("main.qml"))

    if not engine.rootObjects():
        serial_connection.close()
        sys.exit(-1)
    
    try:
        QtAsyncio.run(handle_sigint = True)
    finally:
        serial_connection.close()

if __name__ == '__main__':
    main()
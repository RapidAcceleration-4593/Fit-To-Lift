import sys
import os

from PySide6.QtWidgets import QApplication 
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl
from PySide6.QtPrintSupport import QPrinter, QPrinterInfo
import PySide6.QtAsyncio as QtAsyncio

import service
import serial
import testmanager
import serialmanager
import printing


if __name__ == '__main__':
    config_path = os.path.join(os.path.dirname(__file__), "qtquickcontrols2.conf")
    os.environ["QT_QUICK_CONTROLS_CONF"] = config_path

    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    serial_connection = serial.Serial(serialmanager.default_port_name(), 115200)
    serial_manager = serialmanager.SerialManager(serial_connection)
    test_manager = testmanager.TestManager(reps_per_test=1)

    printer = QPrinter(QPrinterInfo.defaultPrinter())
    person_printer = printing.WidePagePrinter(printer)

    services = service.Services(serial_manager, test_manager, person_printer)

    engine.rootContext().setContextProperty("services", services)
    engine.load(QUrl.fromLocalFile("main.qml"))

    if not engine.rootObjects():
        serial_connection.close()
        sys.exit(-1)
    QtAsyncio.run(handle_sigint=True)
    serial_connection.close()

    # Alternative Qt-only loop
    # sys.exit(app.exec())
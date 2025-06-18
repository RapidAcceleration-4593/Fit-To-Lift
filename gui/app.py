import sys
import os
from PySide6.QtWidgets import QApplication 
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType
from PySide6.QtCore import QUrl
import PySide6.QtAsyncio as QtAsyncio
import service

if __name__ == '__main__':
    config_path = os.path.join(os.path.dirname(__file__), "qtquickcontrols2.conf")
    os.environ["QT_QUICK_CONTROLS_CONF"] = config_path
    app = QApplication(sys.argv)
    engine = QQmlApplicationEngine()

    services = service.Services()
    engine.rootContext().setContextProperty("services", services)
    
    engine.load(QUrl.fromLocalFile("main.qml"))
    
    if not engine.rootObjects():
        sys.exit(-1)
    QtAsyncio.run(handle_sigint=True)
from PySide6.QtPrintSupport import QPrinter, QPrinterInfo
from PySide6.QtGui import QTextDocument, QFont
import datetime

from personaldata import Person

def timestamp() -> str:
    time = datetime.datetime.now()

    appendix = "a.m."
    if time.hour > 11:
        appendix = "p.m."
    
    hour = time.hour % 12
    minutes = str(time.minute).rjust(2, "0")
    month = time.month
    day = time.day
    year = time.year

    return f"{month}/{day}/{year} {hour}:{minutes} {appendix}"


class PersonPrinter:
    def __init__(self, printer: QPrinter):
        self.supports_html = False
        self.printer = printer

    def get_printer(self) -> QPrinter:
        return self.printer
    
    def set_printer(self, printer):
        self.printer = printer

    def create_template(self) -> QTextDocument: # type: ignore
        pass

    def format(self, person: Person) -> str: # type: ignore
        pass

    def print(self, person: Person):
        doc = self.create_template()
        if self.supports_html:
            doc.setHtml(self.format(person))
        else:
            doc.setPlainText(self.format(person))
        # doc.print_(self.printer)


class WidePagePrinter(PersonPrinter):
    def create_template(self) -> QTextDocument:
        template = QTextDocument()

        font = QFont()
        font.setFamily("Courier New")
        font.setPointSize(12)

        template.setDefaultFont(font)
        return template

    def format(self, person: Person) -> str:
        bar = "-------------------------------------------------\n"

        text = "\n--------- Fit to Lift Measurement Data ----------\n"
        text += "Name: " + person.name + "\n"

        text += "Lift                                   Mean   Max\n"

        text += bar
        for lift in person.measurements.keys():
            data = person.measurements[lift]
            text += lift.ljust(38) + str(int(sum(data) / len(data))).rjust(5, " ")
            text += str(int(max(data))).rjust(6) + "\n"
        text += "\nFit to Lift developed by Bob McIntosh and team\n"
        text += "4593 Rapid Acceleration\n"
        text += "Programming by Matthew Flanegan and Tyler Mueller\n"
        text += "Printed " + timestamp() + "\n"

        return text
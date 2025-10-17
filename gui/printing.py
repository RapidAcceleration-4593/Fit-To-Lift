import datetime
from personaldata import Person
from PySide6.QtPrintSupport import QPrinter
from PySide6.QtGui import QTextDocument

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

class Printer:
    def __init__(self, qprinter: QPrinter, template_path):
        with open(template_path) as f:
            self.template = f.read()
            self.working_copy = self.template
        self.printer = qprinter
    
    def clear_working_copy(self):
        self.working_copy = self.template
    
    def print(self, dict: dict, printpath = "printed.txt"):
        self.clear_working_copy()
        for key in dict:
            if isinstance(dict[key], list):
                self.populate_list(key, dict[key])
            else:
                self.populate_item(key, dict[key])

        doc = QTextDocument()        
        doc.setPlainText(self.working_copy)
        self.clear_working_copy()
        doc.print_(self.printer)

    def populate_item(self, name: str, value):
        if name.startswith("@"):
            code = "{"+name+"}"
        else:
            code = "{$"+name+"}"

        self.working_copy = self.working_copy.replace(code, str(value))
                
    def populate_list(self, name, values):
        for i in range(0, len(values)):
            self.populate_item("@"+name+str(i), values[i])

class PersonPrinter:
    def __init__(self, qprinter):
        self.printer = Printer(qprinter, "printing/templates/Label.prn")
    
    def print_person(self, person: Person):
        lifts = []
        avgs = []
        maxes = []

        for lift, measurements in person.measurements.items():
            lifts.append(lift)

            mean = sum(measurements) / len(measurements)
            avgs.append(mean)

            maxes.append(max(measurements))
        
        parameters = {
            "Name" : lifts,
            "Avg" : avgs,
            "Max" : maxes
        }

        self.printer.print(parameters)
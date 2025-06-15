import datetime

class Person:
    def __init__(self):
        self.name = ""
        self.height_inches = 0
        self.measurements: dict[str, list[int]] = {}

    def printout(self) -> str:
        bar = "-------------------------------------------------\n"

        text = "\n--------- Fit to Lift Measurement Data ----------\n\n"
        text += "Name: " + self.name + "\n\n"
        text += "Lift                                   Mean   Max  \n"
        text += bar
        for lift in self.measurements.keys():
            data = self.measurements[lift]
            text += lift.ljust(38) + str(int(sum(data) / len(data))).rjust(5, " ")
            text += str(int(max(data))).rjust(6) + "\n"
        text += "\nFit to Lift developed by Bob McIntosh and team\n"
        text += "4593 Rapid Acceleration\n"
        text += "Programming by Matthew Flanegan and Tyler Mueller\n\n"
        text += "Printed " + self.timestamp() + "\n"
        return text
    
    def timestamp(self) -> str:
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

    def set_name(self, name):
        self.name = name
    
    def get_name(self):
        return self.name
    
    def set_height(self, height_inches):
        self.height_inches = height_inches
    
    def get_height(self):
        return self.height_inches
    
    def addMeasurement(self, lift_name, value):
        if lift_name in self.measurements.keys():
            self.measurements[lift_name].append(value)
        else:
            self.measurements[lift_name] = [value]
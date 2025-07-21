class Person:
    def __init__(self):
        self.name = ""
        self.height_inches = 0
        self.measurements: dict[str, list[int]] = {}

    def set_name(self, name):
        self.name = name
    
    def get_name(self):
        return self.name
    
    def set_height(self, height_inches):
        self.height_inches = height_inches
    
    def get_height(self):
        return self.height_inches
    
    def add_measurement(self, lift_name, value):
        if lift_name in self.measurements.keys():
            self.measurements[lift_name].append(value)
        else:
            self.measurements[lift_name] = [value]
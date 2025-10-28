import datetime
from personaldata import Person
import subprocess
import platform

class PrinterParsingException(Exception):
    pass

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
    def __init__(self, template_path):
        self.template_path = template_path
        with open(template_path) as f:
            self.template = f.read()
    
    def print(self, dict: dict):
        printstring = self.generate_print_string(dict)
        
        f = open("printed.prn", "w")
        f.writelines(printstring)
        f.close()

        if platform.system() == "Windows":
            subprocess.Popen(["powershell", 'Get-Content "printed.prn" -ReadCount 0 | Out-Printer -Name "Generic / Text Only"'], shell=True)
        else:
            subprocess.Popen("lp printed.prn",shell=True)
    
    def populate_item(self, target, name: str, value):
        if name.startswith("@"):
            code = "{"+name+"}"
        else:
            code = "{$"+name+"}"

        return target.replace(code, str(value))
                
    def populate_list(self, target, name, values):
        w_target = target
        for i in range(0, len(values)):
            w_target = self.populate_item(w_target, "@"+name+str(i), values[i])
        return w_target
    
    def create_parse_error(self, error_msg):
        return PrinterParsingException(f"Problem in template file '{self.template_path}'\n\tParsing Error: {error_msg}")

    def generate_print_string(self, params: dict):
        var_symbols = []
        # A list containing lists that describe a variable. The list contains:
        #   0: the name of the variable
        #   1: the position of the variable
        #   2: the size of the variable (e.g. {$foo} would have a size of 6)
        #   3: the type of the variable. Either @ (array) or $ (single element)
        #   4 (optional): the list index this variable is intended to access.
        # Element 4 only occurs for array variables. The size of the list is
        # how some sections of this function determine whether the variable
        # descriptor is an array or single element variable: do not touch.
        vars = [] 

        i = 0
        while i < len(self.template) - 2:
            # If not start of variable expression, continue to next index.
            if self.template[i] != '{' or self.template[i+1] not in ('$', '@'): # $: single element variable. @: array element variable.
                i += 1
                continue

            # Find end of variable expression
            j = i + 2
            while j < len(self.template) and self.template[j] != '}':
                if self.template[j] == '{':
                    raise self.create_parse_error(f"{self.template[i:j+1]} is invalid variable name. Cannot start new variable without terminating previous.")
                j += 1

            var_type = self.template[i+1]
            var_name = self.template[i+2:j]
            if len(var_name) == 0:
                raise self.create_parse_error(f"Variable {self.template[i:j+1]} has name length of zero.")
            elif var_name[0].isdigit():
                raise self.create_parse_error(f"Variable {self.template[i:j+1]} has name which begins with digit.")
            vars.append([var_name, i, j-i+1, var_type])
            
            i = j + 1 # Since we found a variable, we can skip to the end of it to search for the next.
        
        # Further process array variables to determine their index
        for var in vars:
            is_list = var[3] == '@'
            if not is_list:
                continue
            var_name = var[0]
            # If the variable is a list variable, it will end with digits of a certain length
            # denoting the index it is intended to access. We must strip these from the variable name.
            k = len(var_name)
            while var_name[k-1].isdigit():
                k -= 1
            if k == len(var_name):
                raise self.create_parse_error(f"List element variable {self.template[var[1]:var[1]+var[2]]} does not have index.")
            index = int(var_name[k:])

            var[0] = var_name[:k]
            var.append(index)
        
        printstring = self.template
        populated_fields = [] 

        # Populate the values from the params dict into the printstring
        while len(vars) > 0:
            # The value that will be substituted for the variable in the printstring
            var_value = " "

            # Iterate through each key in the parameters dictionary. If there is a match between a parameter
            # name and a variable name, change var_value to the value of the parameter.
            for key in params:
                if vars[0][0] != key:
                    continue
                if key not in populated_fields:
                    populated_fields.append(key)
                if len(vars[3]) == '@': # List variable
                    if vars[0][4] < len(params[key]):
                        var_index = vars[0][4]
                        var_value = str(params[key][var_index]) # Access the correct element of the list
                else: # Regular variable
                    var_value = str(params[key])
                break

            if len(var_value) < 1: var_value = " "

            start = printstring[0:vars[0][1]] # Take the first half of the string (before the variable)
            end = printstring[vars[0][1]+vars[0][2]:] # Take the second half of the string (after the variable)
            printstring = start + var_value + end

            # d_index is the difference in lengths of the original variable. It is important to shift the indices of
            # all the following variables by this value, otherwise we will attempt to modify the wrong portion of text.
            d_index = len(var_value) - vars[0][2]
            for entry in vars:
                entry[1] += d_index
            vars.pop(0)
        
        for key in params:
            if key not in populated_fields:
                print(f"Printer Warning: parameter '{key}' was not populated into printstring.")

        return printstring


class PersonPrinter:
    def __init__(self):
        self.printer = Printer("printing/templates/Label.prn")
    
    def print_person(self, person: Person):
        lifts = []
        avgs = []
        maxes = []

        for lift, measurements in person.measurements.items():
            lifts.append(lift)

            mean = round(sum(measurements) / len(measurements))
            avgs.append(mean)

            maxes.append(round(max(measurements)))
        
        parameters = {
            "Name" : lifts,
            "Avg" : avgs,
            "Max" : maxes
        }

        self.printer.print(parameters)
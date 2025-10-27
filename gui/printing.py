import datetime
from personaldata import Person
import subprocess
import platform

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

    def generate_print_string(self, dict: dict):
        # A list containing lists that describe a variable. The list contains:
        #   0: the name of the variable
        #   1: the position of the variable
        #   2: the size of the variable (e.g. {$foo} would have a size of 6)
        #   3 (optional): the list index this variable is intended to access.
        # Element 3 only occurs for array variables. The size of the list is
        # how some sections of this function determine whether the variable
        # descriptor is an array or single element variable: do not touch.
        vars = [] 

        i = 0
        while i < len(self.template) - 2:
            # If start of variable expression, process. Otherwise, continue on to next index.
            if self.template[i] == '{' and self.template[i+1] in ('$', '@'): # $: single element variable. @: array element variable.
                # Find end of variable expression
                j = i + 2
                while j < len(self.template) and self.template[j] != '}':
                    if self.template[j] == '{':
                        raise Exception("Printer parsing error: Attempted to start new variable name without terminating previous.")
                    j += 1
                
                var_name = self.template[i+2:j] # The variable name is the word(s) between the brackets
                if len(var_name) < 1:
                    raise Exception("Printer parsing error: cannot have variable name of length zero.")
                
                is_list = self.template[i+1] == '@'
                if is_list:
                    # If the variable is a list variable, it will end with digits of a certain length
                    # denoting the index it is intended to access. We must strip these from the variable name.
                    k = len(var_name)
                    while var_name[k-1].isdigit():
                        k -= 1
                    if k == len(var_name):
                        raise Exception("Printer parsing error: list element does not have index. Look for {@list123} elements that do not have numbers.")
                    index = int(var_name[k:])
                    var_name = var_name[:k]
                    vars.append([var_name, i, j-i+1, index]) # Add the array variable descriptor to the variables list.
                else:
                    vars.append([var_name, i, j-i+1]) # Single element variable; therefore no index element.
                i = j + 1 # Since we found a variable, we can skip to the end of it to search for the next.
            i += 1
        
        printstring = self.template

        # Populate the values from dict into the printstring
        while len(vars) > 0:
            # The value that will be substituted for the variable in the printstring
            var_value = " "

            # Iterate through each key in the parameters dictionary. If there is a match between a parameter
            # name and a variable name, change var_value to the value of the parameter.
            for key in dict:
                if vars[0][0] != key:
                    continue
                if len(vars[0]) == 4: # List variable
                    if vars[0][3] < len(dict[key]):
                        var_index = vars[0][3]
                        var_value = str(dict[key][var_index]) # Access the correct element of the list
                else: # Regular variable
                    var_value = str(dict[key])
                break

            if len(var_value) < 1: var_value = " "

            start = printstring[0:vars[0][1]] # Take the first half of the string (before the variable)
            end = printstring[vars[0][1]+vars[0][2]:] # Take the second half of the string (after the variable)
            printstring = start + var_value + end

            # d_index is the difference in lengths of the original variable. It is important to shift the indices of
            # all the following variables by this value, otherwise we will attempt to modify the wrong portion of text.
            print(var_value)
            print("{@"+vars[0][0]+"}")
            d_index = len(var_value) - vars[0][2]
            print(d_index)
            vars.pop(0)
            for entry in vars:
                entry[1] += d_index

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
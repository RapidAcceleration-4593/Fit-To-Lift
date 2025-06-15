from typing_extensions import Any

def _absolute_generator(setpoint_inches):
    return lambda height : setpoint_inches

def _proportional_generator(proportion):
    return lambda height : height * proportion

_tests: list[dict[str, Any]] = [
    { "setpoint-calculator" : _absolute_generator(3), "name" : "Floor-Level Lift", "instructions" : "Squat down, grip the bar with both hands, and lift straight up using your legs. Keep your back straight." },
    { "setpoint-calculator" : _absolute_generator(15), "name" : "Knee-Level Lift", "instructions" : "Bend slightly, grip the bar just below your knees, and stand up tall, driving through your legs." },
    { "setpoint-calculator" : _proportional_generator(.5), "name" : "Waist-Level Lift", "instructions" : "Stand close, grip the bar at waist height, and lift it straight up to your chest. Keep elbows in." },
    { "setpoint-calculator" : _absolute_generator(60), "name" : "Shoulder-Level, Arms In", "instructions" : "Grip the bar at shoulder height with elbows tucked in. Push straight up above your head." },
    { "setpoint-calculator" : _absolute_generator(60), "name" : "Shoulder-Level, Arms Out", "instructions" : "Grip the bar wider, elbows out. Push the bar overhead in a straight line. Lock arms at the top." }
]

class TestManager:
    def __init__(self, reps_per_test = 3, tests: list[dict[str, Any]] = _tests) -> None:
        self.current_test_index = 0
        self.current_repetition = 1
        self.reps_per_test = reps_per_test
        self.tests = tests

    def next_test(self):
        if self.current_repetition < self.reps_per_test: 
            self.current_repetition += 1
        else:
            self.current_repetition = 1
            self.current_test_index += 1

    def get_current_test(self):
        if (self.is_testing_complete()):
            return { "setpoint-calculator" : _absolute_generator(0), "name" : "Testing Complete", "instructions" : "You finished!" }
        return self.tests[self.current_test_index]

    def get_current_repetition(self):
        return self.current_repetition

    def is_testing_complete(self):
        return self.current_test_index >= len(self.tests)
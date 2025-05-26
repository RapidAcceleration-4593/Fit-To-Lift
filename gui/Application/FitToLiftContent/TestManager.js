.pragma library

var tests = [
    { name: "Floor-Level Lift", instructions: "Squat down, grip the bar with both hands, and lift straight up using your legs. Keep your back straight." },
    { name: "Knee-Level Lift", instructions: "Bend slightly, grip the bar just below your knees, and stand up tall, driving through your legs." },
    { name: "Waist-Level Lift", instructions: "Stand close, grip the bar at waist height, and lift it straight up to your chest. Keep elbows in." },
    { name: "Shoulder-Level, Arms In", instructions: "Grip the bar at shoulder height with elbows tucked in. Push straight up above your head." },
    { name: "Shoulder-Level, Arms Out", instructions: "Grip the bar wider, elbows out. Push the bar overhead in a straight line. Lock arms at the top." }
];

var currentTestIndex = 0;
var currentRepetition    = 1;

function nextTest() {
    if (currentRepetition < 3) {
        currentRepetition += 1;
    } else {
        currentRepetition = 1;
        currentTestIndex += 1;
    }
}

function getCurrentTest() {
    return tests[currentTestIndex];
}

function getCurrentIndex() {
    return currentTestIndex;
}

function getCurrentRepetition() {
    return currentRepetition;
}

function isTestingComplete() {
    return currentTestIndex >= tests.length;
}

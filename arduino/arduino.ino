#include <Encoder.h>
#include <PID_v1.h>

// pin connections
#define LOAD_CELL A1
#define TOP_LS 8
#define BOTTOM_LS 9

#define MOTOR_RIGHT 6
#define MOTOR_LEFT 5

#define MAGNET_A 12
#define MAGNET_B 13

// Setpoints
#define CMD_L1 "floor"
#define SET_L1 0

#define CMD_L2 "knee"
#define SET_L2 2000

#define CMD_L3 "waist"
#define SET_L3 20000

#define CMD_L4 "chest"
#define SET_L4 25000


Encoder encoder(2, 3);

bool magnetEngaged = false;

double setpoint = 0;
bool goingToSetpoint = false;

bool bottomLSSticky = false;

double currentMotorSpeed = 0;

void setup() {
  Serial.begin(115200);
  Serial.setTimeout(5);

  // Input
  pinMode(LOAD_CELL, INPUT);
  pinMode(TOP_LS, INPUT_PULLUP);
  pinMode(BOTTOM_LS, INPUT_PULLUP);

  // Output
  pinMode(MOTOR_RIGHT, OUTPUT);
  pinMode(MOTOR_LEFT, OUTPUT);
  pinMode(MAGNET_A, OUTPUT);
  pinMode(MAGNET_B, OUTPUT);
  
  analogWrite(MOTOR_LEFT, 0);
  analogWrite(MOTOR_RIGHT, 0);

  digitalWrite(MAGNET_A, LOW);
  digitalWrite(MAGNET_B, LOW);

  magnetDisengage();
}

void loop() {
  // Serial.print(bottomLSPressed());

  if (Serial.available() != 0) {
    handleSerialInput();
  }

  if (bottomLSPressed()) {
    bottomLSSticky = true;
  }

  if (bottomLSPressed() && setpoint < encoder.readAndReset()) {
    setpoint = 0;
    goingToSetpoint = false;
  }

  if (topLSPressed() && setpoint > encoder.read()) {
    setpoint = encoder.read();
    goingToSetpoint = false;
  }

  if (goingToSetpoint) {
    handleSetpointMovement();
  }
  updateMotor();
}

void handleSerialInput() {
  Serial.println("Reading commands");
  String command = Serial.readString();
  command.trim();
  Serial.println(command);

  if (command == "u") {
    moveMotorUp();
  } else if (command == "d") {
    moveMotorDown();
  } else if (command == "e") {
    magnetEngage();
  } else if (command == "r") {
    magnetDisengage();
  } else if (command == CMD_L1) {
    setSetpoint(SET_L1);
  } else if (command == CMD_L2) {
    setSetpoint(SET_L2);
  } else if (command == CMD_L3) {
    setSetpoint(SET_L3);
  } else if (command == CMD_L4) {
    setSetpoint(SET_L4);
  } else if (command == "encoder") {
    Serial.println(encoder.read());
  } else if (command == "topls") {
    Serial.println(topLSPressed());
  } else if (command == "bottomls") {
    Serial.println(bottomLSPressed());
  } else if (command == "stickyls") {
    Serial.println(bottomLSSticky);
  } else if (command == "clearstickyls") {
    bottomLSSticky = false; 
  } else if (command == "zero") {
    encoder.readAndReset();
  } else {
    Serial.println("No such command");
  }
}

bool setSetpoint(double set) {
  goingToSetpoint = true;
  setpoint = set;
}

void handleSetpointMovement() {
  if (!goingToSetpoint) { return; }

  if (abs(encoder.read() - setpoint) < 100) {
    goingToSetpoint = false;
    stopMotor();
    magnetEngage();
  } else {
    magnetDisengage();
    setMotorSpeed((setpoint > encoder.read()) ? 100 : -100);
  }
}

void setMotorSpeed(int speed) {
  currentMotorSpeed = speed;
  updateMotor();
}

void updateMotor() {
  int finalSpeed = currentMotorSpeed;

  // Handle limit switches
  if (topLSPressed()) {
    finalSpeed = min(0, currentMotorSpeed);
  }

  if (bottomLSPressed()) {
    finalSpeed = max(0, currentMotorSpeed);
  }
  
  // Write to motors
  if (!magnetEngaged) {
    currentMotorSpeed = finalSpeed;
    analogWrite(MOTOR_RIGHT, -min(0, finalSpeed));
    analogWrite(MOTOR_LEFT, max(0, finalSpeed));
  } else {
    stopMotor();
  }
}

void moveMotorUp() {
  // goingToSetpoint = false;
  // magnetDisengage();
  // setMotorSpeed(100);
  // delay(500);
  // stopMotor();
  // magnetEngage();
  setSetpoint(encoder.read() + 1200);
}

void moveMotorDown() {
  // goingToSetpoint = false;
  // magnetDisengage();
  // setMotorSpeed(-100);
  // delay(500);
  // stopMotor();
  // magnetEngage();
  setSetpoint(encoder.read() - 1200);
}

void stopMotor() {
  analogWrite(MOTOR_RIGHT, 0);
  analogWrite(MOTOR_LEFT, 0);
  currentMotorSpeed = 0;
}

void magnetEngage() {
  digitalWrite(MAGNET_A, HIGH);
  digitalWrite(MAGNET_B, HIGH);

  magnetEngaged = true;
}

void magnetDisengage() {
  digitalWrite(MAGNET_A, LOW);
  digitalWrite(MAGNET_B, LOW);

  magnetEngaged = false;
}

bool topLSPressed() {
  return digitalRead(TOP_LS);
}

bool bottomLSPressed() {
  return digitalRead(BOTTOM_LS);
}

void printData() {

  Serial.print("Encoder: ");
  Serial.print(encoder.read());
  Serial.println();

  Serial.print("Top Limit Switch: ");
  Serial.print(topLSPressed());
  Serial.println();

  Serial.print("Bottom Limit Switch: ");
  Serial.print(bottomLSPressed());
  Serial.println();

  Serial.print("Load Cell: ");
  Serial.println(analogRead(LOAD_CELL));
  Serial.println();
}
#include <Encoder.h>
#include <PID_v1.h>

// Pin Connections.
#define LOAD_CELL A1
#define TOP_LS 8
#define BOTTOM_LS 9

#define MOTOR_LEFT 5
#define MOTOR_RIGHT 6

#define MAGNET_A 12
#define MAGNET_B 13

// Named Setpoints
#define FLOOR_SETPOINT 0
#define KNEE_SETPOINT 2000
#define WAIST_SETPOINT 20000
#define CHEST_SETPOINT 25000

// Commands for Setpoints
#define CMD_FLOOR "floor"
#define CMD_KNEE "knee"
#define CMD_WAIST "waist"
#define CMD_CHEST "chest"

Encoder encoder(2, 3);

bool isMagnetEngaged = false;
bool isMovingToSetpoint = false;
bool isBottomLSSticky = false;

double setpoint = 0;
double currentMotorSpeed = 0;

void setup() {
  Serial.begin(115200);
  Serial.setTimeout(5);

  // Inputs
  pinMode(LOAD_CELL, INPUT);
  pinMode(TOP_LS, INPUT_PULLUP);
  pinMode(BOTTOM_LS, INPUT_PULLUP);

  // Outputs
  pinMode(MOTOR_LEFT, OUTPUT);
  pinMode(MOTOR_RIGHT, OUTPUT);
  pinMode(MAGNET_A, OUTPUT);
  pinMode(MAGNET_B, OUTPUT);
  
  analogWrite(MOTOR_LEFT, 0);
  analogWrite(MOTOR_RIGHT, 0);

  digitalWrite(MAGNET_A, LOW);
  digitalWrite(MAGNET_B, LOW);

  stopMotor();
  disengageMagnet();
}

void loop() {
  if (Serial.available()) {
    processSerialCommand();
  }

  // Update Bottom LS Sticky State.
  if (isBottomLSPressed()) {
    isBottomLSSticky = true;
  }

  // Reset Setpoint if Bottom LS is Pressed and Position Overshoots.
  if (isBottomLSPressed() && setpoint < encoder.readAndReset()) {
    setpoint = 0;
    isMovingToSetpoint = false;
  }

  // Adjust Setpoint if Top LS is Pressed and Position Overshoots.
  if (isTopLSPressed() && setpoint > encoder.read()) {
    setpoint = encoder.read();
    isMovingToSetpoint = false;
  }

  if (isMovingToSetpoint) {
    moveToSetpoint();
  }

  updateMotorOutputs();
}

void processSerialCommand() {
  String command = Serial.readString();
  command.trim();

  if (command == "u") {
    moveBySteps(1200);
  } else if (command == "d") {
    moveBySteps(-1200);
  } else if (command == "e") {
    engageMagnet();
  } else if (command == "r") {
    disengageMagnet();
  } else if (command == CMD_FLOOR) {
    setSetpoint(FLOOR_SETPOINT);
  } else if (command == CMD_KNEE) {
    setSetpoint(KNEE_SETPOINT);
  } else if (command == CMD_WAIST) {
    setSetpoint(WAIST_SETPOINT);
  } else if (command == CMD_CHEST) {
    setSetpoint(CHEST_SETPOINT);
  } else if (command == "encoder") {
    Serial.println(encoder.read());
  } else if (command == "topls") {
    Serial.println(isTopLSPressed());
  } else if (command == "bottomls") {
    Serial.println(isBottomLSPressed());
  } else if (command == "stickyls") {
    Serial.println(isBottomLSSticky);
  } else if (command == "clearstickyls") {
    isBottomLSSticky = false; 
  } else if (command == "zero") {
    encoder.readAndReset();
  } else {
    Serial.println("Unknown Command!");
  }
}

void setSetpoint(double newSetpoint) {
  setpoint = newSetpoint;
  isMovingToSetpoint = true;
}

void moveBySteps(int steps) {
  setSetpoint(encoder.read() + steps);
}

void moveToSetpoint() {
  long currentPos = encoder.read();
  long error = setpoint - currentPos;

  if (abs(error) < 100) {
    isMovingToSetpoint = false;
    stopMotor();
    engageMagnet();
  } else {
    disengageMagnet();
    setMotorSpeed((error > 0) ? 100 : -100);
  }
}

void setMotorSpeed(int speed) {
  currentMotorSpeed = speed;
  updateMotorOutputs();
}

void updateMotorOutputs() {
  int adjustedSpeed = currentMotorSpeed;

  // Prevent movement past top limit switch.
  if (isTopLSPressed()) {
    adjustedSpeed = min(0, adjustedSpeed);
  }

  // Prevent movement past bottom limit switch.
  if (isBottomLSPressed()) {
    adjustedSpeed = max(0, adjustedSpeed);
  }
  
  // Write to Motors.
  if (isMagnetEngaged) {
    stopMotor();
  } else {
    analogWrite(MOTOR_RIGHT, -min(0, adjustedSpeed));
    analogWrite(MOTOR_LEFT, max(0, adjustedSpeed));
    currentMotorSpeed = adjustedSpeed;
  }
}

void stopMotor() {
  analogWrite(MOTOR_RIGHT, 0);
  analogWrite(MOTOR_LEFT, 0);
  currentMotorSpeed = 0;
}

void engageMagnet() {
  digitalWrite(MAGNET_A, HIGH);
  digitalWrite(MAGNET_B, HIGH);
  isMagnetEngaged = true;
}

void disengageMagnet() {
  digitalWrite(MAGNET_A, LOW);
  digitalWrite(MAGNET_B, LOW);
  isMagnetEngaged = false;
}

bool isTopLSPressed() {
  return digitalRead(TOP_LS) == LOW;
}

bool isBottomLSPressed() {
  return digitalRead(BOTTOM_LS) == LOW;
}

void printData() {
  Serial.print("Encoder: ");
  Serial.print(encoder.read());
  Serial.println();

  Serial.print("Top Limit Switch: ");
  Serial.print(isTopLSPressed());
  Serial.println();

  Serial.print("Bottom Limit Switch: ");
  Serial.print(isBottomLSPressed());
  Serial.println();

  Serial.print("Load Cell: ");
  Serial.println(analogRead(LOAD_CELL));
  Serial.println();
}
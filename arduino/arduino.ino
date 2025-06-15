#include <Encoder.h>

// Pin connections
#define LOAD_CELL A1
#define TOP_LS 8
#define BOTTOM_LS 9

#define MOTOR_RIGHT 6
#define MOTOR_LEFT 5

#define MAGNET_A 12
#define MAGNET_B 13

// Commands
#define UP_CMD "u"
#define DOWN_CMD "d"
#define SETPOINT_CMD "sp"
#define READ_CELL_CMD "r"
#define STATUS_CMD "st"
#define E_STOP_CMD "e"
#define CMD_SEP '\n' // The character that separates commands from each other
#define SEPARATOR ' ' // The character that separates expressions within the same command

Encoder encoder(2, 3);

bool emergencyStopped = false;

double setpoint = 0;
bool goingToSetpoint = false;

double currentMotorSpeed = 0;
bool magnetEngaged = false;

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
  if (emergencyStopped) {
    return;
  }

  if (Serial.available() != 0) {
    handleSerialInput();
  }

  if (isBottomLSPressed() && setpoint < encoder.readAndReset()) {
    setpoint = 0;
    goingToSetpoint = false;
  }

  if (isTopLSPressed() && setpoint > encoder.read()) {
    setpoint = encoder.read();
    goingToSetpoint = false;
  }

  if (goingToSetpoint) {
    handleSetpointMovement();
  }
  updateMotor();
}

void handleSerialInput() {
  while (Serial.available()) {
    String input = Serial.readStringUntil(CMD_SEP);
    input.trim();
    input.toLowerCase();

    // Note: if the command and payload are separated by multiple separators in serial, executeCommand will not recognize the command
    int separatingIndex = input.indexOf(SEPARATOR);

    String command;
    String payload;

    if (separatingIndex != -1) {
      command = input.substring(0, separatingIndex);
      payload = input.substring(separatingIndex + 1);
    } else {
      command = input;
    }
    executeCommand(command, payload);
  }
}

void executeCommand(String command, String payload) {
  if (command == UP_CMD) {
    bumpMotorUp();
  } else if (command == DOWN_CMD) {
    bumpMotorDown();
  } else if (command == SETPOINT_CMD) {
    double newSetpoint = payload.toDouble();
    setSetpoint(newSetpoint);
  } else if (command == READ_CELL_CMD) {
    printLoadCellReading();
  } else if (command == STATUS_CMD) {
    printStatus();
  } else if (command == E_STOP_CMD) {
    emergencyStop();
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
  if (isTopLSPressed()) {
    finalSpeed = min(0, currentMotorSpeed);
  }

  if (isBottomLSPressed()) {
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

void bumpMotorUp() {
  setSetpoint(encoder.read() + 1200);
}

void bumpMotorDown() {
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

bool isTopLSPressed() {
  return digitalRead(TOP_LS);
}

bool isBottomLSPressed() {
  return digitalRead(BOTTOM_LS);
}

void printStatus() {
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
  Serial.println(readLoadCellLbs());
  Serial.println();
}

void printLoadCellReading() {
  Serial.println(readLoadCellLbs());
}

double readLoadCellLbs() {
  return 0; // TODO: Implement load cell reading functionality
}

void emergencyStop() {
  emergencyStopped = true;
  goingToSetpoint = false;
  magnetEngage();
  stopMotor();
}
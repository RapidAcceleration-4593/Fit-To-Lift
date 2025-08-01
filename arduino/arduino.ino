#include <Encoder.h>
#include <io.h>
#include <iom328p.h> // Included for intellisense purposes

// Pin connections
#define LOAD_CELL A1
#define TOP_LS 8
#define BOTTOM_LS 9

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

Encoder encoder(4, 5);

bool emergencyStopped = false;

double setpoint = 0;
bool goingToSetpoint = false;

bool magnetEngaged = false;

void setup() {
  Serial.begin(115200);
  Serial.setTimeout(5);

  // Input
  pinMode(TOP_LS, INPUT_PULLUP);
  pinMode(BOTTOM_LS, INPUT_PULLUP);
  pinMode(LOAD_CELL, INPUT);

  // Output
  configureMotorPWM();
  pinMode(MAGNET_A, OUTPUT);
  pinMode(MAGNET_B, OUTPUT);
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
    stopMotor();
  }

  if (isTopLSPressed() && setpoint > encoder.read()) {
    setpoint = encoder.read();
    goingToSetpoint = false;
    stopMotor();
  }

  if (goingToSetpoint) {
    handleSetpointMovement();
  }
}

void configureMotorPWM() {

  /*
  DDRB is the Data Direction Register B. It configures whether pins are input or output.

  DDB3: This sets OC2A (pin 11) to output.
  */
  DDRB |= bit(DDB3);

  /*
  DDRD is the Data Direction Register D. In configures whether pins are input or output.]

  DDD3: This sets OC2B (pin 3) to output.
  */
  DDRD |= bit(DDD3);

  /*
  TCCR2A is the Timer Counter Control Register A for timer 2.
  Here is a breakdown of the bits being set:

  WGM21 and WGM20: These are Waveform Generation Mode bits. Setting
  both of them enables Fast PWM.
  COM2A1: Setting this bit links pin OC2A (pin 11) to timer 2's PWM.
  COM2B1: Setting this bit links pin OC2B (pin 3) to timer 2's PWM.
  */

  TCCR2A = bit(WGM21) | bit(WGM20) | bit(COM2A1) | bit(COM2B1);

  /*
  TCCR2B is the Timer Counter Control Register B for timer 2.
  
  CS22 and CS20: The Clock Select bits control the clock prescaler of the
  timer. Setting CS22 and CS20 sets a prescaler of 128, slowing the timer down 128x. 
  With no prescaler, timer 2 operates at 16 MHz. Because it is an 8 bit timer, it
  counts up from 0 to 255. That is the length of a PWM cycle. So PWM with no prescaler
  operates at 62.5 KHz. With a prescaler of 128, the PWM frequency drops to approximately
  488 Hz.
  */
  TCCR2B = bit(CS22) | bit(CS20);

  /*
  OCR2A and OCR2B: OCR2x stands for Output Compare Register x. Because we are using
  fast PWM mode on timer 2, the timer counts up from 0 to 255. OC2x is turned on when
  the timer starts at 0, and turned off when it reaches OCR2x. Thus, the value in OCR2x
  is the duty cycle for OC2x's PWM.

  Because we don't want the motor's running when we start up the device, we set both
  registers to 0.
  */
  OCR2A = 0;
  OCR2B = 0;
}

/**
 * Set the speed of the elevator motor, from -1 to 1.
 */
void setMotorSpeed(float speed) {
  if (speed > 0) {
    OCR2A = uint8_t(min(1, speed) * 255);
    OCR2B = 0;
  } else {
    OCR2A = 0;
    OCR2B = uint8_t(min(1, -speed) * 255);
  }
}

float getMotorSpeed() {
  return (OCR2A - OCR2B) / 255.0F;
}

void stopMotor() {
  setMotorSpeed(0);
  magnetEngage();
}

void handleSerialInput() {
  while (Serial.available()) {
    String input = Serial.readStringUntil(CMD_SEP);
    input.trim();
    input.toLowerCase();

    /*
    Note: if the command and payload are separated by multiple
    separators in serial, executeCommand will not recognize the command.
    */
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
  if (!goingToSetpoint) return;

  if (abs(encoder.read() - setpoint) < 100) {
    goingToSetpoint = false;
    stopMotor();
    magnetEngage();
  } else {
    if (magnetEngaged) magnetDisengage();
    setMotorSpeed((setpoint > encoder.read()) ? 0.2 : -0.2);
  }
}

void bumpMotorUp() {
  setSetpoint(encoder.read() + 1200);
}

void bumpMotorDown() {
  setSetpoint(encoder.read() - 1200);
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
  return analogRead(LOAD_CELL);
}

void emergencyStop() {
  emergencyStopped = true;
  goingToSetpoint = false;
  magnetEngage();
  stopMotor();
}
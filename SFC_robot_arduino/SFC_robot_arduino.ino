//
// 28 March 2019 - 05:50

#include <Servo.h>

// Serial Handler Vars
String inputString = "";         // a String to hold incoming data
bool stringComplete = false;  // whether the string is complete

// Servo Objects
Servo servoA, servoB, servoC, servoD;
int lowLimitA = 400;
int lowLimitB = 400;
int lowLimitC = 400;
int lowLimitD = 400;
int highLimitA = 2500;
int highLimitB = 2500;
int highLimitC = 2500;
int highLimitD = 2500;

// Current Servo Angles
float cangleA = 90, cangleB = 90, cangleC = 90, cangleD = 90;
// Serial Input Angles
float angleA = 90, angleB = 90, angleC = 90, angleD = 90;
// Target Servo Angles
float tangleA = 90, tangleB = 90, tangleC = 90, tangleD = 90;
// Memory Angles
float mangleA[50];
float mangleB[50];
float mangleC[50];
float mangleD[50];
int memoryLength = 50;

// Animation frame
int animFrame = 0;
int animCounter = 0;
int animInterval = 1000;
bool animReached = false;
int frameCount = 0;

// Joystick Button
int buttonPinA = 7;
int buttonPinB = 5;
int buttonStateA = 0;
int buttonStateB = 0;
int lastButtonStateA = LOW;
int lastButtonStateB = LOW;
unsigned long lastDebounceTimeA = 0;  // the last time the output pin was toggled
unsigned long lastDebounceTimeB = 0;  // the last time the output pin was toggled
unsigned long debounceDelay = 50;    // the debounce time; increase if the output flickers

// Modes
int mode = 2;

// Joystick Analogue Pins
int joyPinX = 1;
int joyPinY = 0;
int potA = 3;
int potB = 2;
// speed vars
float rotSpeed = 0.1;
bool inTimerLoop = false;
unsigned long timerStart = 0;
unsigned long timerLoopDuration = 3;

bool inAnimTimerLoop = false;
unsigned long animTimerStart = 0;
unsigned long animTimerLoopDuration = 1000;

// Joystick States
int valX, valY, valA, valB;
// Joystick Deadzones (Range is 0-1023)
int deadzoneLow = 128;
int deadzoneHigh = 896;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(38400);
  // reserve 200 bytes for the inputString:
  inputString.reserve(200);
  pinMode(buttonPinA, INPUT_PULLUP);
  pinMode(buttonPinB, INPUT_PULLUP);
  servoA.attach(11, lowLimitA, highLimitA);
  servoB.attach( 9, lowLimitB, highLimitB);
  servoC.attach(10, lowLimitC, highLimitC);
  servoD.attach( 6, lowLimitD, highLimitD);
  directMoveServos();
  //Serial.println("Start");
  // Handle Serial Output
//  Serial.print("Current Angles");
//  Serial.print(" A:");
//  Serial.print(cangleA);
//  Serial.print(" B:");
//  Serial.print(cangleB);
//  Serial.print(" C:");
//  Serial.print(cangleC);
//  Serial.print(" D:");
//  Serial.println(cangleD);
}

void joystick(){
  // Get debounced button state and change mode
  debounce();
  if(mode == 0){
    valX = analogRead(joyPinX);
    valY = analogRead(joyPinY);
    valA = analogRead(potA);
    valA = map(valA, 0, 1023, 0, 180);
    valB = analogRead(potB);
    valB = map(valB, 0, 1023, 0, 180);
    tangleA = (float)valA;
    tangleB = (float)valB;
    if(valX < deadzoneLow || valX > deadzoneHigh){
      if(valX < deadzoneLow){
        tangleC += rotSpeed;
        tangleC = constrain(tangleC, 0, 180);
      }
      if(valX > deadzoneHigh){
        tangleC -= rotSpeed;
        tangleC = constrain(tangleC, 0, 180);
      }
    }
    if(valY < deadzoneLow || valY > deadzoneHigh){
      if(valY < deadzoneLow){
        tangleD -= rotSpeed;
        tangleD = constrain(tangleD, 0, 180);
      }
      if(valY > deadzoneHigh){
        tangleD += rotSpeed;
        tangleD = constrain(tangleD, 0, 180);
      }
    }
  }
}

void serialOutput(){
  frameCount++;
  Serial.print("Current Angles");
  Serial.print(" A:"); // invert A axis
  Serial.print(180-(int)cangleA);
  Serial.print(" B:");
  Serial.print((int)cangleB);
  Serial.print(" C:");
  Serial.print((int)cangleC);
  Serial.print(" D:");
  Serial.print((int)cangleD);
  Serial.print(" Mode:");
  Serial.print(mode);
  Serial.print(" animCounter:");
  Serial.print(animCounter);
  Serial.print(" animFrame:");
  Serial.print(animFrame);
  Serial.print(" frameCount:");
  Serial.println(frameCount);
}

int convertAngleToMicros(float angle){
  int rangeMicros = highLimitA - lowLimitA;
  float microsPerDegree = rangeMicros / 180;
  int returnvalue =  (float)lowLimitA + (angle * microsPerDegree);
  return returnvalue;
}

void moveServos(){
  if(!inTimerLoop){
    timerStart = millis();
    inTimerLoop = true;
  }
  if(millis()-timerStart > timerLoopDuration){
    inTimerLoop = false;
    if(cangleA<tangleA){
      cangleA += rotSpeed;
      //servoA.write(cangleA);
      servoA.writeMicroseconds(convertAngleToMicros(cangleA));
    }
    if(cangleA>tangleA){
      cangleA -= rotSpeed;
      //servoA.write(cangleA);
      servoA.writeMicroseconds(convertAngleToMicros(cangleA));
    }
    if(cangleB<tangleB){
      cangleB += rotSpeed;
      //servoB.write(cangleB);
      servoB.writeMicroseconds(convertAngleToMicros(cangleB));
    }
    if(cangleB>tangleB){
      cangleB -= rotSpeed;
      //servoB.write(cangleB);
      servoB.writeMicroseconds(convertAngleToMicros(cangleB));
    }
    if(cangleC<tangleC){
      cangleC += rotSpeed;
      //servoC.write(cangleC);
      servoC.writeMicroseconds(convertAngleToMicros(cangleC));
    }
    if(cangleC>tangleC){
      cangleC -= rotSpeed;
      //servoC.write(cangleC);
      servoC.writeMicroseconds(convertAngleToMicros(cangleC));
    }
    if(cangleD<tangleD){
      cangleD += rotSpeed;
      //servoD.write(cangleD);
      servoD.writeMicroseconds(convertAngleToMicros(cangleD));
    }
    if(cangleD>tangleD){
      cangleD -= rotSpeed;
      //servoD.write(cangleD);
      servoD.writeMicroseconds(convertAngleToMicros(cangleD));
    }
  }
}

void directMoveServos(){
  //servoA.write(tangleA);
  //servoB.write(tangleB);
  //servoC.write(tangleC);
  //servoD.write(tangleD);
  servoA.writeMicroseconds(convertAngleToMicros(tangleA));
  servoB.writeMicroseconds(convertAngleToMicros(tangleB));
  servoC.writeMicroseconds(convertAngleToMicros(tangleC));
  servoD.writeMicroseconds(convertAngleToMicros(tangleD));
  cangleA = tangleA;
  cangleB = tangleB;
  cangleC = tangleC;
  cangleD = tangleD;
}

void debounce(){
  // read the state of the switch into a local variable:
  int readingA = digitalRead(buttonPinA);
  int readingB = digitalRead(buttonPinB);

  // If the switch changed, due to noise or pressing:
  if (readingA != lastButtonStateA) {
    // reset the debouncing timer
    lastDebounceTimeA = millis();
  }
  if (readingB != lastButtonStateB) {
    // reset the debouncing timer
    lastDebounceTimeB = millis();
  }

  if ((millis() - lastDebounceTimeA) > debounceDelay) {
    // if the button state has changed:
    if (readingA != buttonStateA) {
      buttonStateA = readingA;

      // Save Position
      if (buttonStateA == LOW) {
        savePosition();
      }
    }
  }
  if ((millis() - lastDebounceTimeB) > debounceDelay) {
    // if the button state has changed:
    if (readingB != buttonStateB) {
      buttonStateB = readingB;

      // Start Animation
      if (buttonStateB == LOW) {
        startAnimation();
      }
    }
  }

  // save the readingA. Next time through the loop, it'll be the lastButtonStateA:
  lastButtonStateA = readingA;
  lastButtonStateB = readingB;
}

void savePosition(){
  if(mode == 0 || mode == 2){
    mangleA[animFrame] = cangleA;
    mangleB[animFrame] = cangleB;
    mangleC[animFrame] = cangleC;
    mangleD[animFrame] = cangleD;
    animFrame++;
  }
  if(mode == 1){
    mode == 0;
    animFrame = 0;
  }
}

void startAnimation(){
  if(mode == 0 || mode == 2){
    mangleA[animFrame] = -1;
    mangleB[animFrame] = -1;
    mangleC[animFrame] = -1;
    mangleD[animFrame] = -1;
    animFrame = 0;
    inAnimTimerLoop = false;
    mode = 1;
  }
}

void animate(){
  // Check if end of memory
  if(mangleA[animFrame]== -1){
      animFrame = 0;
  }
  // set target angle to memory value
  tangleA = mangleA[animFrame];
  tangleB = mangleB[animFrame];
  tangleC = mangleC[animFrame];
  tangleD = mangleD[animFrame];
  // wait till target reached
  if(tangleA == cangleA && tangleB == cangleB && tangleC == cangleC && tangleD == cangleD && !inAnimTimerLoop){
    // start timer
    animTimerStart = millis();
    inAnimTimerLoop = true;
  }
  // when timer expires, increment memory position
  if(millis() - animTimerStart > animTimerLoopDuration && inAnimTimerLoop){
    animFrame++;
    if(animFrame==memoryLength){
      animFrame = 0;
    }
    // Reset timer
    inAnimTimerLoop = false;
  }
}

void serialEvent() {
  while (Serial.available()) {
    // get the new byte:
    char inChar = (char)Serial.read();
    // add it to the inputString:
    inputString += inChar;
    // if the incoming character is a newline, set a flag so the main loop can
    // do something about it:
    if (inChar == '\n') {
      stringComplete = true;
    }
  }
}

void parseSerial(){
  if (stringComplete) {
    if(inputString.startsWith("R")){
      serialOutput();
    }
    if(inputString.startsWith("S")){
      mode = 2;
      tangleA = (float)(180 - angleSubstring("A"));  // Invert A axis
      tangleB = (float)angleSubstring("B");  
      tangleC = (float)angleSubstring("C");
      tangleD = (float)angleSubstring("D");
      //Serial.println(angleString);
      serialOutput();
    }
    if(inputString.startsWith("M")){
      mode = 2;
      savePosition();
      serialOutput();
    }
    if(inputString.startsWith("P")){
      mode = 2;
      startAnimation();
      serialOutput();
    }
    // clear the string:
    inputString = "";
    stringComplete = false;
  }
}

int angleSubstring(String label){
  int labelIndex;
  int delimIndex;
  String angleString;
  labelIndex = inputString.indexOf(label);
  delimIndex = inputString.indexOf(",", labelIndex);
  angleString = inputString.substring(labelIndex+1,delimIndex);
  int newTargetAngle = angleString.toInt();
  return newTargetAngle;
}

void loop() {
  // Parse Serial Input
  parseSerial();
  
  // Handle Joystick Input
  joystick();

  // Animate Robot
  if(mode == 1){
    animate();
  }
  // Handle Serial Input
  //serialInput();
  
  // Move servos directly
  //directMoveServos();

  // Move Servos if required
  moveServos();
  
  // Delay between loops
  //delay(15);
}

import processing.serial.*;

int lf = 10;    // Linefeed in ASCII
String serialText = null;
Serial myPort;  // The serial port
PFont f;
int mousePressedX = 0;
int mousePressedY = 0;
int mousePressedOn = 0;
boolean validDrag = true;
int startAngle = 0;
int[] setAngles = {90,90,90,90};
int[] setBoxesX = {300, 350, 400, 450};
boolean[] overBox = {false, false, false, false};

int frameCounter = 0;

// For each axis
String[] readAngles = new String[4];
String[] labels = {"A:","B:","C:","D:"};

// Arm vis vars
Arm armA, armB;
int angle = 0;
int direction = 1;
LegalMove[] legalMoves = {};
boolean firstRun = true;

void setup() {
  size(1000, 600);
  frameRate(100);
  f = createFont("Lucida Console", 14);
  textFont(f);
    
  // List all the available serial ports
  //printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 38400);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  myPort.bufferUntil(lf);
  //serialText = myPort.readStringUntil(lf);
  //serialText = null;
  
  // Arm Vis code
  
  //SPEC: Arm(float ax1, float ay1, float ax2, float ay2, float aangle, float aR)
  armA = new Arm(750,100,850,100,0,100);
  armB = new Arm(850,100,900,100,0,50);
  armA.updateOffsetAngle(-60);
  armB.updateOffsetAngle(-160);
}

void serialEvent(Serial p) { 
  serialText = p.readString(); 
}

void mousePressed() {
  for(int i = 0; i < 4; i++){
    if(overBox[i]){
      mousePressedX = mouseX;
      mousePressedY = mouseY;
      mousePressedOn = i;
      startAngle = setAngles[i];
      validDrag = true;
    }
  }
}

void mouseReleased() {
  validDrag = false;
}

void dragSetAngleBoxes(){
  int offsetY;
  if(mousePressed && validDrag){
    int previousAngle = setAngles[mousePressedOn];
    offsetY = mouseY - mousePressedY;
    setAngles[mousePressedOn] = startAngle - (offsetY/2);
    if(setAngles[mousePressedOn]<0){
      setAngles[mousePressedOn] = 0;
    }
    if(setAngles[mousePressedOn]>180){
      setAngles[mousePressedOn] = 180;
    }
    if(previousAngle != setAngles[mousePressedOn]){
      String outputText = "S A" + setAngles[0] + ",B" + setAngles[1] + ",C" + setAngles[2] + ",D" + setAngles[3] + ",\n";
      myPort.write(outputText);
      print(outputText);
    }
  }
}

void draw() {
  if(frameCount%10 == 0){
    myPort.write("R\n");
    //println("Trigger");
  }
 
  // clear screen and draw envelope
  background(20);
  drawEnvelope();
  
  fill(200,200,200);
  text(" frameCounter: " + frameCounter, 20, 60);
  text(" frameCounter2: " + frameCount, 200, 60);
  
  // Target coords
  float targetX = mouseX;
  float targetY = height - mouseY;
  
  // calculate intersections
  Point[] ints = getIntersections( armA, targetX, targetY, armB.R);
  float[] motorAngles = getMotorAngles(ints, targetX, targetY);
  
  // Invert Y axis
  pushMatrix();
  scale(1,-1);
  translate(0, -height);
  
  stroke(255);
  noFill();
    
  // Draw Arms
  armA.drawArm();
  armB.drawArm();
  
  // Draw preview arms
  if( (motorAngles[0] >= 0 && motorAngles[0] <= 180) && (motorAngles[1] >= 0 && motorAngles[1] <= 180) ){
    // Red Lines
    stroke(255,0,0);
    circle(ints[0].x,ints[0].y,10);
    line(armA.x1, armA.y1, ints[0].x, ints[0].y);
    line(targetX, targetY, ints[0].x, ints[0].y);
  }
  if( (motorAngles[2] >= 0 && motorAngles[2] <= 180) && (motorAngles[3] >= 0 && motorAngles[3] <= 180) ){
    // Green Lines
    stroke(0,255,0);
    circle(ints[1].x,ints[1].y,10);
    line(armA.x1, armA.y1, ints[1].x, ints[1].y);
    line(targetX, targetY, ints[1].x, ints[1].y);
  }
    
  popMatrix();
  
  // Set Angle Boxes
  dragSetAngleBoxes();
  for(int i = 0; i < 4; i++){
    drawBox(str(setAngles[i]), setBoxesX[i]);
    overBox[i] = mouseInBox(setAngles[i], setBoxesX[i]);
    //text(" inBox" + labels[i] + " " + overBox[i], 20, 160+ (i*20));
  }
  
  if (serialText != null) {
    frameCounter++;
    String serialHeader = serialText.substring(0,7);
    text(" Output: " + serialText, 20, 20);
    text(" serialHeader: " + serialHeader, 20, 40);
    
    if(serialHeader.equals("Current")){
      for(int i = 0; i < 4; i++){
        readAngles[i] = getAngleFromSerial(serialText, labels[i]);
        text(" readAngle" + labels[i] + " " + readAngles[i], 20, 80 + (i*20));
        // Read Angle Boxes
        drawBox(readAngles[i], 50 + (i*50));
        if(i==0){
          armA.updateAngle(float(readAngles[i]));
        }
        if(i==1){
          armB.updateAngle(float(readAngles[i]));
          armB.updateParentAngle(armA.worldAngle);
          armB.updatePivot(armA.x2,armA.y2);
        }
      }
    }
  }
}

String getAngleFromSerial(String input, String label){
  //println("Len " + input.length());
  String substring = "";
  int indexStart = 0;
  int indexEnd = 0;
  indexStart = input.indexOf(label) + label.length();
  indexEnd = input.indexOf(" ", indexStart);
  //println(indexStart);
  //println(indexEnd);
  if(indexStart != -1 && indexEnd != -1){
    substring = input.substring(indexStart, indexEnd);
    return substring;
  }
  else{
    return substring;
  }
}

int boxSpan = 360;
int boxWidth = 40;
int boxHeight = 30;

void drawBox(String angleBox, int boxX){
  int angleInt = int(angleBox);
  
  int boxY = boxSpan - (angleInt*2) + 200;
  fill(0);
  stroke(40);
  rect(boxX, boxSpan - 160, boxWidth, 360 + boxHeight);
  stroke(255);
  rect(boxX, boxY, boxWidth, boxHeight);
  fill(255);
  text(angleBox, boxX + 8, boxY + 20);
}

boolean mouseInBox(int setAngle, int setBoxX){
  int setBoxY = boxSpan - (setAngle*2) + 200;
  if(mouseX >= setBoxX && (mouseX <= setBoxX+boxWidth) && mouseY >= setBoxY && (mouseY <= setBoxY+boxHeight)){
    return true;
  }
  return false;
}

//
//
// Arm vis functions
class Point{
  float x, y;
  Point(float px, float py) {
    x = px;
    y = py;
  }
  Point sub(Point p2) {
    return new Point(x - p2.x, y - p2.y);
  }
  Point add(Point p2) {
    return new Point(x + p2.x, y + p2.y);
  }
  float distance(Point p2) {
    return sqrt((x - p2.x)*(x - p2.x) + (y - p2.y)*(y - p2.y));
  }
  Point normal() {
    float length = sqrt(x*x + y*y);
    return new Point(x/length, y/length);
  }
  Point scale(float s) {
    return new Point(x*s, y*s);
  }
}

class Circle {
  float x, y, r, left;
  Circle(float cx, float cy, float cr) {
    x = cx;
    y = cy;
    r = cr;
    left = x - r;
  }
  Point intersections1(Circle c) {
    Point returnValue;  
    Point P0 = new Point(x, y);
    Point P1 = new Point(c.x, c.y);
    float d, a, h;
    d = P0.distance(P1);
    a = (r*r - c.r*c.r + d*d)/(2*d);
    h = sqrt(r*r - a*a);
    Point P2 = P1.sub(P0).scale(a/d).add(P0);
    float x3, y3, x4, y4;
    x3 = P2.x + h*(P1.y - P0.y)/d;
    y3 = P2.y - h*(P1.x - P0.x)/d;
    x4 = P2.x - h*(P1.y - P0.y)/d;
    y4 = P2.y + h*(P1.x - P0.x)/d;
    returnValue = new Point(x3, y3);
    return returnValue;
  }
  Point intersections2(Circle c) {
    Point returnValue;  
    Point P0 = new Point(x, y);
    Point P1 = new Point(c.x, c.y);
    float d, a, h;
    d = P0.distance(P1);
    a = (r*r - c.r*c.r + d*d)/(2*d);
    h = sqrt(r*r - a*a);
    Point P2 = P1.sub(P0).scale(a/d).add(P0);
    float x3, y3, x4, y4;
    x3 = P2.x + h*(P1.y - P0.y)/d;
    y3 = P2.y - h*(P1.x - P0.x)/d;
    x4 = P2.x - h*(P1.y - P0.y)/d;
    y4 = P2.y + h*(P1.x - P0.x)/d;
    returnValue = new Point(x4, y4);
    return returnValue;
  }
}

class Arm {
  float x1, y1, x2, y2, angle, R, parentAngle, offsetAngle, worldAngle;
  Arm(float ax1, float ay1, float ax2, float ay2, float aangle, float aR){
    x1 = ax1;
    x2 = ax2;
    y1 = ay1;
    y2 = ay2;
    angle = aangle;
    parentAngle = 0;
    offsetAngle = 0;
    worldAngle = angle + parentAngle + offsetAngle;
    R = aR;
  }
  void setWorldAngle(){
    worldAngle = angle + parentAngle + offsetAngle;
  }
  void updateOffsetAngle(float aoffsetAngle){
    offsetAngle = aoffsetAngle;
    x2 = (R * cos( radians(worldAngle) ) ) + x1;
    y2 = (R * sin( radians(worldAngle) ) ) + y1;
    setWorldAngle();
   
  }
  void updateAngle(float aangle){
    angle = aangle;
    x2 = (R * cos( radians(worldAngle) ) ) + x1;
    y2 = (R * sin( radians(worldAngle) ) ) + y1;
    setWorldAngle();
    
  }
  void updateParentAngle(float aparentAngle){
    parentAngle = aparentAngle;
    x2 = (R * cos( radians(worldAngle) ) ) + x1;
    y2 = (R * sin( radians(worldAngle) ) ) + y1;
    setWorldAngle();
  }
  void updateCoords(float ax1, float ax2, float ay1, float ay2){
    x1 = ax1;
    x2 = ax2;
    y1 = ay1;
    y2 = ay2;
    angle = atan( (y2-y1) / (x2-x1) );
  }
  void updatePivot(float ax1, float ay1){
    x2 = x2 + ax1-x1;
    y2 = y2 + ay1-y1;
    x1 = ax1;
    y1 = ay1;
  }
  void drawArm(){
    line(x1, y1, x2, y2);
  }
}

Point[] getIntersections(Arm _arm, float _x2, float _y2, float _R){
  Circle circleA = new Circle( _arm.x1, _arm.y1, _arm.R);
  Circle circleB = new Circle( _x2, _y2, _R);
  Point[] returnValue = {circleA.intersections2(circleB), circleA.intersections1(circleB)};
  return returnValue;
}

float getAngle(float _x1, float _y1, float _x2, float _y2){
  float angle = degrees( atan2( (_y2 - _y1) , ( _x2 - _x1) ) );
  return angle;
}

float[] getMotorAngles(Point[] ints, float _x, float _y){
  float angleA1 = getAngle(armA.x1, armA.y1, ints[0].x, ints[0].y);
  float angleB1 = getAngle(ints[0].x, ints[0].y, _x, _y );
  float angleA2 = getAngle(armA.x1, armA.y1, ints[1].x, ints[1].y);
  float angleB2 = getAngle(ints[1].x, ints[1].y, _x, _y );
  float motorAngleA1 = angleA1 - armA.offsetAngle;
  float motorAngleB1 = angleB1 - angleA1 - armB.offsetAngle;
  float motorAngleA2 = angleA2 - armA.offsetAngle;
  float motorAngleB2 = angleB2 - angleA2 - armB.offsetAngle;
  if(motorAngleB1>360){
    motorAngleB1 -= 360;
  }
  if(motorAngleB2>360){
    motorAngleB2 -= 360;
  }
  float[] returnValue = {motorAngleA1, motorAngleB1, motorAngleA2, motorAngleB2};
  return returnValue;
}

void drawAngleInfo(float motorAngleA1, float motorAngleB1, float motorAngleA2, float motorAngleB2){
  if(motorAngleA1 < 0 || motorAngleA1 > 180){fill(255,0,0);} else{fill(255);}
  text(" motorAngleA1: " + motorAngleA1, 20, 60);
  if(motorAngleB1 < 0 || motorAngleB1 > 180){fill(255,0,0);} else{fill(255);}
  text(" motorAngleB1: " + motorAngleB1, 20, 80);
  if(motorAngleA2 < 0 || motorAngleA2 > 180){fill(255,0,0);} else{fill(255);}
  text(" motorAngleA2: " + motorAngleA2, 20, 100);
  if(motorAngleB2 < 0 || motorAngleB2 > 180){fill(255,0,0);} else{fill(255);}
  text(" motorAngleB2: " + motorAngleB2, 20, 120);
  fill(255);
}

class LegalMove{
  boolean legal;
  int x, y;
  LegalMove(boolean _legal, int _x, int _y){
    legal = _legal;
    x = _x;
    y = _y;
  }
}

LegalMove[] calcLegalMoves(){
  //println("In: calcLegalMoves");
  LegalMove[] legalMoves = {};
  Point[] ints2;
  float[] motorAngles;
  boolean valid;
  for(int x = 0; x < width; x++){
    for(int y = 0; y < height; y++){
      ints2 = getIntersections(armA, x, y, armB.R);
      motorAngles = getMotorAngles(ints2, x, y);
      valid = (motorAngles[0] >= 0 && motorAngles[0] <= 180) && (motorAngles[1] >= 0 && motorAngles[1] <= 180);
      valid = valid || (motorAngles[2] >= 0 && motorAngles[2] <= 180) && (motorAngles[3] >= 0 && motorAngles[3] <= 180);
      if(valid){
        LegalMove legalMove = new LegalMove(true, x, y);
        legalMoves = (LegalMove[])append(legalMoves, legalMove);
      }
    }
  }
  return legalMoves;
}

void drawLegalMoves(LegalMove[] _legalMoves){
  //println("In: showLegalMoves " +_legalMoves.length);
  for(int i = 0; i < _legalMoves.length ; i++ ){
    LegalMove lm = _legalMoves[i];
    if(lm.legal){
      stroke(100,100,100,100);
      line(lm.x,lm.y,lm.x,lm.y);
    }
  }
}

void drawEnvelope(){
  pushMatrix();
  scale(1,-1);
  translate(0, -height);
      
  if(firstRun){
    drawLegalMoves(calcLegalMoves());
    loadPixels();
    firstRun = false;
  }else{
    updatePixels();
  }
  popMatrix();
}

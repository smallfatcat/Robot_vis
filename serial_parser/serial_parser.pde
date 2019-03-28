//
// 28 March 2019 - 05:50

import processing.serial.*;

int lf = 10;    // Linefeed in ASCII
String serialText = null;
Serial myPort;  // The serial port
PFont f;
int mousePressedX = 0;
int mousePressedY = 0;
int mousePressedOn = 0;
boolean validDrag = false;
int startAngle = 0;
int[] setAngles = {90,90,90,90};
int[] setBoxesX = {300, 350, 400, 450};
boolean[] overBox = {false, false, false, false};

// Button vars
Button button0 = new Button("Save", "M", 900, 10, 950, 40);
Button button1 = new Button("Play", "P", 840, 10, 890, 40);
Button[] buttons = {button0, button1};

int frameCounter = 0;

// For each axis
String[] currentAngles = new String[4];
String[] labels = {"A:","B:","C:","D:"};

// Arm vis vars
Arm armA, armB;
int angle = 0;
int direction = 1;
LegalMove[] legalMoves = {};
boolean firstRun = true;

// Box vars
int boxSpan = 360;
int boxWidth = 40;
int boxHeight = 30;

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
  armA = new Arm(800,100,858,100,0,58);
  armB = new Arm(858,100,900,100,0,42);
  armA.updateOffsetAngle(-60);
  armB.updateOffsetAngle(-160);
}

void draw() {
  // Every 10 frames send a serial message to arduino to get info
  if(frameCount%10 == 0){
    // Request current angles
    myPort.write("R\n");
  }
 
  // clear screen and draw envelope
  background(20);
  drawEnvelope();
  
  fill(200,200,200);
  text(" frameCounter: " + frameCounter, 20, 60);
  text(" frameCounter2: " + frameCount, 200, 60);
  
  // Store Target coords from mouse position
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
  boolean angleSent = false;
  if( (motorAngles[0] >= 0 && motorAngles[0] <= 180) && (motorAngles[1] >= 0 && motorAngles[1] <= 180) ){
    // Red Lines
    stroke(255,0,0);
    circle(ints[0].x,ints[0].y,10);
    line(armA.x1, armA.y1, ints[0].x, ints[0].y);
    line(targetX, targetY, ints[0].x, ints[0].y);
    if(mousePressed && !angleSent){
      if(setAngles[0] != int(motorAngles[0]) || setAngles[1] != int(motorAngles[1])){
        setAngles[0] = int(motorAngles[0]);
        setAngles[1] = int(motorAngles[1]);
        sendNewAngles(setAngles, "1st motor: ");
        angleSent = true;
      }
    }
  }
  if( (motorAngles[2] >= 0 && motorAngles[2] <= 180) && (motorAngles[3] >= 0 && motorAngles[3] <= 180) ){
    // Green Lines
    stroke(0,255,0);
    circle(ints[1].x,ints[1].y,10);
    line(armA.x1, armA.y1, ints[1].x, ints[1].y);
    line(targetX, targetY, ints[1].x, ints[1].y);
    if(mousePressed && !angleSent){
      if(setAngles[0] != int(motorAngles[2]) || setAngles[1] != int(motorAngles[3])){
        setAngles[0] = int(motorAngles[2]);
        setAngles[1] = int(motorAngles[3]);
        sendNewAngles(setAngles, "2nd motor: ");
      }
    }
  }
    
  popMatrix();
  
  // Button
  drawButtons();
    
  // Draw Set Angle Boxes
  dragSetAngleBoxes();
  for(int i = 0; i < 4; i++){
    drawBox(str(setAngles[i]), setBoxesX[i]);
    overBox[i] = mouseInBox(setAngles[i], setBoxesX[i]);
    //text(" inBox" + labels[i] + " " + overBox[i], 20, 160+ (i*20));
  }
  
  // Draw Read Angle Boxes
  if (serialText != null) {
    frameCounter++;
    String serialHeader = serialText.substring(0,7);
    text(" Output: " + serialText, 20, 20);
    text(" serialHeader: " + serialHeader, 20, 40);
    
    if(serialHeader.equals("Current")){
      for(int i = 0; i < 4; i++){
        currentAngles[i] = getAngleFromSerial(serialText, labels[i]);
        //text(" readAngle" + labels[i] + " " + currentAngles[i], 20, 80 + (i*20));
        
        // Read Angle Boxes
        drawBox(currentAngles[i], 50 + (i*50));
        
        // update Preview Angles for A and B
        if(i==0){
          armA.updateAngle(float(currentAngles[i]));
        }
        if(i==1){
          armB.updateAngle(float(currentAngles[i]));
          armB.updateParentAngle(armA.worldAngle);
          armB.updatePivot(armA.x2,armA.y2);
        }
      }
    }
  }
}

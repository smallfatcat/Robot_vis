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

boolean portChosen = false;
String[] sl;

String lastSerialSend = "";

void setup() {
  size(1000, 600);
  frameRate(100);
  f = createFont("Lucida Console", 14);
  textFont(f);
  
  // Get serial ports
  sl = Serial.list();
    
  // Arm Vis code
  //SPEC: Arm(float ax1, float ay1, float ax2, float ay2, float aangle, float aR)
  armA = new Arm(800,100,858,100,0,58);
  armB = new Arm(858,100,900,100,0,42);
  armA.updateOffsetAngle(-90);
  armB.updateOffsetAngle(-90);
}

void draw(){
  if(portChosen){
    mainDraw();
  }
  else{
    // List all the available serial ports
    background(20);
    stroke(255);
    text("Select serial port to use:", 20, 20);
    for(int i = 0; i < sl.length; i++){
      //println(sl[i]);
      text(sl[i] + " [" + (i+1)+"]", 20, 40 + (i*20));
    }
  }
}


void mainDraw() {
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
  text(" LastSent: " + lastSerialSend, 20, 40);
  
  // Invert Y axis
  pushMatrix();
  scale(1,-1);
  translate(0, -height);
  
  stroke(255);
  noFill();
 
   // Store Target coords from mouse position
  float targetX = mouseX;
  float targetY = height - mouseY;
  
  // calculate intersections
  Point[] ints = getIntersections( armA, targetX, targetY, armB.R);
  float[] motorAngles = getMotorAngles(ints, targetX, targetY);
  float motAngA1 = motorAngles[0];
  float motAngB1 = motorAngles[1];
  float motAngA2 = motorAngles[2];
  float motAngB2 = motorAngles[3];
    
  // Draw Arms
  armA.drawArm();
  armB.drawArm();
    
  // Draw preview arms
  boolean angleSent = false;
  if( validRange(motAngA1) && validRange(motAngB1) ){
    // Red Lines
    stroke(255,0,0);
    drawPreviewArm(ints[0], armA, targetX, targetY);
    if(mousePressed && !angleSent){
      setNewAngles(motAngA1, motAngB1);
      angleSent = true;
    }
  }
  if( validRange(motAngA2) && validRange(motAngB2) ){
    // Green Lines
    stroke(0,255,0);
    drawPreviewArm(ints[1], armA, targetX, targetY);
    if(mousePressed && !angleSent){
      setNewAngles(motAngA2, motAngB2);
    }
  }
    
  popMatrix();
  
  // Button
  stroke(255);
  drawButtons();
    
  // Draw Set Angle Boxes
  dragSetAngleBoxes();
  for(int i = 0; i < 4; i++){
    drawBox(str(setAngles[i]), setBoxesX[i]);
    overBox[i] = mouseInBox(setAngles[i], setBoxesX[i]);
  }
  
  // Draw Current Angle Boxes
  if (serialText != null) {
    frameCounter++;
    String serialHeader = serialText.substring(0,7);
    text(" LastRCVD: " + serialText, 20, 20);
        
    if(serialHeader.equals("Current")){
      for(int i = 0; i < 4; i++){
        currentAngles[i] = getAngleFromSerial(serialText, labels[i]);
        String curAngle = currentAngles[i];
                
        // Read Angle Boxes
        drawBox(curAngle, 50 + (i*50));
        
        // update Preview Angles for A and B
        if(i==0){
          armA.updateAngle(float(curAngle));
        }
        if(i==1){
          armB.updateAngle(float(curAngle));
          armB.updateParentAngle(armA.worldAngle);
          armB.updatePivot(armA.x2,armA.y2);
        }
      }
    }
  }
}

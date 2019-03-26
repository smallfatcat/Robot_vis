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
  background(20);
  fill(200,200,200);
  text(" frameCounter: " + frameCounter, 20, 60);
  text(" frameCounter2: " + frameCount, 200, 60);
  
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

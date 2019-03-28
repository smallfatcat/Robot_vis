void drawButtons(){
  stroke(255);
  for(int i = 0; i < buttons.length; i++){
    Button but = buttons[i];
    rect(but.x1, but.y1, but.x2 - but.x1, but.y2 - but.y1);
    text(but.label, but.x1 + 8, but.y1 + 20);
  }
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
      //String outputText = "S A" + setAngles[0] + ",B" + setAngles[1] + ",C" + setAngles[2] + ",D" + setAngles[3] + ",\n";
      //myPort.write(outputText);
      //print(outputText);
      sendNewAngles(setAngles, "Drag: ");
    }
  }
}

void sendNewAngles(int[] _setAngles, String _text){
  String outputText = "S A" + _setAngles[0] + ",B" + _setAngles[1] + ",C" + _setAngles[2] + ",D" + _setAngles[3] + ",\n";
  myPort.write(outputText);
  println(_text + outputText);
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
// Arm vis functions
//
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

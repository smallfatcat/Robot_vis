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
  
  // Check if buttons pressed
  for(int i = 0; i < buttons.length; i++){
    Button but = buttons[i];
    if(but.isOverButton(mouseX, mouseY)){
      myPort.write(but.serialCommand + "\n");
      lastSerialSend = but.serialCommand;
      println(but.label+" Pressed");
    }
  }
}

void mouseReleased() {
  validDrag = false;
}

void keyPressed() {
  if(!portChosen){
    boolean serialSet = false;
    int len = Serial.list().length;
    if(key == '1' && len >= 1){
      myPort = new Serial(this, Serial.list()[0], 38400);
      serialSet = true;
    }
    if(key == '2' && len >= 2){
      myPort = new Serial(this, Serial.list()[1], 38400);
      serialSet = true;
    }
    if(key == '3' && len >= 3){
      myPort = new Serial(this, Serial.list()[2], 38400);
      serialSet = true;
    }
    if(key == '4' && len >= 3){
      myPort = new Serial(this, Serial.list()[3], 38400);
      serialSet = true;
    }

    if(serialSet){
      myPort.clear();
      myPort.bufferUntil(lf);
      portChosen = true;
    }
  }
}

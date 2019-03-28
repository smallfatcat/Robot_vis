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
      println(but.label+" Pressed");
    }
  }
}

void mouseReleased() {
  validDrag = false;
}

void keyPressed() {
  if(!portChosen){
    if(key == '1'){
      myPort = new Serial(this, Serial.list()[0], 38400);
      myPort.clear();
      myPort.bufferUntil(lf);
      portChosen = true;
    }
    if(key == '2'){
      myPort = new Serial(this, Serial.list()[1], 38400);
      myPort.clear();
      myPort.bufferUntil(lf);
      portChosen = true;
    }
  }
}

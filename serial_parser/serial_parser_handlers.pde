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
    if(mouseX >= but.x1 && mouseX <=but.x2 && mouseY >= but.y1 && mouseY <= but.y2){
      myPort.write(but.serialCommand + "\n");
      print(but.label+" Pressed");
    }
  }
}

void mouseReleased() {
  validDrag = false;
}

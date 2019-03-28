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
  if(mouseX >= button1[0] && mouseX <= button1[2] && mouseY >= button1[1] && mouseY <= button1[3]){
    myPort.write("M\n");
    print("button1 Pressed");
  }
  if(mouseX >= button2[0] && mouseX <= button2[2] && mouseY >= button2[1] && mouseY <= button2[3]){
    myPort.write("P\n");
    print("button2 Pressed");
  }
}

void mouseReleased() {
  validDrag = false;
}

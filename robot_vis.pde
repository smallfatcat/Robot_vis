//Added to github

// Configuration variables
float animationSpeed = 20.0f;
float         angleA = 0.0f;
float         angleB = 0.0f;
float        offsetA = 0.0f;
float        offsetB = 0.0f;
float             Ox = 200.0f;
float             Oy = 60.0f;
float           MagA = 50.0f;

// System Variables
PFont f;
float Ax, Ay, Bx, By;
float[] aBx = new float[32400];
float[] aBy = new float[32400];
float[] aBdistance = new float[32400];
int counter;

void setup() {
  size(640, 380);
  background(102);
  // Setup fonts
  f = createFont("Lucida Console", 14);
  textFont(f);
  // Calculate B position with current offsets
  calcB();
}

void draw() {
  background(20);
  
  // Draw Info Text
  drawText();
  
  // Invert Y axis
  pushMatrix();
  scale(1,-1);
  translate(0, -height);
  
  // Draw Calculated Area
  drawCalc();
  
  // Draw Robot Arms
  drawRobotArms();
  
  // Restore Matrix
  popMatrix();
  
  // Animate angles 
  animateAngles();
}

void drawCalc(){
  stroke(255,255,255,20); 
  for(int k = 0; k < 32400; k++){
     line(aBx[k], aBy[k], aBx[k], aBy[k]);
  }
}

void drawRobotArms(){
  Ax = Ox + (MagA * cos(radians(angleA - offsetA)));
  Ay = Oy + (MagA * sin(radians(angleA - offsetA)));
  Bx = Ax + (MagA * cos(radians(angleA - offsetA - offsetB + angleB)));
  By = Ay + (MagA * sin(radians(angleA - offsetA - offsetB + angleB)));
  
  stroke(255);
  line(Ox, 0, Ox, Oy);
  stroke(255,0,0,100);
  line(Ox, Oy, Ax, Ay);
  stroke(0,255,0,100);
  line(Ax, Ay, Bx, By);
  stroke(255);
  line(Bx, By, Bx, By);
}

void drawText(){
  int textX = 10;
  int textY = 20;
  int spacingY = 15;
  textAlign(LEFT);
  fill(200,0,0);
  text("OffsetA: " + offsetA, textX, textY);
  textY += spacingY;
  fill(0,255,0);
  text("OffsetB: " + offsetB, textX, textY);
  textY += spacingY;
  fill(200,0,0);
  text(" angleA: " + angleA, textX, textY);
  textY += spacingY;
  fill(0,255,0);
  text(" angleB: " + angleB, textX, textY);
  textY += spacingY;
  fill(255);
  text(" mouseX: " + mouseX, textX, textY);
  textY += spacingY;
  text(" mouseY: " + (height - mouseY), textX, textY);
  textY += spacingY;
  
  calcDistance();
  int lowIndex = getLowestDistanceIndex();
  text(" Distance: " + sqrt(aBdistance[lowIndex]), textX, textY);
  textY += spacingY;
  text(" lowIndex: " + lowIndex, textX, textY);
  textY += spacingY;
  text(" A: " + (lowIndex/180), textX, textY);
  textY += spacingY;
  text(" B: " + (lowIndex%180), textX, textY);
}

void animateAngles(){
  angleB+=animationSpeed;
  if(angleB>180){
    angleB = 0.f;
    angleA +=animationSpeed;
    if(angleA>180){
      angleA = 0.0f;
      offsetB+=animationSpeed;
      if(offsetB>180){
        offsetB = 0.0f;
        offsetA+=animationSpeed;
        if(offsetA>180){
          offsetA = 0.0f;
        }
      }
      // Offset changed, recalculate B position
      calcB();
    }
  }
}

void calcB(){
  counter = 0;
  for(float ia=0;ia<180;ia++){
    for(float ib=0;ib<180;ib++){
      Ax = Ox + (MagA * cos(radians(ia- offsetA)));
      Ay = Oy + (MagA * sin(radians(ia- offsetA)));
      aBx[counter] = Ax + (MagA * cos(radians(ia - offsetA - offsetB + ib)));
      aBy[counter] = Ay + (MagA * sin(radians(ia - offsetA - offsetB + ib)));
      counter++;
    }
  }
}

void calcDistance(){
  for(int i=0;i<32400;i++){
    float xdist = abs(aBx[i]-mouseX);
    float ydist = abs(aBy[i]-(height-mouseY));
    aBdistance[i] = (xdist * xdist) + (ydist * ydist);
  }
}

int getLowestDistanceIndex(){
  int lowestIndex=0;
  float lowestDistance = aBdistance[0];
  for(int i=1;i<32400;i++){
    if(aBdistance[i]<lowestDistance){
      lowestIndex = i;
      lowestDistance = aBdistance[i];
    }
  }
  return lowestIndex;
}

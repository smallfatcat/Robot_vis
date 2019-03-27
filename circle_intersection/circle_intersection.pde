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

//Point Point;
Circle circleA, circleB, circleC, circleD;
Arm armA, armB;

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

int angle = 0;
int direction = 1;

void setup() {
  
  //Arm(float ax1, float ay1, float ax2, float ay2, float aangle, float aR)
  armA = new Arm(200,200,300,200,0,100);
  armB = new Arm(300,200,400,200,0,100);
  armA.updateOffsetAngle(-60);
  armB.updateOffsetAngle(-150);
  circleA = new Circle(armA.x1, armA.y1, armA.R);
  circleD = new Circle(armB.x2, armB.y2, armB.R);
  size(800, 600);
}

void draw() {
  circleD.x = mouseX;
  circleD.y = height - mouseY;
  
  background(20);
    
  // Invert Y axis
  pushMatrix();
  scale(1,-1);
  translate(0, -height);
  
  stroke(255);
  noFill();
  // Draw Arms
  armA.drawArm();
  armB.drawArm();
  
  // calculate intersections
  Point int1 = circleA.intersections1(circleD);
  Point int2 = circleA.intersections2(circleD);
  
  // Red Lines
  stroke(255,0,0);
  circle(int1.x,int1.y,10);
  line(armA.x1,armA.y1,int1.x,int1.y);
  line(circleD.x,circleD.y,int1.x,int1.y);
  
  // Green Lines
  stroke(0,255,0);
  circle(int2.x,int2.y,10);
  line(armA.x1,armA.y1,int2.x,int2.y);
  line(circleD.x,circleD.y,int2.x,int2.y);
  
  stroke(255);
  
  popMatrix();
  if(frameCount%5 == 0){
    angle += direction;
    //angle = 90;
    armA.updateAngle((float)angle);
    armB.updateAngle((float)angle);
    armB.updateParentAngle(armA.worldAngle);
    armB.updatePivot(armA.x2,armA.y2);
    println("worldAngleA: " + armA.worldAngle);
    println("worldAngleB: " + armB.worldAngle);
    
  }
  if(angle >= 180){
    direction = -1; 
  }
  if(angle <= 0){
    direction = 1; 
  }
}

//Point intersection1result = testCircle1.intersections1(testCircle2);
//  Point intersection2result = testCircle1.intersections2(testCircle2);
//  //intersection1result = testCircle1.intersections1(testCircle2);
//  //intersection2result = testCircle1.intersections2(testCircle2);
//  println(intersection1result.x);
//  println(intersection1result.y);
//  println(intersection2result.x);
//  println(intersection2result.y);

class Button {
  int x1, y1, x2, y2;
  String label, serialCommand;
  Button(String _label, String _serialCommand, int _x1, int _y1, int _x2, int _y2){
    x1 = _x1;
    y1 = _y1;
    x2 = _x2;
    y2 = _y2;
    label = _label;
    serialCommand = _serialCommand;
  }
  boolean isOverButton(int x, int y){
    boolean returnValue = x >= x1 && x <=x2 && y >= y1 && y <= y2;
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

class LegalMove{
  boolean legal;
  int x, y;
  LegalMove(boolean _legal, int _x, int _y){
    legal = _legal;
    x = _x;
    y = _y;
  }
}

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

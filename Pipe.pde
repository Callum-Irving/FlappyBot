class Pipe {
  float x;
  float width;
  float openingStart;
  float openingEnd;

  // Create a random pipe with opening size specified.
  public Pipe(float x, float width, float openingSize) {
    this.x = x;
    this.width = width;
    this.openingStart = random(0, height - openingSize);
    this.openingEnd = this.openingStart + openingSize;
  }

  public void show() {
    fill(255);

    // Draw top half.
    rect(this.x, 0, this.width, this.openingStart);

    // Draw bottom half.
    rect(this.x, this.openingEnd, this.width, height - this.openingEnd);
  }

  public boolean collidesWith(Bird b) {
    boolean collidesTop = circleRect(b.x, b.y, BIRD_RADIUS, this.x, 0, this.width, this.openingStart);
    boolean collidesBottom = circleRect(b.x, b.y, BIRD_RADIUS, this.x, this.openingEnd, this.width, height);
    return collidesTop || collidesBottom;
  }
}

// Taken from: http://www.jeffreythompson.org/collision-detection/circle-rect.php
boolean circleRect(float cx, float cy, float radius, float rx, float ry, float rw, float rh) {
  // temporary variables to set edges for testing
  float testX = cx;
  float testY = cy;

  // which edge is closest?
  if (cx < rx)         testX = rx;      // test left edge
  else if (cx > rx+rw) testX = rx+rw;   // right edge
  if (cy < ry)         testY = ry;      // top edge
  else if (cy > ry+rh) testY = ry+rh;   // bottom edge

  // get distance from closest edges
  float distX = cx-testX;
  float distY = cy-testY;
  float distance = sqrt( (distX*distX) + (distY*distY) );

  // if the distance is less than the radius, collision!
  if (distance <= radius) {
    return true;
  }

  return false;
}

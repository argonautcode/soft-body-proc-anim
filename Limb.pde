// I quickly wrote this to work with the frog animation so it's very coupled and messy.
// You can find a generalized and slightly less messy distance constraint chain algo here:
// https://github.com/argonautcode/animal-proc-anim/blob/main/Chain.pde
class Limb {
  // Only two points needed.
  LimbPoint elbow;
  LimbPoint foot;

  float distance; // between joints
  float elbowRange;
  float elbowOffset;
  float footRange;
  float footOffset;

  Limb(PVector origin, float distance, float elbowRange, float elbowOffset, float footRange, float footOffset) {
    this.distance = distance;
    this.elbowRange = elbowRange;
    this.elbowOffset = elbowOffset;
    this.footRange = footRange;
    this.footOffset = footOffset;
    elbow = new LimbPoint(PVector.add(origin, new PVector(0, distance)));
    foot = new LimbPoint(PVector.add(elbow.pos, new PVector(0, distance)));
  }

  void resolve(PVector anchor, float normal) {
    elbow.verletIntegrate();
    elbow.applyGravity();
    elbow.applyConstraint(anchor, normal, distance, elbowRange, elbowOffset);
    elbow.keepInBounds();

    foot.verletIntegrate();
    foot.applyGravity();
    foot.applyConstraint(elbow.pos, elbow.angle, distance, footRange, footOffset);
    foot.keepInBounds();
  }

  void display(PVector anchor) {
    strokeWeight(8);
    stroke(0);
    line(anchor.x, anchor.y, elbow.pos.x, elbow.pos.y);
    line(elbow.pos.x, elbow.pos.y, foot.pos.x, foot.pos.y);

    fill(42, 44, 53);
    ellipse(anchor.x, anchor.y, 32, 32);
    ellipse(elbow.pos.x, elbow.pos.y, 32, 32);
    ellipse(foot.pos.x, foot.pos.y, 32, 32);
  }
}

// Perhaps this and BlobPoint could inherit from a Point class but alas I'm lazy
class LimbPoint {
  PVector pos;
  PVector ppos; // previous pos
  float angle;

  LimbPoint(PVector pos) {
    this.pos = pos.copy();
    ppos = pos.copy();
    angle = 0;
  }

  void verletIntegrate() {
    PVector temp = pos.copy();
    PVector vel = PVector.sub(pos, ppos).mult(0.95); // Slightly dampen velocity
    pos.add(vel);
    ppos = temp;
  }

  // distance: distance between anchor and the point
  // angleRange: range of motion, how far the point can be from pointing toward normal
  // angleOffset: rotates the entire range of motion
  void applyConstraint(PVector anchor, float normal, float distance, float angleRange, float angleOffset) {
    float anchorAngle = normal + angleOffset;
    float curAngle = PVector.sub(anchor, pos).heading();
    angle = constrainAngle(curAngle, anchorAngle, angleRange);
    pos = PVector.sub(anchor, PVector.fromAngle(angle).setMag(distance));
  }

  void applyGravity() {
    pos.add(0, 1);
  }

  void keepInBounds() {
    pos.x = constrain(pos.x, 0, width);
    pos.y = constrain(pos.y, 0, height);
  }
}

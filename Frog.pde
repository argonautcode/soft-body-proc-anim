class Frog {
  Blob blob;

  Limb leftFrontLeg;
  Limb rightFrontLeg;

  Limb leftHindLeg;
  Limb rightHindLeg;

  Frog(PVector origin) {
    blob = new Blob(origin, 16, 128, 1.5);
    leftFrontLeg = new Limb(PVector.sub(origin, new PVector(80, 0)), 56, PI/4, PI/8, PI/5, -PI/4);
    rightFrontLeg = new Limb(PVector.sub(origin, new PVector(-80, 0)), 56, PI/4, -PI/8, PI/5, PI/4);

    leftHindLeg = new Limb(PVector.sub(origin, new PVector(100, 0)), 100, 1.9*PI/5, 2*PI/5, 2*PI/5, -2*PI/5);
    rightHindLeg = new Limb(PVector.sub(origin, new PVector(-100, 0)), 100, 1.9*PI/5, -2*PI/5, 2*PI/5, 2*PI/5);
  }

  void update() {
    blob.update();

    PVector leftFront = blob.points.get(12).pos;
    PVector rightFront = blob.points.get(4).pos;
    PVector leftFrontAnchor = PVector.lerp(leftFront, rightFront, 0.25).add(new PVector(0, 10));
    PVector rightFrontAnchor = PVector.lerp(leftFront, rightFront, 0.75).add(new PVector(0, 10));
    PVector midSecant = PVector.sub(rightFront, leftFront).setMag(64);
    float midNormal = midSecant.copy().rotate(-HALF_PI).heading();
    PVector leftHindAnchor = PVector.add(blob.points.get(11).pos, midSecant).add(new PVector(0, 16));
    PVector rightHindAnchor = PVector.sub(blob.points.get(5).pos, midSecant).add(new PVector(0, 16));

    leftFrontLeg.resolve(leftFrontAnchor, midNormal);
    rightFrontLeg.resolve(rightFrontAnchor, midNormal);

    // A little hack to make sure the hind legs go back into position when approaching the ground.
    if (height - leftHindLeg.foot.pos.y < 100) {
      leftHindLeg.elbow.pos.y -= 1.5;
      leftHindLeg.foot.pos.x += 0.5;
    }
    if (height - rightHindLeg.foot.pos.y < 100) {
      rightHindLeg.elbow.pos.y -= 1.5;
      rightHindLeg.foot.pos.x -= 0.5;
    }

    leftHindLeg.resolve(leftHindAnchor, midNormal);
    rightHindLeg.resolve(rightHindAnchor, midNormal);
  }

  void display() {
    drawHindLegs();
    drawBody();
    drawHead();
    drawFrontLegs();
  }

  void drawBody() {
    ArrayList<BlobPoint> points = blob.points;

    strokeWeight(8);
    stroke(0);
    fill(85, 145, 127);
    beginShape();

    // Two extra points on either side of the blob because curveVertex() requires some control points at the ends of the shape.
    curveVertex(points.get(points.size() - 2).pos.x, points.get(points.size() - 2).pos.y);
    curveVertex(points.get(points.size() - 1).pos.x, points.get(points.size() - 1).pos.y);

    for (int i = 0; i < points.size(); i++) {
      BlobPoint cur = points.get(i);
      curveVertex(cur.pos.x, cur.pos.y);
    }

    curveVertex(points.get(0).pos.x, points.get(0).pos.y);
    curveVertex(points.get(1).pos.x, points.get(1).pos.y);

    endShape();
  }

  void drawHead() {
    PVector top = blob.points.get(0).pos;
    float topNormal = PVector.sub(blob.points.get(2).pos, blob.points.get(blob.points.size() - 2).pos).heading();

    pushMatrix();
    translate(top.x, top.y);
    rotate(topNormal);

    // Head
    arc(0, 75, 250, 225, -PI, 0);
    noStroke();
    ellipse(0, 75, 244, 219);

    // Eye socket thingies
    stroke(0);
    noFill();
    arc(-75, -10, 75, 75, -PI-PI/4.6, -PI/5.6);
    arc(75, -10, 75, 75, -PI+PI/5.6, PI/4.6);
    noStroke();
    fill(85, 145, 127);
    ellipse(-75, -10, 70, 70);
    ellipse(75, -10, 70, 70);

    // Eyes
    strokeWeight(4);
    stroke(0);
    fill(240, 153, 91);
    ellipse(-75, -10, 48, 48);
    ellipse(75, -10, 48, 48);

    // Pupils
    noStroke();
    fill(0);
    pushMatrix();
    translate(-75, -10);
    rotate(-PI/24);
    ellipse(0, 0, 32, 18);
    popMatrix();
    pushMatrix();
    translate(75, -10);
    rotate(PI/24);
    ellipse(0, 0, 32, 18);
    popMatrix();

    // Chin
    strokeWeight(7);
    stroke(0);
    noFill();
    arc(0, 80, 92, 48, PI/8, PI-PI/8);

    // Mouth
    strokeWeight(5);
    beginShape();
    vertex(-90, 40);
    bezierVertex(-45, 60, -35, 15, -10, 25);
    bezierVertex(-5, 27, 5, 27, 10, 25);
    bezierVertex(35, 15, 45, 60, 90, 40);
    endShape();

    // Nostrils
    pushMatrix();
    translate(-9, 5);
    rotate(PI/6);
    ellipse(0, 0, 2, 5);
    popMatrix();
    pushMatrix();
    translate(9, 5);
    rotate(-PI/6);
    ellipse(0, 0, 2, 5);
    popMatrix();

    popMatrix();
  }

  void drawFrontLegs() {
    PVector left = blob.points.get(12).pos;
    PVector right = blob.points.get(4).pos;
    PVector leftAnchor = PVector.lerp(left, right, 0.25).add(new PVector(0, 10));
    PVector rightAnchor = PVector.lerp(left, right, 0.75).add(new PVector(0, 10));
    drawFrontLeg(leftAnchor, leftFrontLeg);
    drawFrontLeg(rightAnchor, rightFrontLeg);
  }

  void drawHindLegs() {
    PVector left = blob.points.get(12).pos;
    PVector right = blob.points.get(4).pos;
    PVector midSecant = PVector.sub(right, left).setMag(64);
    PVector leftAnchor = PVector.add(blob.points.get(11).pos, midSecant).add(new PVector(0, 16));
    PVector rightAnchor = PVector.sub(blob.points.get(5).pos, midSecant).add(new PVector(0, 16));
    drawHindLeg(leftAnchor, leftHindLeg, false);
    drawHindLeg(rightAnchor, rightHindLeg, true);
  }

  void drawFrontLeg(PVector anchor, Limb limb) {
    // Outline
    noFill();
    strokeWeight(48);
    stroke(0);

    beginShape();
    curveVertex(anchor.x, anchor.y);
    curveVertex(anchor.x, anchor.y);
    curveVertex(limb.elbow.pos.x, limb.elbow.pos.y);
    curveVertex(limb.foot.pos.x, limb.foot.pos.y);
    curveVertex(limb.foot.pos.x, limb.foot.pos.y);
    endShape();

    // Fill
    strokeWeight(34);
    stroke(85, 145, 127);

    beginShape();
    curveVertex(anchor.x, anchor.y);
    curveVertex(anchor.x, anchor.y);
    curveVertex(limb.elbow.pos.x, limb.elbow.pos.y);
    curveVertex(limb.foot.pos.x, limb.foot.pos.y);
    curveVertex(limb.foot.pos.x, limb.foot.pos.y);
    endShape();

    // Toes
    float footNormal = PVector.sub(limb.elbow.pos, limb.foot.pos).heading() + HALF_PI;
    strokeWeight(6);
    stroke(0);
    fill(85, 145, 127);
    pushMatrix();
    translate(limb.foot.pos.x, limb.foot.pos.y);
    rotate(footNormal - PI/4);
    ellipse(0, 16, 16, 55);
    rotate(PI/6);
    ellipse(0, 28, 16, 55);
    rotate(PI/6);
    ellipse(0, 28, 16, 55);
    rotate(PI/6);
    ellipse(0, 16, 16, 55);
    // Hiding overlaps
    noStroke();
    rotate(-PI/6);
    ellipse(0, 28, 10, 49);
    rotate(-PI/6);
    ellipse(0, 28, 10, 49);
    rotate(-PI/6);
    ellipse(0, 16, 10, 49);
    popMatrix();


    // Hiding the bit where the limb connects to the body
    float shoulderNormal = PVector.sub(anchor, limb.elbow.pos).heading();
    noStroke();
    fill(85, 145, 127);
    arc(anchor.x, anchor.y, 49, 49, -HALF_PI+shoulderNormal, HALF_PI+shoulderNormal);

    // Hiding the bit where the toes connect to the foot
    ellipse(limb.foot.pos.x, limb.foot.pos.y, 35, 35);
  }

  void drawHindLeg(PVector anchor, Limb limb, boolean right) {
    float offset = right ? -PI/8 : PI/8;
    float footNormal = PVector.sub(limb.elbow.pos, limb.foot.pos).heading() + HALF_PI + offset;
    PVector footShift = PVector.add(limb.foot.pos, PVector.fromAngle(footNormal + HALF_PI).setMag(24));
    

    // Outline
    noFill();
    strokeWeight(48);
    stroke(0);

    beginShape();
    curveVertex(anchor.x, anchor.y);
    curveVertex(anchor.x, anchor.y);
    curveVertex(limb.elbow.pos.x, limb.elbow.pos.y);
    curveVertex(limb.foot.pos.x, limb.foot.pos.y);
    curveVertex(footShift.x, footShift.y);
    curveVertex(footShift.x, footShift.y);
    endShape();

    // Fill
    strokeWeight(34);
    stroke(85, 145, 127);

    beginShape();
    curveVertex(anchor.x, anchor.y);
    curveVertex(anchor.x, anchor.y);
    curveVertex(limb.elbow.pos.x, limb.elbow.pos.y);
    curveVertex(limb.foot.pos.x, limb.foot.pos.y);
    curveVertex(footShift.x, footShift.y);
    curveVertex(footShift.x, footShift.y);
    endShape();

    // Toes
    strokeWeight(6);
    stroke(0);
    fill(85, 145, 127);
    pushMatrix();
    translate(footShift.x, footShift.y);
    rotate(footNormal - PI/4 + offset);
    ellipse(0, 16, 16, 55);
    rotate(PI/6);
    ellipse(0, 28, 16, 55);
    rotate(PI/6);
    ellipse(0, 28, 16, 55);
    rotate(PI/6);
    ellipse(0, 16, 16, 55);
    // Hiding overlaps
    noStroke();
    rotate(-PI/6);
    ellipse(0, 28, 10, 49);
    rotate(-PI/6);
    ellipse(0, 28, 10, 49);
    rotate(-PI/6);
    ellipse(0, 16, 10, 49);
    popMatrix();


    // Hiding the bit where the limb connects to the body
    float shoulderNormal = PVector.sub(anchor, limb.elbow.pos).heading();
    noStroke();
    fill(85, 145, 127);
    arc(anchor.x, anchor.y, 49, 49, -HALF_PI+shoulderNormal, HALF_PI+shoulderNormal);

    // Hiding the bit where the toes connect to the foot
    ellipse(footShift.x, footShift.y, 35, 35);
  }

  void debugDisplay() {
    blob.display();

    PVector leftFront = blob.points.get(12).pos;
    PVector rightFront = blob.points.get(4).pos;
    PVector leftFrontAnchor = PVector.lerp(leftFront, rightFront, 0.25).add(new PVector(0, 10));
    PVector rightFrontAnchor = PVector.lerp(leftFront, rightFront, 0.75).add(new PVector(0, 10));
    PVector midSecant = PVector.sub(rightFront, leftFront).setMag(64);
    PVector leftHindAnchor = PVector.add(blob.points.get(11).pos, midSecant).add(new PVector(0, 16));
    PVector rightHindAnchor = PVector.sub(blob.points.get(5).pos, midSecant).add(new PVector(0, 16));

    leftFrontLeg.display(leftFrontAnchor);
    rightFrontLeg.display(rightFrontAnchor);
    leftHindLeg.display(leftHindAnchor);
    rightHindLeg.display(rightHindAnchor);
  }
}

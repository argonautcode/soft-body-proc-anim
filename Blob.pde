class Blob {
  ArrayList<BlobPoint> points;

  float radius;
  float area;
  float circumference;
  float chordLength;

  Blob(PVector origin, int numPoints, float radius, float puffiness) {
    this.radius = radius;
    area = radius * radius * PI * puffiness;
    circumference = radius * TWO_PI;
    chordLength = circumference / numPoints;

    points = new ArrayList<BlobPoint>();
    for (int i = 0; i < numPoints; i++) {
      PVector offset = new PVector(cos(TWO_PI * i / numPoints - HALF_PI) * radius, sin(TWO_PI * i / numPoints - HALF_PI) * radius);
      points.add(new BlobPoint(PVector.add(origin, offset)));
    }
  }

  void update() {
    // Compute one time step of physics with Verlet integration.
    for (BlobPoint point : points) {
      point.verletIntegrate();
      point.applyGravity();
    }

    // Iterate multiple times to converge faster.
    for (int j = 0; j < 10; j++) {
      // Accumulate the displacement caused by distance constraints (preventing points from getting too stretched).
      for (int i = 0; i < points.size(); i++) {
        BlobPoint cur = points.get(i);
        BlobPoint next = points.get(i == points.size() - 1 ? 0 : i + 1);

        PVector diff = PVector.sub(next.pos, cur.pos);
        // We only need to constrain the points if they are too far from each other.
        if (diff.mag() > chordLength) {
          // Both points will be equally pulled together to correct the error.
          float error = (diff.mag() - chordLength) / 2f;
          PVector offset = diff.copy().setMag(error);
          PVector negOffset = offset.copy().mult(-1);
          cur.accumulateDisplacement(offset);
          next.accumulateDisplacement(negOffset);
        }
      }

      // Accumulate the displacement caused by dilation (preventing the blob from getting too squashed).
      float error = area - getArea();
      float offset = error / circumference;

      for (int i = 0; i < points.size(); i++) {
        // The point will be pushed along the normal (as defined from the secant line formed by its neighbors).
        BlobPoint prev = points.get(i == 0 ? points.size() - 1 : i - 1);
        BlobPoint cur = points.get(i);
        BlobPoint next = points.get(i == points.size() - 1 ? 0 : i + 1);
        PVector secant = PVector.sub(next.pos, prev.pos);
        PVector normal = secant.copy().rotate(-HALF_PI).setMag(offset);
        cur.accumulateDisplacement(normal);
      }

      // Apply all the accumulated displacement.
      for (BlobPoint point : points) {
        point.applyDisplacement();
      }

      // Collision detection.
      for (BlobPoint point : points) {
        point.keepInBounds();
        point.collideWithMouse();
      }
    }
  }

  // Get the area of the blob using the trapezoid method.
  float getArea() {
    float area = 0;
    for (int i = 0; i < points.size(); i++) {
      PVector cur = points.get(i).pos;
      PVector next = points.get(i == points.size() - 1 ? 0 : i + 1).pos;
      area += ((cur.x - next.x) * (cur.y + next.y) / 2);
    }
    return area;
  }

  void display() {
    strokeWeight(8);
    stroke(0);
    noFill();
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

    fill(42, 44, 53);
    for (BlobPoint point : points) {
      ellipse(point.pos.x, point.pos.y, 32, 32);
    }
  }
}

class BlobPoint {
  PVector pos;
  PVector ppos; // previous pos

  PVector displacement;
  int displacementWeight;

  BlobPoint(PVector pos) {
    this.pos = pos.copy();
    ppos = pos.copy();
    displacement = new PVector(0, 0);
    displacementWeight = 0;
  }

  void verletIntegrate() {
    PVector temp = pos.copy();
    PVector vel = PVector.sub(pos, ppos).mult(0.99); // Slightly dampen velocity
    pos.add(vel);
    ppos = temp;
  }

  void applyGravity() {
    pos.add(0, 1);
  }

  void accumulateDisplacement(PVector offset) {
    displacement.add(offset);
    displacementWeight += 1;
  }

  void applyDisplacement() {
    if (displacementWeight > 0) {
      displacement.div(displacementWeight);
      pos.add(displacement);
      displacement = new PVector(0, 0);
      displacementWeight = 0;
    }
  }

  void keepInBounds() {
    pos.x = constrain(pos.x, 0, width);
    pos.y = constrain(pos.y, 0, height);
  }

  void collideWithMouse() {
    PVector mouse = new PVector(mouseX, mouseY);
    if (mousePressed && PVector.dist(pos, mouse) < 100) {
      PVector diff = PVector.sub(pos, mouse).setMag(100);
      pos = PVector.add(mouse, diff);
    }
  }
}

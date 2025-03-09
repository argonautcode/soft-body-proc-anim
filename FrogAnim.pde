import processing.javafx.*;

Frog frog;

void setup() {
  fullScreen(FX2D);
  frameRate(60);
  frog = new Frog(new PVector(width / 2, height - 512));
}

void draw() {
  background(40, 44, 52);
  frog.update();
  frog.display();
}

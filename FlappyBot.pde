final float GRAVITY = 0.8;
final float BIRD_RADIUS = 10.0;
final float BIRD_X = 30.0;
final float PIPE_SPEED = 2.5;
final float PIPE_SPACING = 275.0;
final float PIPE_WIDTH = 35.0;
final float PIPE_OPENING_SIZE = 150.0;
final float MUT_RATE = 0.7;

int stepsPerFrame = 1;

Population pop;

void setup() {
  size(800, 800);
  pop = new Population(100);
}

void draw() {
  background(0);
  pop.update();
}

void keyPressed() {
  if (keyCode == UP)
    stepsPerFrame ++;
  else if (keyCode == DOWN)
    stepsPerFrame = max(1, stepsPerFrame - 1);
}

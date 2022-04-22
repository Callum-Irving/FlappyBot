class Bird {
  NeuralNet brain;
  float x ; // This stays constant
  float y;
  float vel = 0.0;
  float jumpStrength = 10.0;
  int fitness = 0;

  public Bird(float x) {
    this.x = x;
    this.y = height / 2;
    // Brain inputs:
    // 1. y position
    // 2. y velocity
    // 3. vertical distance to top of nearest pipe
    // 4. vertical distance to botton of nearest pipe
    // 5. horizontal distance to start of nearest pipe
    this.brain = new NeuralNet(5, 5, 1);
  }

  public void update(Pipe nearestPipe) {
    float[] inputs = new float[5];
    inputs[0] = this.y;
    inputs[1] = this.vel;
    inputs[2] = nearestPipe.openingStart - this.y;
    inputs[3] = nearestPipe.openingEnd - this.y;
    inputs[4] = nearestPipe.x - this.x;
    boolean move = this.brain.predict(inputs)[0] > 0.5;
    if (move) this.vel -= this.jumpStrength;
    this.vel += GRAVITY;
    this.y += this.vel;
  }

  public void show() {
    stroke(255);
    fill(240, 240, 240, 200);
    circle(this.x, this.y, 20);
  }

  public void reset() {
    this.vel = 0;
    this.y = height / 2;
    this.fitness = 0;
  }

  // Genetic algoirthm related functions:

  private Bird(float x, NeuralNet brain) {
    this.x = x;
    this.y = height / 2;
    this.brain = brain;
  }

  public Bird clone() {
    Bird clone = new Bird(this.x, this.brain.clone());
    return clone;
  }

  public void mutateSelf(float sd) {
    this.brain.mutate(sd);
  }
}

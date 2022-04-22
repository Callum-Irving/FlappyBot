import java.util.ArrayDeque;
import java.util.Collections;

class Population {
  ArrayList<Bird> population;
  ArrayDeque<Pipe> pipes;
  int size;
  public int generation = 0;

  private ArrayList<Bird> deadBirds;

  public Population(int size) {
    this.size = size;
    this.population = new ArrayList<Bird>(size);
    this.deadBirds = new ArrayList<Bird>(size);
    for (int i = 0; i < size; i++)
      this.population.add(new Bird(BIRD_X));

    this.pipes = new ArrayDeque<Pipe>();
    this.pipes.add(new Pipe(width, PIPE_WIDTH, PIPE_OPENING_SIZE));
  }

  public void update() {
    for (Bird b : this.population)
      b.show();
    for (Pipe p : this.pipes)
      p.show();

    for (int step = 0; step < stepsPerFrame; step++) {

      // Draw current generation.
      text(this.generation, 10, 20);

      // Remove pipes that are out of bounds.
      Pipe firstPipe = this.pipes.getFirst();
      if (firstPipe.x + firstPipe.width < 0) {
        this.pipes.removeFirst();
      }

      // Add new pipes when required.
      Pipe lastPipe = this.pipes.getLast();
      if (lastPipe.x + lastPipe.width + PIPE_SPACING < width) {
        this.pipes.add(new Pipe(width, PIPE_WIDTH, PIPE_OPENING_SIZE));
      }

      // Find nearest pipe.
      Pipe nearestPipe = null;
      for (Pipe p : this.pipes) {
        if (!(p.x + p.width < BIRD_X - BIRD_RADIUS)) {
          nearestPipe = p;
          break;
        }
      }

      // Update all the birds.
      for (int i = this.population.size() - 1; i >= 0; i--) {
        Bird b = this.population.get(i);
        b.update(nearestPipe);
        //b.show();

        // Check if dead.
        if (this.birdIsDead(b, nearestPipe)) {
          this.deadBirds.add(b);
          this.population.remove(i);
        } else {
          b.fitness++;
        }
      }

      // Draw then move all pipes.
      for (Pipe p : this.pipes) {
        //p.show();
        p.x -= PIPE_SPEED;
      }

      // Evolve if all the birds in the current generation have died.
      if (this.population.size() == 0) {
        this.evolve();
      }
    }
  }

  private void evolve() {
    println("Generation", this.generation, "summary:");
    println("Best fitness:", this.deadBirds.get(this.size - 1).fitness);
    println("Median fitness:", this.deadBirds.get(this.size / 2).fitness);

    // Save the best bird (elitism). Deadbirds is already sorted by fitness.
    Bird best = this.deadBirds.get(this.size -1);
    best.reset();
    this.population.add(best);

    // Create new birds through roulette wheel selection.

    float fitnessSum = 0.0;
    for (Bird b : this.deadBirds) fitnessSum += b.fitness;

    for (int i = 0; i < this.size - 1; i++) {
      float rollingSum = 0.0;
      float chance = random(fitnessSum);
      for (Bird b : this.deadBirds) {
        rollingSum += b.fitness;
        if (rollingSum >= chance) {
          Bird child = b.clone();
          child.mutateSelf(MUT_RATE);
          this.population.add(child);
          break;
        }
      }
    }

    this.deadBirds.clear();

    // Reset pipes.
    this.pipes.clear();
    this.pipes.add(new Pipe(width, PIPE_WIDTH, PIPE_OPENING_SIZE));

    this.generation++;
  }

  // Use tournament selection to return a bird from deadBirds.
  private Bird tournamentSelect(int k) {
    Bird[] candidates = new Bird[k];

    // Get candidates randomly.
    for (int i = 0; i < k; i++) {
      int index = (int)random(this.deadBirds.size());
      candidates[i] = this.deadBirds.get(index);
    }

    // Find best.
    int best = 0;
    for (int i = 1; i < k; i++) {
      if (candidates[i].fitness > candidates[best].fitness) {
        best = i;
      }
    }

    return candidates[best];
  }

  private boolean birdIsDead(Bird b, Pipe nearestPipe) {
    // Check if bird is out of bounds.
    if (b.y - BIRD_RADIUS < 0 || b.y + BIRD_RADIUS > height) return true;

    // Check if bird collides with pipe.
    if (nearestPipe.collidesWith(b)) return true;

    return false;
  }
}

import java.util.Arrays;

import org.ejml.dense.row.mult.MatrixVectorMult_FDRM;
import org.ejml.data.FMatrix1Row;
import org.ejml.data.FMatrixRMaj;
import org.ejml.dense.row.CommonOps_FDRM;
import org.ejml.ops.FOperatorUnary;

class Gaussian implements FOperatorUnary {
  float apply(float f) {
    return randomGaussian() * f;
  }
}

class ReLU implements FOperatorUnary {
  float apply(float x) {
    return max(0, x);
  }
}

class Sigmoid implements FOperatorUnary {
  float apply(float x) {
    return (float)(1/( 1 + Math.pow(Math.E, (-1*x))));
  }
}

class NeuralNet {
  private int[] size;
  private FMatrixRMaj[] weights;
  private FMatrixRMaj[] biases;

  public NeuralNet(int ... layerSizes) {
    assert((layerSizes.length < 2 || Arrays.asList(layerSizes).contains(0)) == false);

    this.size = layerSizes;
    this.weights = new FMatrixRMaj[layerSizes.length - 1];
    this.biases = new FMatrixRMaj[layerSizes.length - 1];

    for (int i = 0; i < this.weights.length; i++) {
      this.weights[i] = new FMatrixRMaj(this.size[i + 1], this.size[i]);
      this.biases[i] = new FMatrixRMaj(this.size[i + 1], 1);
    }

    this.initWeights();
  }

  private void initWeights() {
    // Initialize hidden layers using He initialization.
    for (int i = 0; i < this.weights.length - 1; i++) {
      float sd = sqrt(2.0f / (this.size[i] + 1));
      this.weights[i].fill(sd);
      this.biases[i].fill(sd);
      CommonOps_FDRM.apply(this.weights[i], new Gaussian(), this.weights[i]);
      CommonOps_FDRM.apply(this.biases[i], new Gaussian(), this.biases[i]);
    }

    // Initialize output layer using Xavier initialization.
    int i = this.weights.length - 1;
    float sd = sqrt(1.0f / (this.size[i] + 1));
    this.weights[i].fill(sd);
    this.biases[i].fill(sd);
    CommonOps_FDRM.apply(this.weights[i], new Gaussian(), this.weights[i]);
    CommonOps_FDRM.apply(this.biases[i], new Gaussian(), this.biases[i]);
  }

  // Do feedforward computation to get output given inputs.
  public float[] predict(float[] inputs) {
    FMatrixRMaj z1 = new FMatrixRMaj(inputs);
    FMatrixRMaj z2;

    // Do hidden layers.
    for (int i = 0; i < this.weights.length - 1; i++) {
      z2 = new FMatrixRMaj(this.size[i], 1);
      MatrixVectorMult_FDRM.mult(this.weights[i], z1, z2);
      CommonOps_FDRM.addEquals(z2, this.biases[i]);
      CommonOps_FDRM.apply(z2, new ReLU(), z2);
      z1 = z2;
    }

    // Do sigmoid activiation on the final layer.
    int i = this.weights.length - 1;
    z2 = new FMatrixRMaj(this.size[i], 1);
    MatrixVectorMult_FDRM.mult(this.weights[i], z1, z2);
    CommonOps_FDRM.addEquals(z2, this.biases[i]);
    CommonOps_FDRM.apply(z2, new Sigmoid(), z2);

    return z2.getData();
  }

  private NeuralNet() {
  }

  public NeuralNet clone() {
    NeuralNet copy = new NeuralNet();
    copy.size = this.size.clone();

    // Copy weights and biases
    copy.weights = new FMatrixRMaj[this.size.length - 1];
    copy.biases = new FMatrixRMaj[this.size.length - 1];
    for (int i = 0; i < this.weights.length; i++) {
      copy.weights[i] = this.weights[i].copy();
      copy.biases[i] = this.biases[i].copy();
    }

    return copy;
  }

  // Mutate all the weights using a normal distribution with standard deviation sd.
  public void mutate(float sd) {
    for (int i = 0; i < this.weights.length; i++) {
      FMatrixRMaj weightMut = this.weights[i].createLike();
      weightMut.fill(sd);
      CommonOps_FDRM.apply(weightMut, new Gaussian(), weightMut);
      CommonOps_FDRM.addEquals(this.weights[i], weightMut);

      FMatrixRMaj biasMut = this.biases[i].createLike();
      biasMut.fill(sd);
      CommonOps_FDRM.apply(biasMut, new Gaussian(), biasMut);
      CommonOps_FDRM.addEquals(this.biases[i], biasMut);
    }
  }
}

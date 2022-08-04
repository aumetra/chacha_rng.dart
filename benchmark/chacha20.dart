import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:chacha_rng/chacha_rng.dart';

class ChaCha20Random extends BenchmarkBase {
  late Random _random;
  ChaCha20Random() : super('ChaCha20 Random class');

  static void main() {
    ChaCha20Random().report();
  }

  @override
  void run() {
    _random.nextInt(max: 60);
  }

  @override
  void setup() {
    _random = Random.withIntSeed(0xDEADBEEF, rounds: 20);
  }
}

void main() {
  ChaCha20Random.main();
}

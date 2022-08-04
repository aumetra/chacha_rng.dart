import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:chacha_rng/chacha_rng.dart';

class ChaCha8Random extends BenchmarkBase {
  late Random _random;
  ChaCha8Random() : super('ChaCha8 Random class');

  static void main() {
    ChaCha8Random().report();
  }

  @override
  void run() {
    _random.nextInt(max: 60);
  }

  @override
  void setup() {
    _random = Random.withIntSeed(0xDEADBEEF, rounds: 8);
  }
}

void main() {
  ChaCha8Random.main();
}

import 'dart:math';
import 'package:benchmark_harness/benchmark_harness.dart';

class StdlibRandom extends BenchmarkBase {
  late Random _random;
  StdlibRandom() : super('Stdlib Random class');

  static void main() {
    StdlibRandom().report();
  }

  @override
  void run() {
    _random.nextInt(60);
  }

  @override
  void setup() {
    _random = Random(0xDEADBEEF);
  }
}

void main() {
  StdlibRandom.main();
}

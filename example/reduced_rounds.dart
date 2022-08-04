import 'package:chacha_rng/chacha_rng.dart';

void main() {
  var random = Random.withIntSeed(0xDEADBEEF, rounds: 8);
  print(
    'Look a random number generated with 8 instead of 20 ChaCha rounds: ${random.nextInt()}',
  );
}

import 'package:chacha_rng/chacha_rng.dart';

void main() {
  var random = Random.withIntSeed(0xDEADBEEF);

  print('Look a random number: ${random.nextInt()}');
  print('Look a random number with a limit of 60: ${random.nextInt(max: 60)}');
}

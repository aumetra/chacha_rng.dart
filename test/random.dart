import 'package:chacha_rng/src/chacha_rng_base.dart';
import 'package:test/test.dart';

const seed = 0xDEADBEEF;

void main() {
  test('Number not repeated', () {
    var random = Random.withIntSeed(seed);
    var first = random.nextInt();
    var second = random.nextInt();

    expect(first == second, false, reason: 'Number repeated');
  });

  test('PRNG is deterministic', () {
    var random1 = Random.withIntSeed(seed);
    var random2 = Random.withIntSeed(seed);

    expect(random1.nextInt(), random2.nextInt());
    expect(random1.nextInt(), random2.nextInt());
  });
}

import 'dart:math' as math;
import 'dart:typed_data';
import 'package:chacha_rng/src/chacha.dart' as chacha;

/// ChaCha based PRNG.
///
/// The amount of rounds is configurable. It defaults to 20 rounds.
///
/// Note: The constructors will throw an exception if the chosen number of rounds is less than 8 or if the number is not divisible by 2.
class Random {
  final chacha.Engine _engine;
  chacha.Block _block;
  int counter = 0;

  Random._(this._block, int? rounds) : _engine = chacha.Engine(rounds ?? 20);

  /// Construct a new PRNG using an int.
  ///
  /// Note: This uses the stdlib `Random` class to generate 32 bytes to initialise the ChaCha state.
  factory Random.withIntSeed(int seed, {int? rounds}) {
    var rand = math.Random(seed);

    var actualSeed = Uint8List(chacha.keyLength);
    for (var i = 0; i < actualSeed.length; ++i) {
      actualSeed[i] = rand.nextInt(256);
    }

    return Random.withSeed(actualSeed, rounds: rounds);
  }

  /// Construct a new PRNG using a 256-bit (32 bytes) long seed.
  factory Random.withSeed(Uint8List seed, {int? rounds}) =>
      Random._(chacha.Block.fromParts(seed), rounds);

  /// Generate a new ChaCha block.
  ///
  /// This will yield 64 bytes of pseudo-random data.
  ByteData _randomData() {
    var randomBlock = _engine.blockFunction(_block);
    _block.nextBlock();
    return randomBlock.serialise().buffer.asByteData();
  }

  /// Generate a random boolean.
  bool nextBool() {
    return nextInt() % 2 == 0;
  }

  /// Generate a random double.
  ///
  /// The value is somewhere between the minimum and the maximum value.
  double nextDouble() {
    return _randomData().getFloat64(0);
  }

  /// Generate a random integer
  ///
  /// Without a maximum value, the value is somewhere between the minimum and the maximum value of the data type.
  /// With a maximum value, the value is somewhere between 0 and the maximum specified value.
  int nextInt({int? max}) {
    var result = _randomData().getInt64(0);
    if (max != null) {
      result %= max;
    }

    return result;
  }
}

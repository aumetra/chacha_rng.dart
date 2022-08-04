import 'dart:typed_data';
import 'package:chacha_rng/src/tuple.dart';

/// Size of a ChaCha block in words.
const blockSize = 16;

/// Bit width of a word the ChaCha engine operates on.
const bitWidth = 32;

/// Key length in bytes.
const keyLength = 32;

/// Nonce length in bytes.
///
/// Smaller than specified in the IETF RFC since we use the original design with a 64-bit counter.
/// Makes repeats virtually impossible.
const nonceLength = 8;

/// Bitmask to mask out a word the ChaCha engine operates on.
const wordMask = 0xFFFFFFFF;

/// Rotate the bits of an Int32x4 vector to the left by N.
///
/// Unfortunately there is no vectorised shifting support.
Int32x4 _rotateLeft(Int32x4 vector, int n) {
  var rightShiftN = bitWidth - n;

  return Int32x4(
        vector.x << n,
        vector.y << n,
        vector.z << n,
        vector.w << n,
      ) |
      Int32x4(
        vector.x.toUnsigned(bitWidth) >> rightShiftN,
        vector.y.toUnsigned(bitWidth) >> rightShiftN,
        vector.z.toUnsigned(bitWidth) >> rightShiftN,
        vector.w.toUnsigned(bitWidth) >> rightShiftN,
      );
}

/// Block used by ChaCha.
class Block {
  final Uint32List state;
  bool limitReached = false;

  Block(this.state) {
    if (state.length != blockSize) throw ArgumentError('Invalid state size');
  }

  /// Construct a ChaCha block from its parts:
  ///
  /// - Key
  /// - Nonce (optional; default to a bunch of zero bytes)
  /// - Counter (optional; defaults to 0)
  factory Block.fromParts(Uint8List key, {Uint8List? nonce, int counter = 0}) {
    nonce ??= Uint8List(nonceLength);
    if (key.length != keyLength) throw ArgumentError('Invalid key length');
    if (nonce.length != nonceLength) {
      throw ArgumentError('Invalid nonce length');
    }

    var state = Uint32List(blockSize);
    state[0] = 0x61707865;
    state[1] = 0x3320646e;
    state[2] = 0x79622d32;
    state[3] = 0x6b206574;

    state.buffer.asUint8List(16).setAll(0, key);

    state[12] = counter >> bitWidth;
    state[13] = counter;

    state.buffer.asUint8List(56).setAll(0, nonce);

    return Block(state);
  }

  /// Increment the block counter by 1.
  void nextBlock() {
    if ((++state[13] & wordMask) == 0) {
      if ((++state[12] & wordMask) == 0) limitReached = true;
    }
  }

  /// Serialise the state into a continous buffer of bytes.
  Uint8List serialise() {
    return Uint8List.fromList(state.buffer.asUint8List()); // Return a copy
  }
}

/// Internal SIMD-accelerated ChaCha implementation.
class Engine {
  final int rounds;

  Engine(this.rounds) {
    if (rounds < 8) throw ArgumentError('Less than 8 rounds specified');
    if (rounds % 2 != 0) throw ArgumentError('Round count not divisible by 2');
  }

  /// Run a quarter round on the values contained in the SIMD vectors.
  Tuple<Int32x4, Int32x4, Int32x4, Int32x4> quarterRound(
      Int32x4 a, Int32x4 b, Int32x4 c, Int32x4 d) {
    // Step 1
    a += b;
    d ^= a;
    d = _rotateLeft(d, 16);

    // Step 2
    c += d;
    b ^= c;
    b = _rotateLeft(b, 12);

    // Step 3
    a += b;
    d ^= a;
    d = _rotateLeft(d, 8);

    // Step 4
    c += d;
    b ^= c;
    b = _rotateLeft(b, 7);

    return Tuple(a, b, c, d);
  }

  /// Run two rounds over the provided block.
  Uint32List _twoRounds(Uint32List block) {
    var simdBlock = block.buffer.asInt32x4List();

    // First round
    var a = simdBlock[0];
    var b = simdBlock[1];
    var c = simdBlock[2];
    var d = simdBlock[3];

    var result = quarterRound(a, b, c, d);

    a = result.item1;
    b = result.item2;
    c = result.item3;
    d = result.item4;

    // Second round
    b = b.shuffle(Int32x4.yzwx);
    c = c.shuffle(Int32x4.zwxy);
    d = d.shuffle(Int32x4.wxyz);

    result = quarterRound(a, b, c, d);

    a = result.item1;
    b = result.item2;
    c = result.item3;
    d = result.item4;

    b = b.shuffle(Int32x4.wxyz);
    c = c.shuffle(Int32x4.zwxy);
    d = d.shuffle(Int32x4.yzwx);

    simdBlock.setAll(0, [a, b, c, d]);

    return block;
  }

  /// Run the ChaCha block function.
  ///
  /// Does not modify the original block.
  Block blockFunction(Block block) {
    if (block.limitReached) {
      throw StateError(
          'Block has reached its limit (how?). Refusing to reuse block');
    }

    var workingBlock = Uint32List.fromList(block.state);
    var beforeBlock = Uint32List.fromList(block.state);

    for (var i = 0; i < rounds / 2; ++i) {
      workingBlock = _twoRounds(workingBlock);
    }

    // Add the resulting block state to the previous block state
    var workingSimdBlock = workingBlock.buffer.asInt32x4List();
    var beforeSimdBlock = beforeBlock.buffer.asInt32x4List();

    for (var i = 0; i < workingSimdBlock.length; ++i) {
      workingSimdBlock[i] += beforeSimdBlock[i];
    }

    return Block(workingBlock);
  }
}

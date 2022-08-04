import 'dart:typed_data';
import 'package:chacha_rng/src/chacha.dart';
import 'package:test/test.dart';

void main() {
  group('ChaCha tests', () {
    final setupBlock = Block(
      Uint32List.fromList([
        0x61707865,
        0x3320646e,
        0x79622d32,
        0x6b206574,
        0x03020100,
        0x07060504,
        0x0b0a0908,
        0x0f0e0d0c,
        0x13121110,
        0x17161514,
        0x1b1a1918,
        0x1f1e1d1c,
        0x00000001,
        0x09000000,
        0x4a000000,
        0x00000000,
      ]),
    );
    final afterBlock = Uint32List.fromList([
      0xe4e7f110,
      0x15593bd1,
      0x1fdd0f50,
      0xc47120a3,
      0xc7f4d1c7,
      0x0368c033,
      0x9aaa2204,
      0x4e6cd4c3,
      0x466482d2,
      0x09aa9f07,
      0x05d7c214,
      0xa2028bd9,
      0xd19c12b5,
      0xb94e16de,
      0xe883d0cb,
      0x4e3c50a2,
    ]);

    test('Quarter round', () {
      var a = Int32x4(0x11111111, 0, 0, 0);
      var b = Int32x4(0x01020304, 0, 0, 0);
      var c = Int32x4(0x9b8d6f43, 0, 0, 0);
      var d = Int32x4(0x01234567, 0, 0, 0);

      var state = Engine(20);
      var result = state.quarterRound(a, b, c, d);

      expect(
        result.item1.x.toUnsigned(bitWidth),
        0xea2a92f4,
        reason: 'A mismatch',
      );
      expect(
        result.item2.x.toUnsigned(bitWidth),
        0xcb1cf8ce,
        reason: 'B mismatch',
      );
      expect(
        result.item3.x.toUnsigned(bitWidth),
        0x4581472e,
        reason: 'C mismatch',
      );
      expect(
        result.item4.x.toUnsigned(bitWidth),
        0x5881c4bb,
        reason: 'D mismatch',
      );
    });

    test('Block function', () {
      var state = Engine(20);
      var block = state.blockFunction(setupBlock);

      expect(block.state, afterBlock);
    });

    test('Block can reach a limit', () {
      var limitBlock = Block(Uint32List.fromList(setupBlock.state));
      limitBlock.state[12] = 0xFFFFFFFF;
      limitBlock.state[13] = 0xFFFFFFFF;
      limitBlock.nextBlock();

      var engine = Engine(8);
      var refusedBlock = false;
      try {
        engine.blockFunction(limitBlock);
      } catch (e) {
        refusedBlock = true;
      }

      if (!refusedBlock) throw StateError('ChaCha engine used exhaused block');
    });
  });
}

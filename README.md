# chacha_rng

PRNG based on the ChaCha stream cipher

## ⚠ Security warning

In theory a ChaCha-based PRNG is suitable for cryptographic use-cases. However the entire library (including the underlying ChaCha implementation) has not been independently audited.

USE AT YOUR OWN RISK!

## Example

```dart
var random = Random.withIntSeed(0xDEADBEEF);
print('Look a random number: ${random.nextInt()}');
print('Look a random number with a limit of 60: ${random.nextInt(max: 60)}');
```

By default `chacha_rng` will use 20 rounds of ChaCha. However, you can specify a custom amount of rounds.

```dart
var random = Random.withIntSeed(0xDEADBEEF, rounds: 8);
print('Look a random number: ${random.nextInt()}');
```

## Benchmarks

Benchmarks were run on an AMD Ryzen 5 3600X (3.8GHz base clock).  
Don't take them too seriously though, I had other stuff open. This is just to give you a rough idea about the performance.

Seeded stdlib Random class (not cryptographically secure)

```
Stdlib Random class(RunTime): 0.07820263754493406 us.
```

Seeded ChaCha Random class (8 rounds; cryptographically secure)

```
ChaCha8 Random class(RunTime): 408.81524926686217 us.
```

Seeded ChaCha Random class (20 rounds; cryptographically secure)

```
ChaCha20 Random class(RunTime): 1026.2875 us.
```

The benchmarks can be found in the `benchmark/` directory

## License

This library is licensed under the MIT license

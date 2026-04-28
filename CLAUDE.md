# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

A minimal Dart package demonstrating "fused" JSON decoding: chaining `Utf8Decoder` and `JsonDecoder` via `.fuse()` so raw `Uint8List` bytes are decoded directly to JSON without an intermediate `String`. The whole library is one function in `lib/fused_jsondecode.dart`; the rest of the repo (bin, benchmark, large.json) exists to demonstrate and measure that approach.

## Commands

```bash
dart pub get                            # install deps
dart run bin/fused_jsondecode.dart      # run the example (fetches a post and prints it)
dart run benchmark/fused_benchmark.dart # benchmark vs. utf8.decode + jsonDecode against large.json
dart test                               # run tests (test/fused_jsondecode_test.dart is currently empty)
dart test test/fused_jsondecode_test.dart -n 'name'  # run a single test by name
dart analyze                            # lint with package:lints/recommended.yaml
```

The benchmark reads `large.json` from the repo root via a relative path, so run it from the project root.

## Architecture

- `lib/fused_jsondecode.dart` — exports `jsonDecode$Fused(Uint8List bytes)`. Constructs `const Utf8Decoder().fuse(const JsonDecoder())` and calls `.convert(bytes)`. Returns `Object?`; callers pattern-match the expected shape (see `bin/`).
- `bin/fused_jsondecode.dart` — example call site. Uses `package:http`, then `if (jsonDecode$Fused(...) case final Map<String, Object?> data)` to assert shape; throws `FormatException` otherwise. Wrapped in `runZonedGuarded` for top-level error logging.
- `benchmark/fused_benchmark.dart` — independently re-implements both decode paths (does **not** import the lib) so each variant is measured in isolation. Reports ns/byte and speedup ratio. `N = 100` iterations.

Key invariant: the fused decoder must be constructed once and reused — constructing it inside a hot loop would erase the win the package is meant to demonstrate.

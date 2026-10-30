// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_llamaparse/otel_llamaparse.dart';
import 'package:test/test.dart';

void main() {
  group('otel_llamaparse', () {
    test('suppression toggles in zone', () async {
      expect(llamaParseInstrumentationSuppressed(), isFalse);
      await runWithoutLlamaParseInstrumentationAsync(() async {
        expect(llamaParseInstrumentationSuppressed(), isTrue);
      });
      expect(llamaParseInstrumentationSuppressed(), isFalse);
    });

    test('LlamaParseResult fields default null', () {
      const r = LlamaParseResult();
      expect(r.statusCode, isNull);
    });
  });
}

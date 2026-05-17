# otel_llamaparse

Dartastic OpenTelemetry bridge for LlamaParse (LLM-native PDF + doc parsing).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_llamaparse/otel_llamaparse.dart';

await tracedLlamaParse<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return LlamaParseCallResult(value: r, result: LlamaParseResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutLlamaParseInstrumentationAsync(() async {
  await client.someInternalSync();
});
```

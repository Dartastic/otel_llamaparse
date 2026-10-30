// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_llamaparse/otel_llamaparse.dart';

/// Traces Llamaparse calls with OpenTelemetry.
///
/// `otel_llamaparse` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Llamaparse call in
/// [tracedLlamaParse]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'llamaparse-example');

  // Traces a Llamaparse call.
  final llamaParseId = await tracedLlamaParse<String>(
    operation: 'create',
    invoke: () async {
      // Make the Llamaparse call here, then report what it returned.
      const id = 'llamaparse_8f3a2c';
      return const LlamaParseCallResult(
          value: id,
          result: LlamaParseResult(
              jobId: 'job_8f3a2c',
              fileName: 'example',
              fileSize: 512,
              pageCount: 3,
              parsingMode: 'example',
              language: 'en',
              resultType: 'standard',
              durationMs: 120,
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedLlamaParse create returned $llamaParseId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutLlamaParseInstrumentationAsync.
  await runWithoutLlamaParseInstrumentationAsync(
    () => tracedLlamaParse<String>(
      operation: 'create',
      invoke: () async {
        const id = 'llamaparse_8f3a2c';
        return const LlamaParseCallResult(
            value: id,
            result: LlamaParseResult(
                jobId: 'job_8f3a2c',
                fileName: 'example',
                fileSize: 512,
                pageCount: 3,
                parsingMode: 'example',
                language: 'en',
                resultType: 'standard',
                durationMs: 120,
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}

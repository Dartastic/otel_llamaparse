// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_llamaparse_suppression.dart';

class LlamaParseResult {
  /// Creates a result.
  const LlamaParseResult({
    this.jobId,
    this.fileName,
    this.fileSize,
    this.pageCount,
    this.parsingMode,
    this.language,
    this.resultType,
    this.durationMs,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? jobId;
  final String? fileName;
  final int? fileSize;
  final int? pageCount;
  final String? parsingMode;
  final String? language;
  final String? resultType;
  final int? durationMs;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class LlamaParseCallResult<T> {
  /// Creates a call result.
  const LlamaParseCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final LlamaParseResult? result;
}

Future<T> tracedLlamaParse<T>({
  required String operation,
  required Future<LlamaParseCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (llamaParseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_llamaparse');
  final span = t.startSpan('llamaparse $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('rpc.system', 'llamaparse')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('gen_ai.system', 'llamaparse')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('llamaparse.job.id', res.jobId!)]));
      }
      if (res.fileName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('file.name', res.fileName!)]));
      }
      if (res.fileSize != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('file.size', res.fileSize!)]));
      }
      if (res.pageCount != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('llamaparse.page_count', res.pageCount!)]));
      }
      if (res.parsingMode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('llamaparse.parsing_mode', res.parsingMode!)
        ]));
      }
      if (res.language != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('llamaparse.language', res.language!)]));
      }
      if (res.resultType != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('llamaparse.result_type', res.resultType!)
        ]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeInt('llamaparse.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('llamaparse.error.code', res.errorCode!)
        ]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'llamaparse.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}

// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_llamaparse_suppression.dart';

class LlamaParseResult {
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

class LlamaParseCallResult<T> {
  const LlamaParseCallResult({required this.value, this.result});
  final T value;
  final LlamaParseResult? result;
}

Future<T> tracedLlamaParse<T>({
  required String operation,
  required Future<LlamaParseCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (llamaParseInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_llamaparse');
  final span = t.startSpan('llamaparse $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('rpc.system', 'llamaparse')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('gen_ai.system', 'llamaparse')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.jobId != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('llamaparse.job.id', res.jobId!)]));
      }
      if (res.fileName != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('file.name', res.fileName!)]));
      }
      if (res.fileSize != null) {
        span.addAttributes(
            OTel.attributes([OTel.attributeInt('file.size', res.fileSize!)]));
      }
      if (res.pageCount != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('llamaparse.page_count', res.pageCount!)]));
      }
      if (res.parsingMode != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString('llamaparse.parsing_mode', res.parsingMode!)
        ]));
      }
      if (res.language != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('llamaparse.language', res.language!)]));
      }
      if (res.resultType != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('llamaparse.result_type', res.resultType!)]));
      }
      if (res.durationMs != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('llamaparse.duration', res.durationMs!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('llamaparse.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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

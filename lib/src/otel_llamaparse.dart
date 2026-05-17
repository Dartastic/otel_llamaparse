// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

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
    span.setStringAttribute('rpc.system', 'llamaparse');
    span.setStringAttribute('gen_ai.system', 'llamaparse');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.jobId != null) {
        span.setStringAttribute('llamaparse.job.id', res.jobId!);
      }
      if (res.fileName != null) {
        span.setStringAttribute('file.name', res.fileName!);
      }
      if (res.fileSize != null) {
        span.setIntAttribute('file.size', res.fileSize!);
      }
      if (res.pageCount != null) {
        span.setIntAttribute('llamaparse.page_count', res.pageCount!);
      }
      if (res.parsingMode != null) {
        span.setStringAttribute('llamaparse.parsing_mode', res.parsingMode!);
      }
      if (res.language != null) {
        span.setStringAttribute('llamaparse.language', res.language!);
      }
      if (res.resultType != null) {
        span.setStringAttribute('llamaparse.result_type', res.resultType!);
      }
      if (res.durationMs != null) {
        span.setIntAttribute('llamaparse.duration', res.durationMs!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('llamaparse.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'llamaparse.error',
        );
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

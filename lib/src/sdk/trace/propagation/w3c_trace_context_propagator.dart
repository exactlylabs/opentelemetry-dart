// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../../api.dart' as api;
import '../../../../sdk.dart' as sdk;

class W3CTraceContextPropagator implements api.TextMapPropagator {
  static const String _traceVersion = '00';
  static const String _traceParentHeaderKey = 'traceparent';
  static const String _traceStateHeaderKey = 'tracestate';
  static const String _traceVersionFieldKey = 'version';
  static const String _traceIdFieldKey = 'traceid';
  static const String _parentIdFieldKey = 'parentid';
  static const String _traceFlagsFieldKey = 'traceflags';

  // See https://www.w3.org/TR/trace-context/#traceparent-header-field-values
  // for trace parent header specification.
  static final RegExp traceParentHeaderRegEx = RegExp('^(?<$_traceVersionFieldKey>[0-9a-f]{2})-'
      '(?<$_traceIdFieldKey>[0-9a-f]{${api.TraceId.sizeBits}})-'
      '(?<$_parentIdFieldKey>[0-9a-f]{${api.SpanId.sizeBits}})-'
      '(?<$_traceFlagsFieldKey>[0-9a-f]{${2}})\$');

  @override
  api.Context extract(api.Context context, dynamic carrier, api.TextMapGetter getter) {
    final traceParentHeader = getter.get(carrier, _traceParentHeaderKey);

    if (traceParentHeader == null || !traceParentHeaderRegEx.hasMatch(traceParentHeader)) {
      // Encountered a malformed or unknown trace header.  Do nothing.
      return context;
    }

    final parentHeaderMatch = traceParentHeaderRegEx.firstMatch(traceParentHeader)!;
    final parentHeaderFields = Map<String, String?>.fromIterable(parentHeaderMatch.groupNames,
        key: (element) => element.toString(), value: (element) => parentHeaderMatch.namedGroup(element));

    final traceId = parentHeaderFields[_traceIdFieldKey] != null
        ? api.TraceId.fromString(parentHeaderFields[_traceIdFieldKey]!)
        : api.TraceId.invalid();
    final parentId = parentHeaderFields[_parentIdFieldKey] != null
        ? api.SpanId.fromString(parentHeaderFields[_parentIdFieldKey]!)
        : api.SpanId.invalid();
    final traceFlags = parentHeaderFields[_traceFlagsFieldKey] != null
        ? int.parse(parentHeaderFields[_traceFlagsFieldKey]!, radix: 16)
        : api.TraceFlags.none;

    final traceStateHeader = getter.get(carrier, _traceStateHeaderKey);
    final traceState = sdk.TraceState.fromString(traceStateHeader!);

    return context.withSpan(api.NonRecordingSpan(sdk.SpanContext.remote(traceId, parentId, traceFlags, traceState)));
  }

  @override
  void inject(api.Context context, dynamic carrier, api.TextMapSetter setter) {
    final spanContext = context.spanContext;

    if (spanContext == null) {
      return;
    }

    setter
      ..set(
          carrier,
          _traceParentHeaderKey,
          '$_traceVersion-${spanContext.traceId.toString()}-'
          '${spanContext.spanId.toString()}-'
          '${spanContext.traceFlags.toRadixString(16).padLeft(2, '0')}')
      ..set(carrier, _traceStateHeaderKey, spanContext.traceState.toString());
  }
}

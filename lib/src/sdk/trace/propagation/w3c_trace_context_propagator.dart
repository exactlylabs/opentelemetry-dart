import '../../../../api.dart' as api;
import '../../../api/trace/nonrecording_span.dart';
import '../span_context.dart';
import '../span_id.dart';
import '../trace_flags.dart';
import '../trace_id.dart';
import '../trace_state.dart';

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
  static final RegExp traceParentHeaderRegEx =
      RegExp('^(?<$_traceVersionFieldKey>[0-9a-f]{2})-'
          '(?<$_traceIdFieldKey>[0-9a-f]{${api.TraceId.sizeBits}})-'
          '(?<$_parentIdFieldKey>[0-9a-f]{${api.SpanId.sizeBits}})-'
          '(?<$_traceFlagsFieldKey>[0-9a-f]{${api.TraceFlags.size}})\$');

  @override
  api.Context extract(
      api.Context context, dynamic carrier, api.TextMapGetter getter) {
    final traceParentHeader = getter.get(carrier, _traceParentHeaderKey);
    if (traceParentHeader == null) {
      // Carrier did not contain a trace header.  Do nothing.
      return context;
    }
    if (!traceParentHeaderRegEx.hasMatch(traceParentHeader)) {
      // Encountered a malformed or unknown trace header.  Do nothing.
      return context;
    }

    final parentHeaderMatch =
        traceParentHeaderRegEx.firstMatch(traceParentHeader);
    final parentHeaderFields = Map<String, String>.fromIterable(
        parentHeaderMatch.groupNames,
        key: (element) => element.toString(),
        value: (element) => parentHeaderMatch.namedGroup(element));

    final traceId = TraceId.fromString(parentHeaderFields[_traceIdFieldKey]) ??
        TraceId(api.TraceId.invalid);
    final parentId = SpanId.fromString(parentHeaderFields[_parentIdFieldKey]) ??
        SpanId(api.SpanId.invalid);
    final traceFlags =
        TraceFlags.fromString(parentHeaderFields[_traceFlagsFieldKey]) ??
            TraceFlags(api.TraceFlags.sampledFlag);

    final traceStateHeader = getter.get(carrier, _traceStateHeaderKey);
    final traceState = (traceStateHeader != null)
        ? TraceState.fromString(traceStateHeader)
        : TraceState.empty();

    return context.withSpan(NonRecordingSpan(
        SpanContext(traceId, parentId, traceFlags, traceState)));
  }

  @override
  void inject(api.Context context, dynamic carrier, api.TextMapSetter setter) {
    final spanContext = context.spanContext;

    setter
      ..set(carrier, _traceParentHeaderKey,
          '$_traceVersion-${spanContext.traceId.toString()}-${spanContext.spanId.toString()}-${spanContext.traceFlags.toString()}')
      ..set(carrier, _traceStateHeaderKey, spanContext.traceState.toString());
  }
}
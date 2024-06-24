// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

/// The set of canonical status codes.
enum StatusCode {
  /// The default status.
  unset,

  /// The operation contains an error.
  error,

  /// The operation has been validated by an Application developers or
  /// Operator to have completed successfully.
  ok,
}

/// A representation of the status of a Span.
class SpanStatus {
  /// Creates a new [SpanStatus] with the given [code] and [description].
  /// If no [code] is provided, [StatusCode.unset] is used.
  /// If no [description] is provided, an empty string is used.
  SpanStatus([this.code = StatusCode.unset, this.description]);

  final StatusCode code;
  final String? description;
}

// Copyright 2021-2022 Workiva.
// Licensed under the Apache License, Version 2.0. Please see https://github.com/Workiva/opentelemetry-dart/blob/master/LICENSE for more information

import '../../../api.dart';

/// A representation of a collection of metadata attached to a trace span.
class Attributes {
  Attributes() : _attributes = {};

  /// Instantiate an empty Attributes.
  Attributes.empty() : this();

  /// Retrieve the value associated with the Attribute with key [key].
  Object get(String key) {
    if (!_attributes.containsKey(key)) {
      throw ArgumentError('Attribute with key $key does not exist.');
    }
    return _attributes[key]!;
  }

  /// Check if an Attribute with key [key] exists.
  bool containsKey(String key) => _attributes.containsKey(key);

  /// Retrieve the number of Attributes in this collection.
  int get length => _attributes.length;

  /// Retrieve the keys of all Attributes in this collection.
  Iterable<String> get keys => _attributes.keys;

  /// Add an Attribute [attribute].
  /// If an Attribute with the same key already exists, it will be overwritten.
  void add(Attribute attribute) {
    _attributes[attribute.key] = attribute.value;
  }

  /// Add all Attributes in List [attributes].
  /// If an Attribute with the same key already exists, it will be overwritten.
  void addAll(List<Attribute> attributes) {
    attributes.forEach(add);
  }

  final Map<String, Object> _attributes;
}

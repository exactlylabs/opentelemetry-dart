import 'package:opentelemetry/src/experimental_sdk.dart' as sdk;
import 'package:opentelemetry/src/experimental_api.dart' as api;

class Meter implements api.Meter {
  // ignore: unused_field

  @override
  api.Counter<T> createCounter<T extends num>(String name, [String? description, String? unit]) {
    return sdk.Counter<T>();
  }
}

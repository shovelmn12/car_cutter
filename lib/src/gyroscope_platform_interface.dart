import 'package:gyroscope/src/gyroscope_data.dart';
import 'package:gyroscope/src/sample_rate.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'gyroscope_method_channel.dart';

abstract class GyroscopePlatform extends PlatformInterface {
  /// Constructs a GyroscopePlatform.
  GyroscopePlatform() : super(token: _token);

  static final Object _token = Object();

  static GyroscopePlatform _instance = MethodChannelGyroscope();

  /// The default instance of [GyroscopePlatform] to use.
  ///
  /// Defaults to [MethodChannelGyroscope].
  static GyroscopePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GyroscopePlatform] when
  /// they register themselves.
  static set instance(GyroscopePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> subscribe(
    void Function(GyroscopeData event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    SampleRate? sampleRate,
  }) {
    throw UnimplementedError('subscribe() has not been implemented.');
  }

  Future<void> unsubscribe() {
    throw UnimplementedError('unsubscribe() has not been implemented.');
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gyroscope/src/extensions.dart';

import 'gyroscope_data.dart';
import 'gyroscope_platform_interface.dart';
import 'sample_rate.dart';

/// An implementation of [GyroscopePlatform] that uses method channels.
class MethodChannelGyroscope extends GyroscopePlatform {
  StreamController<GyroscopeData>? _controller;

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('gyroscope');

  MethodChannelGyroscope() {
    methodChannel.setMethodCallHandler(_handler);
  }

  @override
  Future<void> subscribe(
    void Function(GyroscopeData event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    SampleRate? sampleRate,
  }) async {
    _controller = StreamController.broadcast();
    _controller?.stream.listen(onData, onError: onError, onDone: onDone);

    await methodChannel.invokeMethod(
      "subscribe",
      (sampleRate?.toHz() ?? 30).hzToUs(),
    );
  }

  @override
  Future<void> unsubscribe() async {
    await methodChannel.invokeMethod("unsubscribe");
    await _controller?.close();
    _controller = null;
  }

  Future<dynamic> _handler(MethodCall call) async {
    switch (call.method) {
      case "data":
        if (_controller != null) {
          final args = call.arguments;

          _controller?.sink.add(
            GyroscopeData(
              azimuth: args["azimuth"] ?? 0,
              pitch: args["pitch"] ?? 0,
              roll: args["roll"] ?? 0,
            ),
          );
        } else {
          unsubscribe();
        }
      case "error":
      // TODO:
    }
  }
}

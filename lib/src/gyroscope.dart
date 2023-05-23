import 'package:gyroscope/src/gyroscope_data.dart';
import 'package:gyroscope/src/sample_rate.dart';
import 'gyroscope_platform_interface.dart';

class Gyroscope implements GyroscopePlatform {
  @override
  Future<void> subscribe(
    void Function(GyroscopeData event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
    SampleRate? sampleRate,
  }) =>
      GyroscopePlatform.instance.subscribe(
        onData,
        onError: onError,
        onDone: onDone,
        sampleRate: sampleRate,
      );

  @override
  Future<void> unsubscribe() => GyroscopePlatform.instance.unsubscribe();
}

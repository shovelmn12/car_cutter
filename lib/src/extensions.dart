import 'utils.dart';

extension NumHzToUsExtension on num {
  double hzToUs() => hertzToMicroseconds(this);
}

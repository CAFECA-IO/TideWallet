
part of 'core.dart';

int payloadId() {
  final time = DateTime.now().microsecondsSinceEpoch;
  var rng = new Random().nextInt(10);

  return time + rng * 1000;
}

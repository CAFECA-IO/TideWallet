import 'dart:math';

String randomHex(int length) {
  const array = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 'a', 'b', 'c', 'd', 'e', 'f'];
  String hex = ''; //      var subPSKID = [];
  for (int index = 0; index < length; index++) {
    hex += array[Random().nextInt(16)]
        .toString(); //        subPSKID.add(array[i]);
  }
  return hex;
}

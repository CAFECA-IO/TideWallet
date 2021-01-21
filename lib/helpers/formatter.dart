import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

class Formatter {
  static dateTime(DateTime dateTime) {
    assert(dateTime != null, 'eee');
    return DateFormat('MMM dd,yyyy, kk:mm a').format(dateTime);
  }

  static String formaDecimal(String amount, {int decimalLength = 8}) {
    List<String> splitChunck = amount.split('.');
    if (splitChunck.length > 1) {
      if (splitChunck[1].length > decimalLength) {
        splitChunck[1] = splitChunck[1].substring(0, decimalLength);
      }
      return '${splitChunck[0]}.${splitChunck[1]}';
    }
    return Decimal.parse(amount).toString();
  }
}

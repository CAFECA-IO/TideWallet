import 'dart:typed_data';

import './extended_bip39.dart' as exbip39;
import './pbkdf2.dart';

class Mnemonic {
  static bool checkMnemonicVaildity(mnemonic) {
    bool isValid = exbip39.eXvalidateMnemonic(mnemonic.trim());
    return isValid;
  }

  /// The [payload] is [String mnemonic, Strign passphrass]
  /// return the seed
  static Uint8List mnemonicToSeed(List payload) {
    final pbkdf2 = new PBKDF2(salt: 'mnemonic${payload[1]}');
    return pbkdf2.process(payload[0]);
  }
}

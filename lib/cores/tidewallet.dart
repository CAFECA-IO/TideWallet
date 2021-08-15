import 'dart:typed_data';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:web3dart/web3dart.dart';

import '../helpers/cryptor.dart';
import '../helpers/rlp.dart' as rlp;
import '../helpers/logger.dart';

import '../models/credential.model.dart';

import 'signer.dart';
import 'user.dart';
import 'paper_wallet.dart';

class TideWallet {
  static final TideWallet _instance = TideWallet._internal();
  factory TideWallet() {
    return _instance;
  }
  TideWallet._internal();

  Wallet? _wallet;
  Wallet get wallet => this._wallet!;
  set wallet(Wallet wallet) => this._wallet = wallet;

  Uint8List _getNonce(Uint8List userIdentifierBuffer) {
    const int cafeca = 0xcafeca;
    int nonce = cafeca;
    String getString(nonce) {
      String result = hex
          .encode(Cryptor.keccak256round(
              (userIdentifierBuffer + rlp.toBuffer(nonce)),
              round: 1))
          .substring(0, 3)
          .toLowerCase();
      return result;
    }

    while (getString(nonce) != 'cfc') {
      nonce++;
    }
    return rlp.toBuffer(nonce);
  }

  String _getPassword(User user) {
    Uint8List userIdentifierBuffer = ascii.encode(user.thirdPartyId);
    Uint8List installIdBuffer = ascii.encode(user.installId);
    List<int> pwseedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
            Cryptor.keccak256round(userIdentifierBuffer, round: 1) +
                Cryptor.keccak256round(hex.decode(user.id), round: 1)) +
        Cryptor.keccak256round(Cryptor.keccak256round(
                rlp.toBuffer(
                    hex.encode(rlp.toBuffer(user.timestamp)).substring(3, 6)),
                round: 1) +
            Cryptor.keccak256round(installIdBuffer, round: 1)));
    String password = hex.encode(Cryptor.keccak256round(pwseedBuffer));
    return password;
  }

  Credential _generateCredentialData(User user) {
    Uint8List userIdentifierBuffer = ascii.encode(user.thirdPartyId);
    Uint8List nonce = _getNonce(userIdentifierBuffer);
    Log.debug('nonce: $nonce');

    Uint8List mainBuffer =
        Uint8List.fromList((userIdentifierBuffer + nonce).sublist(0, 8));
    List<int> extendBuffer =
        Cryptor.keccak256round(nonce, round: 1).sublist(0, 4);
    List<int> seedBuffer = Cryptor.keccak256round(Cryptor.keccak256round(
            Cryptor.keccak256round(mainBuffer, round: 1) +
                Cryptor.keccak256round(extendBuffer, round: 1)) +
        Cryptor.keccak256round(
            Cryptor.keccak256round(hex.decode(user.id), round: 1) +
                Cryptor.keccak256round(hex.decode(user.userSecret), round: 1)));
    String key = hex.encode(Cryptor.keccak256round(seedBuffer));
    String password = _getPassword(user);
    String extend = hex.encode(extendBuffer);

    return Credential(key: key, password: password, extend: extend);
  }

  Wallet createWallet(User user) {
    Credential credential = this._generateCredentialData(user);
    Wallet wallet = PaperWallet.createWallet(credential);
    this.wallet = wallet;
    return this.wallet;
  }

  Wallet createWalletWithSeed(User user) {
    Credential credential = this._generateCredentialData(user);
    credential = credential.copyWith(key: hex.encode(user.seed));
    Wallet wallet = PaperWallet.createWallet(credential);
    this.wallet = wallet;
    return this.wallet;
  }

  Wallet restoreWallet(Map<String, String> decode) {
    Wallet wallet =
        PaperWallet.jsonToWallet(decode['keystore']!, decode['password']!);
    this.wallet = wallet;
    return this.wallet;
  }

  String keystore(Wallet? wallet) {
    String keystore = PaperWallet.walletToJson(wallet ?? this.wallet);
    return keystore;
  }

  String extendedPublicKey(Wallet? wallet) {
    String extPubK =
        PaperWallet.getExtendedPublicKey(wallet: wallet ?? this.wallet);
    return extPubK;
  }

  Uint8List getPubKey(
      {Wallet? wallet, required int changeIndex, required int keyIndex}) {
    Uint8List key =
        PaperWallet.getPubKey(wallet ?? this.wallet, changeIndex, keyIndex);
    return key;
  }

  MsgSignature sign(
      {Wallet? wallet,
      required Uint8List data,
      required int changeIndex,
      required int keyIndex}) {
    Uint8List key =
        PaperWallet.getPrivKey(wallet ?? this.wallet, changeIndex, keyIndex);
    MsgSignature signature = Signer().sign(data, key);
    return signature;
  }
}

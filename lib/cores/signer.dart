import 'dart:typed_data';
import "package:pointycastle/ecc/curves/secp256k1.dart";
import 'package:pointycastle/ecc/api.dart'
    show ECPrivateKey, ECPublicKey, ECSignature, ECPoint;
import 'package:pointycastle/export.dart';
import 'package:convert/convert.dart';

import '../helpers/logger.dart';
import '../helpers/utils.dart';

final ZERO32 = Uint8List.fromList(List.generate(32, (index) => 0));
final EC_GROUP_ORDER = hex
    .decode("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141");
final EC_P = hex
    .decode("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f");
final secp256k1 = new ECCurve_secp256k1();
final n = secp256k1.n;
final G = secp256k1.G;
BigInt nDiv2 = n >> 1;
const THROW_BAD_PRIVATE = 'Expected Private';
const THROW_BAD_POINT = 'Expected Point';
const THROW_BAD_TWEAK = 'Expected Tweak';
const THROW_BAD_HASH = 'Expected Hash';
const THROW_BAD_SIGNATURE = 'Expected Signature';

class MsgSignature {
  final BigInt r;
  final BigInt s;
  final int v;

  MsgSignature(this.r, this.s, this.v);
}

class Signer {
  static final Signer _instance = Signer._internal();
  factory Signer() => _instance;
  Signer._internal();

  bool _isScalar(Uint8List x) {
    return x.length == 32;
  }

  int _compare(Uint8List a, Uint8List b) {
    BigInt aa = fromBuffer(a);
    BigInt bb = fromBuffer(b);
    if (aa == bb) return 0;
    if (aa > bb) return 1;
    return -1;
  }

  bool _isPrivate(Uint8List x) {
    if (!_isScalar(x)) return false;
    return _compare(x, ZERO32) > 0 && // > 0
        _compare(x, EC_GROUP_ORDER) < 0; // < G
  }

  ECSignature _deterministicGenerateK(Uint8List hash, Uint8List x) {
    final signer = new ECDSASigner(null, new HMac(new SHA256Digest(), 64));
    var pkp =
        new PrivateKeyParameter(new ECPrivateKey(decodeBigInt(x), secp256k1));
    signer.init(true, pkp);
    //  signer.init(false, new PublicKeyParameter(new ECPublicKey(secp256k1.curve.decodePoint(x), secp256k1)));
    return signer.generateSignature(hash);
  }

  /// Generates a public key for the given private key using the ecdsa curve which
  /// Ethereum uses.
  Uint8List _privateKeyToPublic(BigInt privateKey) {
    final p = secp256k1.G * privateKey;

    //skip the type flag, https://github.com/ethereumjs/ethereumjs-util/blob/master/index.js#L319
    return Uint8List.view(p.getEncoded(false).buffer, 1);
  }

  ECPoint _decompressKey(BigInt xBN, bool yBit, ECCurve c) {
    List<int> x9IntegerToBytes(BigInt s, int qLength) {
      //https://github.com/bcgit/bc-java/blob/master/core/src/main/java/org/bouncycastle/asn1/x9/X9IntegerConverter.java#L45
      final bytes = encodeBigInt(s);

      if (qLength < bytes.length) {
        return bytes.sublist(0, bytes.length - qLength);
      } else if (qLength > bytes.length) {
        final tmp = List<int>.filled(qLength, 0);

        final offset = qLength - bytes.length;
        for (var i = 0; i < bytes.length; i++) {
          tmp[i + offset] = bytes[i];
        }

        return tmp;
      }

      return bytes;
    }

    final compEnc = x9IntegerToBytes(xBN, 1 + ((c.fieldSize + 7) ~/ 8));
    compEnc[0] = yBit ? 0x03 : 0x02;
    return c.decodePoint(compEnc);
  }

  BigInt _recoverFromSignature(
      int recId, ECSignature sig, Uint8List msg, ECCurve_secp256k1 params) {
    final n = params.n;
    final i = BigInt.from(recId ~/ 2);
    final x = sig.r + (i * n);

    //Parameter q of curve
    final prime = decodeBigInt(EC_P);
    if (x.compareTo(prime) >= 0) return null;

    final R = _decompressKey(x, (recId & 1) == 1, params.curve);
    if (!(R * n).isInfinity) return null;

    final e = decodeBigInt(msg);

    final eInv = (BigInt.zero - e) % n;
    final rInv = sig.r.modInverse(n);
    final srInv = (rInv * sig.s) % n;
    final eInvrInv = (rInv * eInv) % n;

    final q = (params.G * eInvrInv) + (R * srInv);

    final bytes = q.getEncoded(false);
    return decodeBigInt(bytes.sublist(1));
  }

  Uint8List encodeSignature(Uint8List signature, int hashType) {
    if (!isUint(hashType, 8)) throw ArgumentError("Invalid hasType $hashType");
    if (signature.length != 64) throw ArgumentError("Invalid signature");
    final hashTypeMod = hashType & ~0x80;
    if (hashTypeMod <= 0 || hashTypeMod >= 4)
      throw new ArgumentError('Invalid hashType $hashType');

    final hashTypeBuffer = new Uint8List(1);
    hashTypeBuffer.buffer.asByteData().setUint8(0, hashType);
    final r = toDER(signature.sublist(0, 32));
    final s = toDER(signature.sublist(32, 64));
    List<int> combine = List.from(bip66encode(r, s));
    combine.addAll(List.from(hashTypeBuffer));
    return Uint8List.fromList(combine);
  }

  MsgSignature sign(Uint8List hash, Uint8List x) {
    if (!_isScalar(hash)) throw new ArgumentError(THROW_BAD_HASH);
    if (!_isPrivate(x)) throw new ArgumentError(THROW_BAD_PRIVATE);
    ECSignature sig = _deterministicGenerateK(hash, x);
    // Uint8List buffer = new Uint8List(64);
    // buffer.setRange(0, 32, encodeBigInt(sig.r));
    /*
	This is necessary because if a message can be signed by (r, s), it can also
	be signed by (r, -s (mod N)) which N being the order of the elliptic function
	used. In order to ensure transactions can't be tampered with (even though it
	would be harmless), Ethereum only accepts the signature with the lower value
	of s to make the signature for the message unique.
	More details at
	https://github.com/web3j/web3j/blob/master/crypto/src/main/java/org/web3j/crypto/ECDSASignature.java#L27
	 */
    if (sig.s.compareTo(secp256k1.n >> 1) > 0) {
      final canonicalisedS = secp256k1.n - sig.s;
      sig = ECSignature(sig.r, canonicalisedS);
    }
    Log.debug('sig s: ${sig.s}');
    Log.debug('sig r: ${sig.r}');

    // buffer.setRange(32, 64, encodeBigInt(s));

    //https://github.com/web3j/web3j/blob/master/crypto/src/main/java/org/web3j/crypto/Sign.java
    final publicKey = decodeBigInt(_privateKeyToPublic(decodeBigInt(x)));
    Log.debug('publicKey: $publicKey');

    var recId = -1;
    for (var i = 0; i < 4; i++) {
      final k = _recoverFromSignature(i, sig, hash, secp256k1);
      Log.debug('k: $k');
      if (k == publicKey) {
        recId = i;
        Log.debug('recId: $recId');
        break;
      }
    }

    if (recId == -1) {
      throw Exception(
          'Could not construct a recoverable key. This should never happen');
    }
    return MsgSignature(sig.r, sig.s, recId + 27);
  }
}

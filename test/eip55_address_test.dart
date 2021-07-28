import 'package:tidewallet3/helpers/ethereum_based_utils.dart';
import 'package:tidewallet3/helpers/logger.dart';

main() {
  String address = "0x88e3bBD42b8ea3623dD10A324A3587eC29480dad";

  Log.debug(verifyEthereumAddress(address));
}

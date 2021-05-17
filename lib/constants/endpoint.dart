import 'package:package_info/package_info.dart';

class Endpoint {
  static String env = 'production';
  static const String _SUSANOO = 'https://service.tidewallet.io';
  static const String _AMATERASU = 'https://staging.tidewallet.io';
  static const String _version = '/api/v1';

  static const String SUSANOO = _SUSANOO + _version;
  static const String AMATERASU = _AMATERASU + _version;

  static const EMAIL = 'info@tidewallet.io';

  static init() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    switch (info.packageName) {
      case 'com.tideisun.tidewallet3':
        Endpoint.env = 'production';
        break;
      case 'com.tideisun.tidewallet3.dev':
        Endpoint.env = 'development';
        break;
      default:
    }
  }

  static String url = Endpoint.env == 'production' ? SUSANOO : AMATERASU;
}

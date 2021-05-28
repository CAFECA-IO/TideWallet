import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidewallet3/models/auth.model.dart';
import 'package:uuid/uuid.dart';

class PrefManager {
  static const String INSTALL_ID_KEY = "installation_id";
  static const String AUTH_ITEM_KEY = 'auth_item';
  static const String SELECTED_FIAT_KEY = 'selected_fiat';
  static const String SELECTED_DISPLAY = 'selected_display';

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.reload();
  }

  /// Installation ID
  Future<void> setInstallationId(String installationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(INSTALL_ID_KEY, installationId);
  }

  Future<String> getInstallationId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String installationId;
    installationId = pref.getString(INSTALL_ID_KEY) ?? null;

    if (installationId == null) {
      installationId = Uuid().v4();
      setInstallationId(installationId);
    }
    return installationId;
  }

  Future<String> reCreateInstallationId() async {
    await setInstallationId(null);
    return await getInstallationId();
  }

  Future<void> setAuthItem(AuthItem authItem) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(AUTH_ITEM_KEY, json.encode(authItem.toJson()));
  }

  Future<AuthItem> getAuthItem() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String authItemString = pref.getString(AUTH_ITEM_KEY) ?? null;

    if (authItemString == null) {
      return null;
    }
    AuthItem tokenItem = AuthItem.fromJson(json.decode(authItemString));
    return tokenItem;
  }

  Future<void> setSelectedFiat(String symbol) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SELECTED_FIAT_KEY, symbol);
  }

  Future<String> getSeletedFiat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String selected = prefs.getString(SELECTED_FIAT_KEY) ?? null;

    return selected;
  }

  Future<Map> setSelectedDisplay(
      String accountId, String currencyId, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String selected = prefs.getString(SELECTED_DISPLAY) ?? '{}';
    Map _map = json.decode(selected);

    _map[currencyId] = value;
    prefs.setString(SELECTED_DISPLAY, json.encode(_map));

    return _map;
  }

  Future<Map> getSeletedDisplay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String selected = prefs.getString(SELECTED_DISPLAY) ?? null;
    return selected != null ? json.decode(selected) : null;
  }

  // TODO: Set Notification
  // TODO: Set language
}

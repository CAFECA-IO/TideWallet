import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tidewallet3/models/auth.model.dart';
import 'package:uuid/uuid.dart';

class PrefManager {
  static const String INSTALL_ID_KEY = "installation_id";
  static const String AUTH_ITEM_KEY = 'auth_item';
  static const String SELECTED_FIAT_KEY = 'selected_fiat';
  static const String SELECTED_DISPLAY = 'selected_display';
  static const String DEBUG_MODE = 'debug_mode';

  Future<void> clearAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.reload();
  }

  /// Installation ID
  Future<void> setInstallationId(String? installationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (installationId != null)
      prefs.setString(INSTALL_ID_KEY, installationId);
    else
      prefs.remove(INSTALL_ID_KEY);
  }

  Future<String> getInstallationId() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? installationId;
    installationId = pref.getString(INSTALL_ID_KEY);

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

  Future<AuthItem?> getAuthItem() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? authItemString = pref.getString(AUTH_ITEM_KEY);

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

  Future<String?> getSeletedFiat() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selected = prefs.getString(SELECTED_FIAT_KEY);

    return selected;
  }

  Future<void> setDebugMode(bool mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(DEBUG_MODE, mode);
  }

  Future<bool> getDebugMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool selected = prefs.getBool(DEBUG_MODE) ?? false;

    return selected;
  }

  Future<Map<String, bool>> setSelectedDisplay(
      String accountId, String currencyId, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String selected = prefs.getString(SELECTED_DISPLAY) ?? '{}';
    Map<String, bool> _map = json.decode(selected);

    _map[currencyId] = value;
    prefs.setString(SELECTED_DISPLAY, json.encode(_map));

    return _map;
  }

  Future<Map?> getSeletedDisplayToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selected = prefs.getString(SELECTED_DISPLAY);
    return selected != null ? json.decode(selected) : null;
  }

  // TODO: Set Notification
  // TODO: Set language
}

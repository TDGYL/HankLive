import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hank_user_model.dart';
import 'hank_network_manager.dart';

/// HankAuthManager: useaccountLoginstate management class（singleton）
/// Lmanages Token cache、useaccountinfocache、Loginstatuscheck、request header sync
/// useuse SharedPreferences dolocalpersistence
class HankAuthManager {
  /// singleton instance
  static final HankAuthManager _instance = HankAuthManager._internal();

  /// factoryconstructor，Backsingleton
  factory HankAuthManager() => _instance;

  /// private constructor
  HankAuthManager._internal();

  /// TokencacheKey
  static const String _kTokenKey = 'hank_user_token';

  /// useaccountinfocacheKey
  static const String _kUserInfoKey = 'hank_user_info';

  /// in memoryToken - String?type，Logincache，Exitaftersetnull
  String? _token;

  /// user info in memory - HankUserModel?type，Logincache，Exitaftersetnull
  HankUserModel? _currentUser;

  /// getwhenbeforeToken - String?type，notLoginwhennull
  String? get token => _token;

  /// getwhenbeforeuseaccountinfo - HankUserModel?type，notLoginwhennull
  HankUserModel? get currentUser => _currentUser;

  /// whetheralreadyLogin - booltype，tokennonemptyanduseaccountinfononemptywhentrue
  bool get isLoggedIn => _token != null && _token!.isNotEmpty && _currentUser != null;

  /// init，fromlocalcachereadgetTokenanduseaccountinfo
  /// inAppstartupwhencalluse，restoreLoginstatus
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
    final userInfoJson = prefs.getString(_kUserInfoKey);

    // restoreTokentorequestheader
    if (_token != null && _token!.isNotEmpty) {
      HankNetworkManager().setAuthToken(_token!);
    }

    // restoreuseaccountinfo
    if (userInfoJson != null && userInfoJson.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(userInfoJson);
        _currentUser = HankUserModel.fromJson(map);
      } catch (e) {
        _currentUser = null;
      }
    }
  }

  /// SaveTokentomemoryandlocal，syncSettingsrequestheader
  /// [token] - Stringtype，LoginAPIBackrefresh_token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    HankNetworkManager().setAuthToken(token);
  }

  /// Saveuseaccountinfotomemoryandlocal
  /// [user] - HankUserModeltype，useaccountinfoAPIBackData
  Future<void> saveUserInfo(HankUserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_kUserInfoKey, jsonString);
  }

  /// ExitLogin，clear memory and localTokenanduseaccountinfo，removerequestheader
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserInfoKey);
    HankNetworkManager().clearAuthToken();
  }
}

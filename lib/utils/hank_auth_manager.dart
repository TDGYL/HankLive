import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hank_user_model.dart';
import 'hank_network_manager.dart';

/// HankAuthManager: 用户登录状态管理类（单例）
/// 负责管理 Token 缓存、用户信息缓存、登录状态判断、请求头同步
/// 使用 SharedPreferences 做本地持久化
class HankAuthManager {
  /// 单例实例
  static final HankAuthManager _instance = HankAuthManager._internal();

  /// 工厂构造，返回单例
  factory HankAuthManager() => _instance;

  /// 私有构造
  HankAuthManager._internal();

  /// Token缓存Key
  static const String _kTokenKey = 'hank_user_token';

  /// 用户信息缓存Key
  static const String _kUserInfoKey = 'hank_user_info';

  /// 内存中的Token - String?类型，登录后缓存，退出后置null
  String? _token;

  /// 内存中的用户信息 - HankUserModel?类型，登录后缓存，退出后置null
  HankUserModel? _currentUser;

  /// 获取当前Token - String?类型，未登录时为null
  String? get token => _token;

  /// 获取当前用户信息 - HankUserModel?类型，未登录时为null
  HankUserModel? get currentUser => _currentUser;

  /// 是否已登录 - bool类型，token非空且用户信息非空时为true
  bool get isLoggedIn => _token != null && _token!.isNotEmpty && _currentUser != null;

  /// 初始化，从本地缓存读取Token和用户信息
  /// 在App启动时调用，恢复登录状态
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
    final userInfoJson = prefs.getString(_kUserInfoKey);

    // 恢复Token到请求头
    if (_token != null && _token!.isNotEmpty) {
      HankNetworkManager().setAuthToken(_token!);
    }

    // 恢复用户信息
    if (userInfoJson != null && userInfoJson.isNotEmpty) {
      try {
        final Map<String, dynamic> map = jsonDecode(userInfoJson);
        _currentUser = HankUserModel.fromJson(map);
      } catch (e) {
        _currentUser = null;
      }
    }
  }

  /// 保存Token到内存和本地，同步设置请求头
  /// [token] - String类型，登录接口返回的refresh_token
  Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    HankNetworkManager().setAuthToken(token);
  }

  /// 保存用户信息到内存和本地
  /// [user] - HankUserModel类型，用户信息接口返回的数据
  Future<void> saveUserInfo(HankUserModel user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(user.toJson());
    await prefs.setString(_kUserInfoKey, jsonString);
  }

  /// 退出登录，清除内存和本地的Token和用户信息，移除请求头
  Future<void> logout() async {
    _token = null;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kUserInfoKey);
    HankNetworkManager().clearAuthToken();
  }
}

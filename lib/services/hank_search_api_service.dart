import '../utils/hank_network_manager.dart';
import '../models/hank_search_model.dart';

/// HankSearchApiService: 搜索接口服务
/// 封装 /api/livespeed/index/search 和 /api/livespeed/index/search/match/hot 接口
class HankSearchApiService {
  /// 单例实例
  static final HankSearchApiService _instance = HankSearchApiService._internal();

  /// 工厂构造，返回单例
  factory HankSearchApiService() {
    return _instance;
  }

  /// 私有构造
  HankSearchApiService._internal();

  /// 请求搜索结果
  /// 接口：GET /api/livespeed/index/search
  /// 参数：text - 搜索关键词
  /// 返回：HankSearchResult 包含比赛和用户搜索结果
  Future<HankSearchResult?> fetchSearchResults({
    required String text,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/index/search',
      queryParameters: {'text': text},
    );

    if (response.isSuccess && response.data != null) {
      return HankSearchResult.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求热门比赛列表
  /// 接口：GET /api/livespeed/index/search/match/hot
  /// 返回：List<HankSearchMatch> 热门比赛列表
  Future<List<HankSearchMatch>> fetchHotMatches() async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/index/search/match/hot',
    );

    if (response.isSuccess) {
      List<dynamic> rawData = [];
      if (response.data is List) {
        rawData = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic> &&
          response.data['data'] is List) {
        rawData = response.data['data'] as List<dynamic>;
      }

      return rawData
          .map((json) => HankSearchMatch.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}

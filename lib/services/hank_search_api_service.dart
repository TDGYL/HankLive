import '../utils/hank_network_manager.dart';
import '../models/hank_search_model.dart';

/// HankSearchApiService: SearchAPI service
/// wrap /api/livespeed/index/search and /api/livespeed/index/search/match/hot API
class HankSearchApiService {
  /// singleton instance
  static final HankSearchApiService _instance = HankSearchApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankSearchApiService() {
    return _instance;
  }

  /// private constructor
  HankSearchApiService._internal();

  /// requestSearchresults
  /// API：GET /api/livespeed/index/search
  /// paramcount：text - Searchkeyword
  /// Back：HankSearchResult containsmatchanduseaccountSearchresults
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

  /// requestTrendingmatchlist
  /// API：GET /api/livespeed/index/search/match/hot
  /// Back：List<HankSearchMatch> Trendingmatchlist
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

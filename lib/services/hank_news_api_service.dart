import '../utils/hank_network_manager.dart';
import '../models/hank_news_api_model.dart';
import '../models/news_model.dart';

/// HankNewsApiService: newslistAPI service
/// wrap /api/livespeed/info/list GET request
/// BackDatapasspass HankNewsItem → NewsModel convertfor UI useuse
class HankNewsApiService {
  /// singleton instance
  static final HankNewsApiService _instance = HankNewsApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankNewsApiService() {
    return _instance;
  }

  /// private constructor
  HankNewsApiService._internal();

  /// APIpath
  static const String _apiPath = '/api/livespeed/info/list';

  /// requestnewslist
  /// [page] - categorypagepagecode（from1start）
  /// [size] - eachpageitemcount
  /// [type] - articletype，default1
  /// Back：HankNewsData rawresponseData
  Future<HankNewsData?> fetchNewsList({
    int page = 1,
    int size = 10,
    int type = 1,
  }) async {
    final params = <String, dynamic>{
      'type': type,
      'page': page,
      'size': size,
    };

    final response = await HankNetworkManager().getRequest(
      _apiPath,
      queryParameters: params,
    );

    if (response.isSuccess && response.data != null) {
      return HankNewsData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// requestnewslistandconvert to NewsModel list
  /// paramcountsame [fetchNewsList]
  /// Back：List<NewsModel>，for UI componentdirectlyuseuse
  Future<List<NewsModel>> fetchNewsModels({
    int page = 1,
    int size = 10,
    int type = 1,
  }) async {
    final data = await fetchNewsList(
      page: page,
      size: size,
      type: type,
    );

    if (data == null || data.results.isEmpty) {
      return [];
    }

    return data.results.map((item) => _convertToNewsModel(item)).toList();
  }

  /// convert APImodel HankNewsItem convert to UI model NewsModel
  /// [item] - APIBacksinglenewsData
  /// Back：NewsModel
  NewsModel _convertToNewsModel(HankNewsItem item) {
    return NewsModel(
      newsId: item.id?.toString() ?? '',
      type: NewsType.feature,
      title: item.title ?? '',
      coverImageUrl: item.cover,
      thumbnailUrl: item.cover,
      categoryTag: _getCategoryTag(item.type),
      categoryBgColor: 0xFF7C3AED,
      categoryTextColor: 0xFFFFFFFF,
      source: item.author ?? item.source ?? 'pitchnews flash',
      timeDesc: _formatPublishTime(item.createdAt),
      readCountDesc: _formatReadCount(item.contentCounts),
      commentCount: item.intelligenceCounts ?? 0,
    );
  }

  /// requestnewsDetails
  /// API：GET /api/livespeed/info/detail
  /// [id] - newsID
  /// Back：HankNewsItem newsDetails
  Future<HankNewsItem?> fetchNewsDetail({required int id}) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/info/detail',
      queryParameters: {'id': id},
    );

    if (response.isSuccess && response.data != null) {
      return HankNewsItem.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// rootbased onarticletypegetcategorytypetag
  /// [type] - articletypeID
  /// Back：categorytypetagtext
  String _getCategoryTag(int? type) {
    switch (type) {
      case 1:
        return 'darkdepthtactical';
      case 2:
        return 'news flash';
      case 3:
        return 'exclusive';
      default:
        return 'news';
    }
  }

  /// formatPostTimeisrelativeTimedescription
  /// [timestamp] - Timetimestamp（seconds）
  /// Back：e.g. "2underwhenbefore"、"3daybefore"
  String _formatPublishTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final now = DateTime.now();
    final publishDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = now.difference(publishDate);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}minbefore';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}underwhenbefore';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}daybefore';
    } else {
      return '${publishDate.month}-${publishDate.day}';
    }
  }

  /// formatreadingcount
  /// [count] - readingcount
  /// Back：e.g. "1.80k views"
  String _formatReadCount(int? count) {
    if (count == null || count == 0) return '';
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}0k views';
    }
    return '$count reading';
  }
}

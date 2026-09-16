import '../utils/hank_network_manager.dart';
import '../models/hank_news_api_model.dart';
import '../models/news_model.dart';

/// HankNewsApiService: 资讯列表接口服务
/// 封装 /api/livespeed/info/list GET 请求
/// 返回数据通过 HankNewsItem → NewsModel 转换供 UI 使用
class HankNewsApiService {
  /// 单例实例
  static final HankNewsApiService _instance = HankNewsApiService._internal();

  /// 工厂构造，返回单例
  factory HankNewsApiService() {
    return _instance;
  }

  /// 私有构造
  HankNewsApiService._internal();

  /// 接口路径
  static const String _apiPath = '/api/livespeed/info/list';

  /// 请求资讯列表
  /// [page] - 分页页码（从1开始）
  /// [size] - 每页条数
  /// [type] - 文章类型，默认1
  /// 返回：HankNewsData 原始响应数据
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

  /// 请求资讯列表并转换为 NewsModel 列表
  /// 参数同 [fetchNewsList]
  /// 返回：List<NewsModel>，供 UI 组件直接使用
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

  /// 将接口模型 HankNewsItem 转换为 UI 模型 NewsModel
  /// [item] - 接口返回的单条资讯数据
  /// 返回：NewsModel
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
      source: item.author ?? item.source ?? '绿茵快讯',
      timeDesc: _formatPublishTime(item.createdAt),
      readCountDesc: _formatReadCount(item.contentCounts),
      commentCount: item.intelligenceCounts ?? 0,
    );
  }

  /// 请求资讯详情
  /// 接口：GET /api/livespeed/info/detail
  /// [id] - 资讯ID
  /// 返回：HankNewsItem 资讯详情
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

  /// 根据文章类型获取分类标签
  /// [type] - 文章类型ID
  /// 返回：分类标签文字
  String _getCategoryTag(int? type) {
    switch (type) {
      case 1:
        return '深度战术';
      case 2:
        return '快讯';
      case 3:
        return '独家';
      default:
        return '资讯';
    }
  }

  /// 格式化发布时间为相对时间描述
  /// [timestamp] - 时间戳（秒）
  /// 返回：如 "2小时前"、"3天前"
  String _formatPublishTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final now = DateTime.now();
    final publishDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = now.difference(publishDate);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${publishDate.month}-${publishDate.day}';
    }
  }

  /// 格式化阅读量
  /// [count] - 阅读数
  /// 返回：如 "1.8万阅读"
  String _formatReadCount(int? count) {
    if (count == null || count == 0) return '';
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万阅读';
    }
    return '$count阅读';
  }
}

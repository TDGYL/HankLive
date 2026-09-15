/// NewsType: 资讯类型枚举
/// feature: 深度大图样式 | compact: 左右图文快讯样式
enum NewsType { feature, compact }

/// NewsModel: 资讯文章模型
/// 包含标题、图片、分类标签、来源、时间、阅读数等
class NewsModel {
  /// 文章唯一ID
  final String newsId;

  /// 展示类型（大图/小图）
  final NewsType type;

  /// 文章标题
  final String title;

  /// 封面大图URL（feature样式用）
  final String? coverImageUrl;

  /// 缩略图URL（compact样式用）
  final String? thumbnailUrl;

  /// 分类标签文字
  final String categoryTag;

  /// 分类标签背景颜色
  final int categoryBgColor;

  /// 分类标签文字颜色
  final int categoryTextColor;

  /// 来源/作者
  final String source;

  /// 发布时间描述（如：2小时前）
  final String timeDesc;

  /// 阅读量描述（如：1.8万阅读）
  final String readCountDesc;

  /// 评论数
  final int commentCount;

  NewsModel({
    required this.newsId,
    required this.type,
    required this.title,
    this.coverImageUrl,
    this.thumbnailUrl,
    required this.categoryTag,
    this.categoryBgColor = 0xFF7C3AED,
    this.categoryTextColor = 0xFFFFFFFF,
    required this.source,
    required this.timeDesc,
    this.readCountDesc = '',
    this.commentCount = 0,
  });

  /// 从JSON解析
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      newsId: json['newsId'] ?? '',
      type: json['type'] == 'compact' ? NewsType.compact : NewsType.feature,
      title: json['title'] ?? '',
      coverImageUrl: json['coverImageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      categoryTag: json['categoryTag'] ?? '',
      categoryBgColor: json['categoryBgColor'] ?? 0xFF7C3AED,
      categoryTextColor: json['categoryTextColor'] ?? 0xFFFFFFFF,
      source: json['source'] ?? '',
      timeDesc: json['timeDesc'] ?? '',
      readCountDesc: json['readCountDesc'] ?? '',
      commentCount: json['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'newsId': newsId,
      'type': type.name,
      'title': title,
      'coverImageUrl': coverImageUrl,
      'thumbnailUrl': thumbnailUrl,
      'categoryTag': categoryTag,
      'categoryBgColor': categoryBgColor,
      'categoryTextColor': categoryTextColor,
      'source': source,
      'timeDesc': timeDesc,
      'readCountDesc': readCountDesc,
      'commentCount': commentCount,
    };
  }
}

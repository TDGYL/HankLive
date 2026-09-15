/// HankNewsData: 资讯列表接口响应数据体
/// 包含总数和资讯项列表
class HankNewsData {
  /// 数据总数
  final int? total;

  /// 资讯项列表
  final List<HankNewsItem> results;

  HankNewsData({this.total, this.results = const []});

  /// 从JSON解析
  factory HankNewsData.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List?;
    List<HankNewsItem> items = [];
    if (list != null) {
      items = list.map((e) => HankNewsItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return HankNewsData(
      total: json['total'] as int?,
      results: items,
    );
  }
}

/// HankNewsItem: 单条资讯数据项
/// 映射接口返回的 snake_case 字段为 camelCase 属性
class HankNewsItem {
  /// 文章唯一ID
  final int? id;

  /// 文章标题
  final String? title;

  /// 封面图URL
  final String? cover;

  /// 文章类型
  final int? type;

  /// 作者
  final String? author;

  /// 作者头像URL
  final String? authorAvatar;

  /// 来源
  final String? source;

  /// 来源URL
  final String? sourceUrl;

  /// 创建时间戳（秒）
  final int? createdAt;

  /// 上线时间戳（秒）
  final int? onlineAt;

  /// 下线时间戳（秒）
  final int? offlineAt;

  /// 状态
  final int? status;

  /// 内容
  final String? content;

  /// 是否支持
  final bool? isSupport;

  /// 视频方向
  final int? videoDirection;

  /// H5页面URL
  final String? h5Url;

  /// 是否关注
  final bool? isFollow;

  /// 阅读量
  final int? contentCounts;

  /// 视频高度
  final int? videoHeight;

  /// 视频宽度
  final int? videoWidth;

  /// 是否直播中
  final bool? living;

  /// 专家ID
  final int? expertId;

  /// 补丁信息
  final String? patch;

  /// 分组ID
  final String? groupId;

  /// 权重
  final int? weight;

  /// 竖屏封面URL
  final String? verticalCoverUrl;

  /// 情报数
  final int? intelligenceCounts;

  HankNewsItem({
    this.id,
    this.title,
    this.cover,
    this.type,
    this.author,
    this.authorAvatar,
    this.source,
    this.sourceUrl,
    this.createdAt,
    this.onlineAt,
    this.offlineAt,
    this.status,
    this.content,
    this.isSupport,
    this.videoDirection,
    this.h5Url,
    this.isFollow,
    this.contentCounts,
    this.videoHeight,
    this.videoWidth,
    this.living,
    this.expertId,
    this.patch,
    this.groupId,
    this.weight,
    this.verticalCoverUrl,
    this.intelligenceCounts,
  });

  /// 从JSON解析（snake_case → camelCase）
  factory HankNewsItem.fromJson(Map<String, dynamic> json) {
    return HankNewsItem(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      title: json['title'] as String?,
      cover: json['cover'] as String?,
      type: json['type'] != null ? (json['type'] as num).toInt() : null,
      author: json['author'] as String?,
      authorAvatar: json['author_avatar'] as String?,
      source: json['source'] as String?,
      sourceUrl: json['source_url'] as String?,
      createdAt: json['created_at'] != null ? (json['created_at'] as num).toInt() : null,
      onlineAt: json['online_at'] != null ? (json['online_at'] as num).toInt() : null,
      offlineAt: json['offline_at'] != null ? (json['offline_at'] as num).toInt() : null,
      status: json['status'] != null ? (json['status'] as num).toInt() : null,
      content: json['content'] as String?,
      isSupport: json['is_support'] as bool?,
      videoDirection: json['video_direction'] != null ? (json['video_direction'] as num).toInt() : null,
      h5Url: json['h5_url'] as String?,
      isFollow: json['is_follow'] as bool?,
      contentCounts: json['content_counts'] != null ? (json['content_counts'] as num).toInt() : null,
      videoHeight: json['video_height'] != null ? (json['video_height'] as num).toInt() : null,
      videoWidth: json['video_width'] != null ? (json['video_width'] as num).toInt() : null,
      living: json['living'] as bool?,
      expertId: json['expert_id'] != null ? (json['expert_id'] as num).toInt() : null,
      patch: json['patch'] as String?,
      groupId: json['group_id'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toInt() : null,
      verticalCoverUrl: json['vertical_cover_url'] as String?,
      intelligenceCounts: json['intelligence_counts'] != null ? (json['intelligence_counts'] as num).toInt() : null,
    );
  }
}

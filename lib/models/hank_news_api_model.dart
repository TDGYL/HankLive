/// HankNewsData: newslistAPIresponseDatabody
/// containstotalcountandnewsitem list
class HankNewsData {
  /// Datatotalcount
  final int? total;

  /// newsitem list
  final List<HankNewsItem> results;

  HankNewsData({this.total, this.results = const []});

  /// fromJSONparse
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

/// HankNewsItem: singlenewsDataitem
/// mappingAPIBack snake_case field is camelCase property
class HankNewsItem {
  /// articleuniqueID
  final int? id;

  /// articletitle
  final String? title;

  /// coverimageURL
  final String? cover;

  /// articletype
  final int? type;

  /// author
  final String? author;

  /// authoravatarURL
  final String? authorAvatar;

  /// source
  final String? source;

  /// sourceURL
  final String? sourceUrl;

  /// createdTimetimestamp（seconds）
  final int? createdAt;

  /// uplineTimetimestamp（seconds）
  final int? onlineAt;

  /// downlineTimetimestamp（seconds）
  final int? offlineAt;

  /// status
  final int? status;

  /// content
  final String? content;

  /// whethersupport
  final bool? isSupport;

  /// Videodirection
  final int? videoDirection;

  /// H5pageURL
  final String? h5Url;

  /// whetherFollow
  final bool? isFollow;

  /// readingcount
  final int? contentCounts;

  /// Videoheight
  final int? videoHeight;

  /// Videowidthdepth
  final int? videoWidth;

  /// whetherLivein
  final bool? living;

  /// expertID
  final int? expertId;

  /// patchinfo
  final String? patch;

  /// groupingID
  final String? groupId;

  /// weight
  final int? weight;

  /// portraitcoverURL
  final String? verticalCoverUrl;

  /// intelcount
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

  /// fromJSONparse（snake_case → camelCase）
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

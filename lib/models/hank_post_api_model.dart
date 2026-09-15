/// HankPostData: 社区帖子列表接口响应数据体
/// 包含总数和帖子项列表
class HankPostData {
  /// 数据总数
  final int? total;

  /// 帖子项列表
  final List<HankPostItem> results;

  HankPostData({this.total, this.results = const []});

  /// 从JSON解析
  factory HankPostData.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List?;
    List<HankPostItem> items = [];
    if (list != null) {
      items = list.map((e) => HankPostItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return HankPostData(
      total: json['total'] as int?,
      results: items,
    );
  }
}

/// HankPostItem: 单条帖子数据项
/// 映射接口返回的 snake_case 字段为 camelCase 属性
class HankPostItem {
  /// 帖子唯一ID
  final int? id;

  /// 帖子正文内容
  final String? content;

  /// 话题标签（逗号分隔的字符串，可能含 com/ 前缀）
  final String? image;

  /// 图片列表
  final List<String>? images;

  /// 点赞数
  final int? likeCount;

  /// 评论数
  final int? commentCount;

  /// 创建时间戳（秒）
  final int? createTime;

  /// 作者信息
  final HankPostAuthor? author;

  /// 关联比赛信息
  final HankPostMatch? match;

  /// 是否已点赞
  final bool? isLike;

  HankPostItem({
    this.id,
    this.content,
    this.image,
    this.images,
    this.likeCount,
    this.commentCount,
    this.createTime,
    this.author,
    this.match,
    this.isLike,
  });

  /// 从JSON解析（snake_case → camelCase）
  factory HankPostItem.fromJson(Map<String, dynamic> json) {
    return HankPostItem(
      id: json['id'] as int?,
      content: json['content'] as String?,
      image: json['image'] as String?,
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      likeCount: json['like_count'] as int?,
      commentCount: json['comment_count'] as int?,
      createTime: json['create_time'] as int?,
      author: json['author'] != null ? HankPostAuthor.fromJson(json['author']) : null,
      match: json['match'] != null ? HankPostMatch.fromJson(json['match']) : null,
      isLike: json['is_like'] as bool?,
    );
  }
}

/// HankPostAuthor: 帖子作者信息
class HankPostAuthor {
  /// 作者ID
  final int? id;

  /// 作者昵称
  final String? name;

  /// 是否已关注
  final bool? isSubscribe;

  /// 作者头像URL
  final String? avatar;

  /// 会员ID
  final int? memberId;

  HankPostAuthor({
    this.id,
    this.name,
    this.isSubscribe,
    this.avatar,
    this.memberId,
  });

  /// 从JSON解析
  factory HankPostAuthor.fromJson(Map<String, dynamic> json) {
    return HankPostAuthor(
      id: json['id'] as int?,
      name: json['name'] as String?,
      isSubscribe: json['is_subscribe'] as bool?,
      avatar: json['avatar'] as String?,
      memberId: json['member_id'] as int?,
    );
  }
}

/// HankPostMatch: 帖子关联比赛信息
class HankPostMatch {
  /// 比赛类型
  final int? matchType;

  /// 比赛ID
  final int? matchId;

  /// 赛事ID
  final int? competitionId;

  /// 赛季ID
  final int? seasonId;

  /// 开始时间戳（秒）
  final int? startTime;

  /// 状态ID
  final int? statusId;

  /// 状态名称
  final String? statusName;

  /// 赛事名称
  final String? competitionName;

  /// 主队ID
  final int? homeTeamId;

  /// 主队名称
  final String? homeTeamName;

  /// 主队Logo URL
  final String? homeTeamLogo;

  /// 客队ID
  final int? awayTeamId;

  /// 客队名称
  final String? awayTeamName;

  /// 客队Logo URL
  final String? awayTeamLogo;

  /// 主队比分
  final int? homeScore;

  /// 客队比分
  final int? awayScore;

  HankPostMatch({
    this.matchType,
    this.matchId,
    this.competitionId,
    this.seasonId,
    this.startTime,
    this.statusId,
    this.statusName,
    this.competitionName,
    this.homeTeamId,
    this.homeTeamName,
    this.homeTeamLogo,
    this.awayTeamId,
    this.awayTeamName,
    this.awayTeamLogo,
    this.homeScore,
    this.awayScore,
  });

  /// 从JSON解析
  factory HankPostMatch.fromJson(Map<String, dynamic> json) {
    return HankPostMatch(
      matchType: json['match_type'] as int?,
      matchId: json['match_id'] as int?,
      competitionId: json['competition_id'] as int?,
      seasonId: json['season_id'] as int?,
      startTime: json['start_time'] as int?,
      statusId: json['status_id'] as int?,
      statusName: json['status_name'] as String?,
      competitionName: json['competition_name'] as String?,
      homeTeamId: json['home_team_id'] as int?,
      homeTeamName: json['home_team_name'] as String?,
      homeTeamLogo: json['home_team_logo'] as String?,
      awayTeamId: json['away_team_id'] as int?,
      awayTeamName: json['away_team_name'] as String?,
      awayTeamLogo: json['away_team_logo'] as String?,
      homeScore: json['home_score'] as int?,
      awayScore: json['away_score'] as int?,
    );
  }
}

/// HankSearchMatch: 搜索比赛结果模型
/// 对应 /api/livespeed/index/search 返回的 matches 数组元素
class HankSearchMatch {
  /// 比赛ID
  final int? matchId;

  /// 比赛时间戳（秒）
  final int? matchTime;

  /// 联赛名称
  final String? competitionName;

  /// 主队ID
  final int? homeTeamId;

  /// 主队名称
  final String? homeTeamName;

  /// 主队Logo URL
  final String? homeTeamLogo;

  /// 主队比分
  final int? homeTeamScore;

  /// 客队ID
  final int? awayTeamId;

  /// 客队名称
  final String? awayTeamName;

  /// 客队Logo URL
  final String? awayTeamLogo;

  /// 客队比分
  final int? awayTeamScore;

  /// 比赛分类ID（1=足球，用于过滤）
  final int? categoryId;

  HankSearchMatch({
    this.matchId,
    this.matchTime,
    this.competitionName,
    this.homeTeamId,
    this.homeTeamName,
    this.homeTeamLogo,
    this.homeTeamScore,
    this.awayTeamId,
    this.awayTeamName,
    this.awayTeamLogo,
    this.awayTeamScore,
    this.categoryId,
  });

  /// 从JSON映射（snake_case → camelCase）
  factory HankSearchMatch.fromJson(Map<String, dynamic> json) {
    return HankSearchMatch(
      matchId: json['match_id'] != null ? (json['match_id'] as num).toInt() : null,
      matchTime: json['match_time'] != null ? (json['match_time'] as num).toInt() : null,
      competitionName: json['competition_name'] as String?,
      homeTeamId: json['home_team_id'] != null ? (json['home_team_id'] as num).toInt() : null,
      homeTeamName: json['home_team_name'] as String?,
      homeTeamLogo: json['home_team_logo'] as String?,
      homeTeamScore: json['home_team_score'] != null ? (json['home_team_score'] as num).toInt() : null,
      awayTeamId: json['away_team_id'] != null ? (json['away_team_id'] as num).toInt() : null,
      awayTeamName: json['away_team_name'] as String?,
      awayTeamLogo: json['away_team_logo'] as String?,
      awayTeamScore: json['away_team_score'] != null ? (json['away_team_score'] as num).toInt() : null,
      categoryId: json['category'] != null ? (json['category'] as num).toInt() : null,
    );
  }
}

/// HankSearchUser: 搜索用户结果模型
/// 对应 /api/livespeed/index/search 返回的 users 数组元素
class HankSearchUser {
  /// 用户ID
  int? id;

  /// 用户头像URL
  String? avatar;

  /// 用户昵称
  String? nickname;

  /// 是否直播中（1=直播中）
  int? isLiving;

  /// 是否专家（1=专家）
  int? isExpert;

  /// 关注状态（0或2=未关注，1或3=已关注）
  int? followType;

  HankSearchUser({
    this.id,
    this.avatar,
    this.nickname,
    this.isLiving,
    this.isExpert,
    this.followType,
  });

  /// 是否已关注
  bool get isFollowed => followType == 1 || followType == 3;

  /// 从JSON映射（snake_case → camelCase）
  factory HankSearchUser.fromJson(Map<String, dynamic> json) {
    return HankSearchUser(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String?,
      isLiving: json['is_living'] != null ? (json['is_living'] as num).toInt() : null,
      isExpert: json['is_expert'] != null ? (json['is_expert'] as num).toInt() : null,
      followType: json['follow_type'] != null ? (json['follow_type'] as num).toInt() : null,
    );
  }
}

/// HankSearchCompetition: 搜索联赛结果模型
/// 对应 /api/livespeed/index/search 返回的 competitions 数组元素
class HankSearchCompetition {
  /// 联赛ID
  final int? id;

  /// 联赛名称
  final String? name;

  /// 联赛Logo URL
  final String? logo;

  /// 比赛场次
  final int? matches;

  HankSearchCompetition({
    this.id,
    this.name,
    this.logo,
    this.matches,
  });

  /// 从JSON映射（snake_case → camelCase）
  factory HankSearchCompetition.fromJson(Map<String, dynamic> json) {
    return HankSearchCompetition(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      matches: json['matches'] != null ? (json['matches'] as num).toInt() : null,
    );
  }
}

/// HankSearchResult: 搜索结果模型
/// 对应 /api/livespeed/index/search 返回的 data 对象
class HankSearchResult {
  /// 比赛搜索结果列表
  final List<HankSearchMatch> matches;

  /// 用户搜索结果列表
  final List<HankSearchUser> users;

  /// 联赛搜索结果列表
  final List<HankSearchCompetition> competitions;

  HankSearchResult({
    this.matches = const [],
    this.users = const [],
    this.competitions = const [],
  });

  /// 从JSON映射
  factory HankSearchResult.fromJson(Map<String, dynamic> json) {
    return HankSearchResult(
      matches: (json['matches'] as List<dynamic>? ?? [])
          .map((e) => HankSearchMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      users: (json['users'] as List<dynamic>? ?? [])
          .map((e) => HankSearchUser.fromJson(e as Map<String, dynamic>))
          .toList(),
      competitions: (json['competitions'] as List<dynamic>? ?? [])
          .map((e) => HankSearchCompetition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// HankTeamRank: 球队积分榜行模型
/// 对应接口 GET /api/livespeed/football/team/rank 返回的 groups[].list[] 元素
class HankTeamRank {
  /// 排名位置
  final int position;

  /// 积分
  final int pts;

  /// 已赛场次
  final int played;

  /// 胜场
  final int won;

  /// 平场
  final int drawn;

  /// 负场
  final int lost;

  /// 进球数
  final int goals;

  /// 客场进球数
  final int awayGoals;

  /// 失球数
  final int against;

  /// 净胜球
  final int diff;

  /// 球队ID
  final int teamId;

  /// 晋级标识ID
  final int promotionId;

  /// 分组ID
  final int group;

  /// 晋级名称（英文，如 Qualified）
  final String promotionName;

  /// 分组名称（中文，如 球队）
  final String groupName;

  /// 球队名称
  final String teamName;

  /// 球队Logo URL
  final String teamLogo;

  /// 阶段ID
  final int stageId;

  HankTeamRank({
    required this.position,
    required this.pts,
    required this.played,
    required this.won,
    required this.drawn,
    required this.lost,
    required this.goals,
    required this.awayGoals,
    required this.against,
    required this.diff,
    required this.teamId,
    required this.promotionId,
    required this.group,
    required this.promotionName,
    required this.groupName,
    required this.teamName,
    required this.teamLogo,
    required this.stageId,
  });

  /// 从JSON映射
  factory HankTeamRank.fromJson(Map<String, dynamic> json) {
    return HankTeamRank(
      position: json['position'] as int? ?? 0,
      pts: json['pts'] as int? ?? 0,
      played: json['played'] as int? ?? 0,
      won: json['won'] as int? ?? 0,
      drawn: json['drawn'] as int? ?? 0,
      lost: json['lost'] as int? ?? 0,
      goals: json['goals'] as int? ?? 0,
      awayGoals: json['away_goals'] as int? ?? 0,
      against: json['against'] as int? ?? 0,
      diff: json['diff'] as int? ?? 0,
      teamId: json['team_id'] as int? ?? 0,
      promotionId: json['promotion_id'] as int? ?? 0,
      group: json['group'] as int? ?? 0,
      promotionName: json['promotion_name'] as String? ?? '',
      groupName: json['group_name'] as String? ?? '',
      teamName: json['team_name'] as String? ?? '',
      teamLogo: (json['team_logo'] as String?)?.trim() ?? '',
      stageId: json['stage_id'] as int? ?? 0,
    );
  }
}

/// HankTeamRankGroup: 球队积分榜分组模型
/// 对应接口返回的 groups[] 元素，包含分组名称和球队列表
class HankTeamRankGroup {
  /// 分组名称（如欧冠区、降级区等，可能为空）
  final String promotionName;

  /// 球队列表
  final List<HankTeamRank> list;

  HankTeamRankGroup({
    required this.promotionName,
    required this.list,
  });

  /// 从JSON映射
  factory HankTeamRankGroup.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'] as List? ?? [];
    return HankTeamRankGroup(
      promotionName: json['promotion_name'] as String? ?? '',
      list: rawList
          .map((e) => HankTeamRank.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
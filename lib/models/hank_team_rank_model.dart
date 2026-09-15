/// HankTeamRankGroup: 球队积分榜分组模型
/// 对应接口 GET /api/livespeed/football/team/rank 返回的数组元素
/// 按晋级/降级分组，每组含排名列表
class HankTeamRankGroup {
  /// 晋级/降级名称（如: 欧冠区, 降级区）
  final String? promotionName;

  /// 排名列表
  final List<HankTeamRankItem>? list;

  HankTeamRankGroup({this.promotionName, this.list});

  /// 从JSON解析
  factory HankTeamRankGroup.fromJson(Map<String, dynamic> json) {
    return HankTeamRankGroup(
      promotionName: json['promotion_name'] as String?,
      list: json['list'] != null
          ? (json['list'] as List)
              .map((e) => HankTeamRankItem.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

/// HankTeamRankItem: 积分榜单条排名数据
/// 包含球队排名、积分、胜平负、进球失球等
class HankTeamRankItem {
  /// 球队ID
  final int? teamId;

  /// 球队名称
  final String? teamName;

  /// 球队Logo URL
  final String? logo;

  /// 晋级ID
  final int? promotionId;

  /// 积分
  final int? points;

  /// 排名名次
  final int? position;

  /// 备注
  final String? noteZh;

  /// 总场次
  final int? total;

  /// 胜场
  final int? won;

  /// 平场
  final int? draw;

  /// 负场
  final int? loss;

  /// 进球数
  final int? goals;

  /// 失球数
  final int? goalsAgainst;

  HankTeamRankItem({
    this.teamId,
    this.teamName,
    this.logo,
    this.promotionId,
    this.points,
    this.position,
    this.noteZh,
    this.total,
    this.won,
    this.draw,
    this.loss,
    this.goals,
    this.goalsAgainst,
  });

  /// 从JSON解析
  /// 字段映射：team_id→teamId, goals_against→goalsAgainst 等
  factory HankTeamRankItem.fromJson(Map<String, dynamic> json) {
    return HankTeamRankItem(
      teamId: json['team_id'] != null ? (json['team_id'] as num).toInt() : null,
      teamName: json['team_name'] as String?,
      logo: json['logo'] as String?,
      promotionId: json['promotion_id'] != null
          ? (json['promotion_id'] as num).toInt()
          : null,
      points: json['points'] != null ? (json['points'] as num).toInt() : null,
      position:
          json['position'] != null ? (json['position'] as num).toInt() : null,
      noteZh: json['note_zh'] as String?,
      total: json['total'] != null ? (json['total'] as num).toInt() : null,
      won: json['won'] != null ? (json['won'] as num).toInt() : null,
      draw: json['draw'] != null ? (json['draw'] as num).toInt() : null,
      loss: json['loss'] != null ? (json['loss'] as num).toInt() : null,
      goals: json['goals'] != null ? (json['goals'] as num).toInt() : null,
      goalsAgainst: json['goals_against'] != null
          ? (json['goals_against'] as num).toInt()
          : null,
    );
  }
}

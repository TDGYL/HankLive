/// HankTeamRank: TeamStandingsrowmodel
/// maps to API GET /api/livespeed/football/team/rank Back groups[].list[] element
class HankTeamRank {
  /// rankPosition
  final int position;

  /// points
  final int pts;

  /// alreadymatchmatchtime
  final int played;

  /// Wmatch
  final int won;

  /// Dmatch
  final int drawn;

  /// Lmatch
  final int lost;

  /// Goalscount
  final int goals;

  /// awaymatchGoalscount
  final int awayGoals;

  /// concededcount
  final int against;

  /// netWgoal
  final int diff;

  /// TeamID
  final int teamId;

  /// promotion flagID
  final int promotionId;

  /// groupingID
  final int group;

  /// promotion name（English，e.g. Qualified）
  final String promotionName;

  /// groupingname（Chinese，e.g. Team）
  final String groupName;

  /// Teamname
  final String teamName;

  /// TeamLogo URL
  final String teamLogo;

  /// phaseID
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

  /// fromJSONmapping
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

/// HankTeamRankGroup: TeamStandingsgroupingmodel
/// maps to APIBack groups[] element，containsgroupingnameandTeamlist
class HankTeamRankGroup {
  /// groupingname（e.g.Champions League zone、downlevelareaetc，mayisempty）
  final String promotionName;

  /// Teamlist
  final List<HankTeamRank> list;

  HankTeamRankGroup({
    required this.promotionName,
    required this.list,
  });

  /// fromJSONmapping
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
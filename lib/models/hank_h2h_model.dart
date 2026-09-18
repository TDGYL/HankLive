/// HankH2HMatch: 历史交锋比赛模型
/// 描述两队历史交锋的一场已完赛比赛信息
class HankH2HMatch {
  /// 比赛唯一ID
  final int matchId;

  /// 联赛名称
  final String competitionName;

  /// 联赛Logo
  final String competitionLogo;

  /// 主队ID
  final int homeTeamId;

  /// 主队名称
  final String homeTeamName;

  /// 主队Logo
  final String homeTeamLogo;

  /// 客队ID
  final int awayTeamId;

  /// 客队名称
  final String awayTeamName;

  /// 客队Logo
  final String awayTeamLogo;

  /// 比赛时间戳（秒）
  final int matchTime;

  /// 主队常规比分
  final int? homeNormalScore;

  /// 客队常规比分
  final int? awayNormalScore;

  /// 主队半场比分
  final int? homeHalfScore;

  /// 客队半场比分
  final int? awayHalfScore;

  HankH2HMatch({
    required this.matchId,
    required this.competitionName,
    required this.competitionLogo,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.homeTeamLogo,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.awayTeamLogo,
    required this.matchTime,
    required this.homeNormalScore,
    required this.awayNormalScore,
    required this.homeHalfScore,
    required this.awayHalfScore,
  });

  /// 安全转换为String
  static String _str(dynamic v) {
    if (v == null) return '';
    if (v is String) return v.trim();
    return v.toString();
  }

  /// 从JSON解析
  factory HankH2HMatch.fromJson(Map<String, dynamic> json) {
    return HankH2HMatch(
      matchId: (json['match_id'] as num?)?.toInt() ?? 0,
      competitionName: _str(json['competition_name']),
      competitionLogo: _str(json['competition_logo']),
      homeTeamId: (json['home_team_id'] as num?)?.toInt() ?? 0,
      homeTeamName: _str(json['home_team_name']),
      homeTeamLogo: _str(json['home_team_logo']),
      awayTeamId: (json['away_team_id'] as num?)?.toInt() ?? 0,
      awayTeamName: _str(json['away_team_name']),
      awayTeamLogo: _str(json['away_team_logo']),
      matchTime: (json['match_time'] as num?)?.toInt() ?? 0,
      homeNormalScore: (json['home_normal_score'] as num?)?.toInt(),
      awayNormalScore: (json['away_normal_score'] as num?)?.toInt(),
      homeHalfScore: (json['home_half_score'] as num?)?.toInt(),
      awayHalfScore: (json['away_half_score'] as num?)?.toInt(),
    );
  }

  /// 获取格式化的比赛日期（YYYY-MM-DD）
  String get formattedDate {
    if (matchTime == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(matchTime * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// 获取半场比分文本
  String get halfScoreText {
    return '${homeHalfScore ?? 0}-${awayHalfScore ?? 0}';
  }

  /// 获取总进球数
  int get totalGoals {
    return (homeNormalScore ?? 0) + (awayNormalScore ?? 0);
  }
}
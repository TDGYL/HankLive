/// HankH2HMatch: H2Hmatchmodel
/// descriptiontwoteamH2Hamatchalreadyfinishedmatchmatchinfo
class HankH2HMatch {
  /// matchuniqueID
  final int matchId;

  /// Leaguename
  final String competitionName;

  /// LeagueLogo
  final String competitionLogo;

  /// HomeID
  final int homeTeamId;

  /// Homename
  final String homeTeamName;

  /// HomeLogo
  final String homeTeamLogo;

  /// AwayID
  final int awayTeamId;

  /// Awayname
  final String awayTeamName;

  /// AwayLogo
  final String awayTeamLogo;

  /// matchTimetimestamp（seconds）
  final int matchTime;

  /// Homeregularscore
  final int? homeNormalScore;

  /// Awayregularscore
  final int? awayNormalScore;

  /// HomeHTscore
  final int? homeHalfScore;

  /// AwayHTscore
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

  /// Safeconvert toString
  static String _str(dynamic v) {
    if (v == null) return '';
    if (v is String) return v.trim();
    return v.toString();
  }

  /// fromJSONparse
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

  /// getformatmatchDate（YYYY-MM-DD）
  String get formattedDate {
    if (matchTime == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(matchTime * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// getHTscoretext
  String get halfScoreText {
    return '${homeHalfScore ?? 0}-${awayHalfScore ?? 0}';
  }

  /// get totalGoalscount
  int get totalGoals {
    return (homeNormalScore ?? 0) + (awayNormalScore ?? 0);
  }
}
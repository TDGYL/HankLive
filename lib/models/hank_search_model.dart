/// HankSearchMatch: Searchmatchresultsmodel
/// maps to /api/livespeed/index/search Back matches countgroupelement
class HankSearchMatch {
  /// matchID
  final int? matchId;

  /// matchTimetimestamp（seconds）
  final int? matchTime;

  /// Leaguename
  final String? competitionName;

  /// HomeID
  final int? homeTeamId;

  /// Homename
  final String? homeTeamName;

  /// HomeLogo URL
  final String? homeTeamLogo;

  /// Homescore
  final int? homeTeamScore;

  /// AwayID
  final int? awayTeamId;

  /// Awayname
  final String? awayTeamName;

  /// AwayLogo URL
  final String? awayTeamLogo;

  /// Awayscore
  final int? awayTeamScore;

  /// matchcategorytypeID（1=Football，usefilter）
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

  /// fromJSONmapping（snake_case → camelCase）
  factory HankSearchMatch.fromJson(Map<String, dynamic> json) {
    return HankSearchMatch(
      matchId:
          json['match_id'] != null ? (json['match_id'] as num).toInt() : null,
      matchTime: json['match_time'] != null
          ? (json['match_time'] as num).toInt()
          : null,
      competitionName: json['competition_name'] as String?,
      homeTeamId: json['home_team_id'] != null
          ? (json['home_team_id'] as num).toInt()
          : null,
      homeTeamName: json['home_team_name'] as String?,
      homeTeamLogo: json['home_team_logo'] as String?,
      homeTeamScore: json['home_team_score'] != null
          ? (json['home_team_score'] as num).toInt()
          : null,
      awayTeamId: json['away_team_id'] != null
          ? (json['away_team_id'] as num).toInt()
          : null,
      awayTeamName: json['away_team_name'] as String?,
      awayTeamLogo: json['away_team_logo'] as String?,
      awayTeamScore: json['away_team_score'] != null
          ? (json['away_team_score'] as num).toInt()
          : null,
      categoryId:
          json['category'] != null ? (json['category'] as num).toInt() : null,
    );
  }
}

/// HankSearchUser: Searchuseaccountresultsmodel
/// maps to /api/livespeed/index/search Back users countgroupelement
class HankSearchUser {
  /// useaccountID
  int? id;

  /// useaccountavatarURL
  String? avatar;

  /// useaccountnickname
  String? nickname;

  /// whetherLivein（1=Livein）
  int? isLiving;

  /// whetherexpert（1=expert）
  int? isExpert;

  /// Followstatus（0or2=notFollow，1or3=alreadyFollow）
  int? followType;

  HankSearchUser({
    this.id,
    this.avatar,
    this.nickname,
    this.isLiving,
    this.isExpert,
    this.followType,
  });

  /// whetheralreadyFollow
  bool get isFollowed => followType == 1 || followType == 3;

  /// fromJSONmapping（snake_case → camelCase）
  factory HankSearchUser.fromJson(Map<String, dynamic> json) {
    return HankSearchUser(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String?,
      isLiving:
          json['is_living'] != null ? (json['is_living'] as num).toInt() : null,
      isExpert:
          json['is_expert'] != null ? (json['is_expert'] as num).toInt() : null,
      followType: json['follow_type'] != null
          ? (json['follow_type'] as num).toInt()
          : null,
    );
  }
}

/// HankSearchCompetition: SearchLeagueresultsmodel
/// maps to /api/livespeed/index/search Back competitions countgroupelement
class HankSearchCompetition {
  /// LeagueID
  final int? id;

  /// Leaguename
  final String? name;

  /// LeagueLogo URL
  final String? logo;

  /// matchmatchtime
  final int? matches;

  HankSearchCompetition({
    this.id,
    this.name,
    this.logo,
    this.matches,
  });

  /// fromJSONmapping（snake_case → camelCase）
  factory HankSearchCompetition.fromJson(Map<String, dynamic> json) {
    return HankSearchCompetition(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      matches:
          json['matches'] != null ? (json['matches'] as num).toInt() : null,
    );
  }
}

/// HankSearchResult: Searchresultsmodel
/// maps to /api/livespeed/index/search Back data object
class HankSearchResult {
  /// matchSearchresult list
  final List<HankSearchMatch> matches;

  /// useaccountSearchresult list
  final List<HankSearchUser> users;

  /// LeagueSearchresult list
  final List<HankSearchCompetition> competitions;

  HankSearchResult({
    this.matches = const [],
    this.users = const [],
    this.competitions = const [],
  });

  /// fromJSONmapping
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

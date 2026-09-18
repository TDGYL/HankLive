/// HankMatchData: matchlistAPIresponseDatabody
/// containstotalcount、Timetimestamp、matchitem list
class HankMatchData {
  /// Datatotalcount
  final int? total;

  /// requestTimetimestamp（seconds）
  final int? timestamp;

  /// matchitem list
  final List<HankMatchItem> results;

  HankMatchData({this.total, this.timestamp, this.results = const []});

  /// fromJSONparse
  factory HankMatchData.fromJson(Map<String, dynamic> json) {
    final list = json['results'] as List?;
    List<HankMatchItem> items = [];
    if (list != null) {
      items = list.map((e) => HankMatchItem.fromJson(e as Map<String, dynamic>)).toList();
    }
    return HankMatchData(
      total: json['total'] as int?,
      timestamp: json['timestamp'] as int?,
      results: items,
    );
  }
}

/// HankMatchItem: singlematchmatchDataitem
/// mappingAPIBack snake_case field is camelCase property
class HankMatchItem {
  /// matchuniqueID
  final int? matchId;

  /// SeasonID
  final int? seasonId;

  /// matchID
  final int? competitionId;

  /// matchLogo URL
  final String? competitionLogo;

  /// matchname
  final String? competitionName;

  /// matchhomecolor
  final String? competitionPrimaryColor;

  /// matchsecondarycolor
  final String? competitionSecondaryColor;

  /// HomeID
  final int? homeTeamId;

  /// Homename
  final String? homeTeamName;

  /// HomeLogo URL
  final String? homeTeamLogo;

  /// AwayID
  final int? awayTeamId;

  /// Awayname
  final String? awayTeamName;

  /// AwayLogo URL
  final String? awayTeamLogo;

  /// statusID（0/1=not started，2/3/4=In Progress，8=FT）
  final int? statusId;

  /// statusname（Chinese）
  final String? statusName;

  /// openmatchTimetimestamp（seconds）
  final int? matchTime;

  /// whetherincreatematch
  final int? neutral;

  /// Homeregularscore
  final int? homeNormalScore;

  /// HomeHTscore
  final int? homeHalfScore;

  /// HomeRed Cardscount
  final int? homeRed;

  /// HomeYellow Cardscount
  final int? homeYellow;

  /// HomeCornerscount
  final int? homeCorn;

  /// Homeovertime score
  final int? homeAddScore;

  /// HomePENscore
  final int? homePointScore;

  /// Awayregularscore
  final int? awayNormalScore;

  /// AwayHTscore
  final int? awayHalfScore;

  /// AwayRed Cardscount
  final int? awayRed;

  /// AwayYellow Cardscount
  final int? awayYellow;

  /// AwayCornerscount
  final int? awayCorn;

  /// Awayovertime score
  final int? awayAddScore;

  /// AwayPENscore
  final int? awayPointScore;

  /// whetherhasLineupData
  final int? lineup;

  /// phaseID
  final int? stageId;

  /// whetheralreadysubscribeFollow
  final bool? subscribed;

  /// Homerank
  final String? homePosition;

  /// Awayrank
  final String? awayPosition;

  /// whetherhasovertime
  final bool? hasOt;

  /// whetherhasPENderby
  final bool? hasPenalty;

  /// WLresults（1=homeW，2=D，3=awayW）
  final int? win;

  /// remark（e.g.：HTscore、totalscoreetc）
  final String? note;

  /// In Progressmincount（e.g.: "78'"）
  final String? minutes;

  /// whetherhasanimationLive
  final int? mlive;

  /// animationLiveURL
  final String? mliveUrl;

  /// whetherhasVideoLive
  final int? liveVideo;

  /// whetherhasphasematcharticle
  final int? hasArticle;

  /// phasename
  final String? stageName;

  /// groupingnumber
  final String? groupNum;

  /// Round
  final int? roundNum;

  /// plancount
  final int? schemeCount;

  /// countdown（seconds）
  final int? countdown;

  /// whetherWorld Cup
  final int? isWorldCup;

  /// motioncategorytype（1=Football）
  final int? categoryId;

  HankMatchItem({
    this.matchId,
    this.seasonId,
    this.competitionId,
    this.competitionLogo,
    this.competitionName,
    this.competitionPrimaryColor,
    this.competitionSecondaryColor,
    this.homeTeamId,
    this.homeTeamName,
    this.homeTeamLogo,
    this.awayTeamId,
    this.awayTeamName,
    this.awayTeamLogo,
    this.statusId,
    this.statusName,
    this.matchTime,
    this.neutral,
    this.homeNormalScore,
    this.homeHalfScore,
    this.homeRed,
    this.homeYellow,
    this.homeCorn,
    this.homeAddScore,
    this.homePointScore,
    this.awayNormalScore,
    this.awayHalfScore,
    this.awayRed,
    this.awayYellow,
    this.awayCorn,
    this.awayAddScore,
    this.awayPointScore,
    this.lineup,
    this.stageId,
    this.subscribed,
    this.homePosition,
    this.awayPosition,
    this.hasOt,
    this.hasPenalty,
    this.win,
    this.note,
    this.minutes,
    this.mlive,
    this.mliveUrl,
    this.liveVideo,
    this.hasArticle,
    this.stageName,
    this.groupNum,
    this.roundNum,
    this.schemeCount,
    this.countdown,
    this.isWorldCup,
    this.categoryId,
  });

  /// fromJSONparse（snake_case → camelCase）
  factory HankMatchItem.fromJson(Map<String, dynamic> json) {
    return HankMatchItem(
      matchId: json['match_id'] as int?,
      seasonId: json['season_id'] as int?,
      competitionId: json['competition_id'] as int?,
      competitionLogo: json['competition_logo'] as String?,
      competitionName: json['competition_name'] as String?,
      competitionPrimaryColor: json['competition_primary_color'] as String?,
      competitionSecondaryColor: json['competition_secondary_color'] as String?,
      homeTeamId: json['home_team_id'] as int?,
      homeTeamName: json['home_team_name'] as String?,
      homeTeamLogo: json['home_team_logo'] as String?,
      awayTeamId: json['away_team_id'] as int?,
      awayTeamName: json['away_team_name'] as String?,
      awayTeamLogo: json['away_team_logo'] as String?,
      statusId: json['status_id'] as int?,
      statusName: json['status_name'] as String?,
      matchTime: json['match_time'] as int?,
      neutral: json['neutral'] as int?,
      homeNormalScore: json['home_normal_score'] as int?,
      homeHalfScore: json['home_half_score'] as int?,
      homeRed: json['home_red'] as int?,
      homeYellow: json['home_yellow'] as int?,
      homeCorn: json['home_corn'] as int?,
      homeAddScore: json['home_add_score'] as int?,
      homePointScore: json['home_point_score'] as int?,
      awayNormalScore: json['away_normal_score'] as int?,
      awayHalfScore: json['away_half_score'] as int?,
      awayRed: json['away_red'] as int?,
      awayYellow: json['away_yellow'] as int?,
      awayCorn: json['away_corn'] as int?,
      awayAddScore: json['away_add_score'] as int?,
      awayPointScore: json['away_point_score'] as int?,
      lineup: json['lineup'] as int?,
      stageId: json['stage_id'] as int?,
      subscribed: json['subscribed'] as bool?,
      homePosition: json['home_position'] as String?,
      awayPosition: json['away_position'] as String?,
      hasOt: json['has_ot'] as bool?,
      hasPenalty: json['has_penalty'] as bool?,
      win: json['win'] as int?,
      note: json['note'] as String?,
      minutes: json['minutes'] as String?,
      mlive: json['mlive'] as int?,
      mliveUrl: json['mlive_url'] as String?,
      liveVideo: json['live_video'] as int?,
      hasArticle: json['has_article'] as int?,
      stageName: json['stage_name'] as String?,
      groupNum: json['group_num'] as String?,
      roundNum: json['round_num'] as int?,
      schemeCount: json['scheme_count'] as int?,
      countdown: json['countdown'] as int?,
      isWorldCup: json['is_world_cup'] as int?,
      categoryId: json['category'] != null ? (json['category'] as num).toInt() : null,
    );
  }
}

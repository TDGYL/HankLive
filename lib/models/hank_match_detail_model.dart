/// HankMatchEventType: match eventseventtypeenum
/// goal: Goals | penaltyGoal: PENGoals | yellowCard: Yellow Cards | redCard: Red Cards | substitution: substitution
enum HankMatchEventType {
  /// Goals
  goal,
  /// PENGoals
  penaltyGoal,
  /// Yellow Cards
  yellowCard,
  /// Red Cards
  redCard,
  /// substitution
  substitution,
}

/// HankMatchEvent: match eventsTimelineeventmodel
/// useArticlematch eventsTabevent display in
class HankMatchEvent {
  /// eventuniqueID
  final String id;

  /// eventtype
  final HankMatchEventType type;

  /// occurredTime（min，e.g.: 58）
  final int minute;

  /// eventtitle（e.g.: "GOAL! Goalsgotcategory!"）
  final String title;

  /// eventdescription
  final String description;

  /// belongs toTeamname
  final String teamName;

  /// score change（e.g.: "Arsenal 2 - 1 Man City"）
  final String? scoreChange;

  /// extrainfo（e.g.: "assists: Odegaard · xG: 0.08"）
  final String? extraInfo;

  HankMatchEvent({
    required this.id,
    required this.type,
    required this.minute,
    required this.title,
    required this.description,
    required this.teamName,
    this.scoreChange,
    this.extraInfo,
  });
}

/// HankMatchPlayer: Playermodel（starterLineup）
class HankMatchPlayer {
  /// Playername
  final String name;

  /// jerseyNumber
  final String number;

  /// Position（e.g.: striker、left winger、goalkeeper）
  final String position;

  /// rating
  final String rating;

  /// whetherismatchkeyPlayer（starlevelmarkrecord）
  final bool isStar;

  /// Goalsmarkrecord
  final bool hasGoal;

  /// Yellow Cardsmarkrecord
  final bool hasYellowCard;

  HankMatchPlayer({
    required this.name,
    required this.number,
    required this.position,
    required this.rating,
    this.isStar = false,
    this.hasGoal = false,
    this.hasYellowCard = false,
  });
}

/// HankMatchStatItem: technicalstat itemmodel
/// usetechnicalstatsTabinmatchmatchDataitem
class HankMatchStatItem {
  /// stat itemname（e.g.: Possession、Shotstimecount）
  final String label;

  /// Homecountvalue
  final String homeValue;

  /// Awaycountvalue
  final String awayValue;

  /// Homeproportionpercentcategorymatch（0-100，useprogressitem）
  final int homePercent;

  /// Awayproportionpercentcategorymatch（0-100，useprogressitem）
  final int awayPercent;

  HankMatchStatItem({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homePercent,
    required this.awayPercent,
  });
}

/// HankMatchOddsRow: oddscountrowmodel
/// useOddsTabhandicap in/1X2table
class HankMatchOddsRow {
  /// Handicapphase（e.g.: ishandicap、Opening）
  final String stage;

  /// homeWOdds
  final String homeOdds;

  /// Handicap/DmatchOdds
  final String middleOdds;

  /// awayWOdds
  final String awayOdds;

  /// homeWOddstrend（up: upup, down: downdown, null: nonechange）
  final String? homeTrend;

  /// awayWOddstrend
  final String? awayTrend;

  HankMatchOddsRow({
    required this.stage,
    required this.homeOdds,
    required this.middleOdds,
    required this.awayOdds,
    this.homeTrend,
    this.awayTrend,
  });
}

/// HankMatchLineupFormation: Teamformation andstarterPlayer
class HankMatchLineupFormation {
  /// Teamname
  final String teamName;

  /// formation（e.g.: 4-3-3）
  final String formation;

  /// Teamcolor（Homeredcolor/Awaybluecolor）
  final int teamColor;

  /// Playerlist（byformationrowarrange）
  final List<List<HankMatchPlayer>> playerRows;

  HankMatchLineupFormation({
    required this.teamName,
    required this.formation,
    required this.teamColor,
    required this.playerRows,
  });
}

/// HankMatchBenchPlayer: benchPlayer
class HankMatchBenchPlayer {
  /// PlayerNumber-name
  final String name;

  /// belongs toTeamname
  final String teamName;

  /// whetheralreadyonmatch
  final bool isPlayed;

  /// onmatchTime（e.g.: 65'）
  final String? playedMinute;

  HankMatchBenchPlayer({
    required this.name,
    required this.teamName,
    this.isPlayed = false,
    this.playedMinute,
  });
}

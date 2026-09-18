import 'team_model.dart';

/// MatchStatus: matchstatusenum
/// live: Livein | upcoming: not started | finished: alreadyfinishedmatch
enum MatchStatus { live, upcoming, finished }

/// MatchModel: matchinfomodel
/// containstwo sides、score、matchinfo、AIWrateetc
class MatchModel {
  /// matchuniqueID
  final String matchId;

  /// Leaguename（e.g.：EnglandFootballoverlevelLeague）
  final String leagueName;

  /// Leagueiconcolor（for trophyicon）
  final int leagueColor;

  /// Homeinfo
  final TeamModel homeTeam;

  /// Awayinfo
  final TeamModel awayTeam;

  /// Homescore
  final int? homeScore;

  /// Awayscore
  final int? awayScore;

  /// matchstartTimestring（e.g.: 20:00, Tomorrow 03:45）
  final String matchTime;

  /// matchstatus
  final MatchStatus status;

  /// enterrowtoTime（onlyLivestatus，e.g.: 78'）
  final String? liveMinute;

  /// HTscore（e.g.: 1-0）
  final String? halfTimeScore;

  /// Goalsevent summarycountgroup（Home+Away）
  final List<String> goalEvents;

  /// isFeaturedBannermatch（dark card style）
  final bool isFeatured;

  /// isFollowmatch
  final bool isFollowed;

  /// AIpredictionHomeWrate 0-100
  final int homeWinRate;

  /// AIpredictionDmatchrate 0-100
  final int drawRate;

  /// AIpredictionAwayWrate 0-100
  final int awayWinRate;

  /// matchlinkedtag（useCommunitySearch、mount）
  final String? matchTag;

  MatchModel({
    required this.matchId,
    required this.leagueName,
    required this.leagueColor,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    required this.matchTime,
    required this.status,
    this.liveMinute,
    this.halfTimeScore,
    this.goalEvents = const [],
    this.isFeatured = false,
    this.isFollowed = false,
    this.homeWinRate = 0,
    this.drawRate = 0,
    this.awayWinRate = 0,
    this.matchTag,
  });

  /// fromJSONparse
  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      matchId: json['matchId'] ?? '',
      leagueName: json['leagueName'] ?? '',
      leagueColor: json['leagueColor'] ?? 0xFF8B5CF6,
      homeTeam: TeamModel.fromJson(json['homeTeam'] ?? {}),
      awayTeam: TeamModel.fromJson(json['awayTeam'] ?? {}),
      homeScore: json['homeScore'],
      awayScore: json['awayScore'],
      matchTime: json['matchTime'] ?? '',
      status: _matchStatusFromString(json['status'] ?? 'upcoming'),
      liveMinute: json['liveMinute'],
      halfTimeScore: json['halfTimeScore'],
      goalEvents: (json['goalEvents'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isFeatured: json['isFeatured'] ?? false,
      isFollowed: json['isFollowed'] ?? false,
      homeWinRate: json['homeWinRate'] ?? 0,
      drawRate: json['drawRate'] ?? 0,
      awayWinRate: json['awayWinRate'] ?? 0,
      matchTag: json['matchTag'],
    );
  }

  /// statusenumconvert
  static MatchStatus _matchStatusFromString(String s) {
    switch (s) {
      case 'live':
        return MatchStatus.live;
      case 'finished':
        return MatchStatus.finished;
      default:
        return MatchStatus.upcoming;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'leagueName': leagueName,
      'leagueColor': leagueColor,
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'matchTime': matchTime,
      'status': status.name,
      'liveMinute': liveMinute,
      'halfTimeScore': halfTimeScore,
      'goalEvents': goalEvents,
      'isFeatured': isFeatured,
      'isFollowed': isFollowed,
      'homeWinRate': homeWinRate,
      'drawRate': drawRate,
      'awayWinRate': awayWinRate,
      'matchTag': matchTag,
    };
  }
}

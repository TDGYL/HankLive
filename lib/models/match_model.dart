import 'team_model.dart';

/// MatchStatus: 比赛状态枚举
/// live: 直播中 | upcoming: 未开赛 | finished: 已完赛
enum MatchStatus { live, upcoming, finished }

/// MatchModel: 比赛信息模型
/// 包含对阵双方、比分、赛事信息、AI胜率等
class MatchModel {
  /// 比赛唯一ID
  final String matchId;

  /// 联赛名称（如：英格兰足球超级联赛）
  final String leagueName;

  /// 联赛图标颜色（用于奖杯icon）
  final int leagueColor;

  /// 主队信息
  final TeamModel homeTeam;

  /// 客队信息
  final TeamModel awayTeam;

  /// 主队比分
  final int? homeScore;

  /// 客队比分
  final int? awayScore;

  /// 比赛开始时间字符串（如: 20:00, 明日 03:45）
  final String matchTime;

  /// 比赛状态
  final MatchStatus status;

  /// 进行到的时间（仅直播状态，如: 78'）
  final String? liveMinute;

  /// 半场比分（如: 1-0）
  final String? halfTimeScore;

  /// 进球事件摘要数组（主队+客队）
  final List<String> goalEvents;

  /// 是否是精选Banner比赛（深色大卡片样式）
  final bool isFeatured;

  /// 是否是关注的比赛
  final bool isFollowed;

  /// AI预测主队胜率 0-100
  final int homeWinRate;

  /// AI预测平局率 0-100
  final int drawRate;

  /// AI预测客队胜率 0-100
  final int awayWinRate;

  /// 比赛关联标签（用于社区搜索、挂载）
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

  /// 从JSON解析
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

  /// 状态枚举转换
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

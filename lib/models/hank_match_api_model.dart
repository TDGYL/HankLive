/// HankMatchData: 比赛列表接口响应数据体
/// 包含总数、时间戳、比赛项列表
class HankMatchData {
  /// 数据总数
  final int? total;

  /// 请求时间戳（秒）
  final int? timestamp;

  /// 比赛项列表
  final List<HankMatchItem> results;

  HankMatchData({this.total, this.timestamp, this.results = const []});

  /// 从JSON解析
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

/// HankMatchItem: 单场比赛数据项
/// 映射接口返回的 snake_case 字段为 camelCase 属性
class HankMatchItem {
  /// 比赛唯一ID
  final int? matchId;

  /// 赛季ID
  final int? seasonId;

  /// 赛事ID
  final int? competitionId;

  /// 赛事Logo URL
  final String? competitionLogo;

  /// 赛事名称
  final String? competitionName;

  /// 赛事主色
  final String? competitionPrimaryColor;

  /// 赛事辅色
  final String? competitionSecondaryColor;

  /// 主队ID
  final int? homeTeamId;

  /// 主队名称
  final String? homeTeamName;

  /// 主队Logo URL
  final String? homeTeamLogo;

  /// 客队ID
  final int? awayTeamId;

  /// 客队名称
  final String? awayTeamName;

  /// 客队Logo URL
  final String? awayTeamLogo;

  /// 状态ID（0/1=未开赛，2/3/4=进行中，8=完场）
  final int? statusId;

  /// 状态名称（中文）
  final String? statusName;

  /// 开赛时间戳（秒）
  final int? matchTime;

  /// 是否中立场
  final int? neutral;

  /// 主队常规比分
  final int? homeNormalScore;

  /// 主队半场比分
  final int? homeHalfScore;

  /// 主队红牌数
  final int? homeRed;

  /// 主队黄牌数
  final int? homeYellow;

  /// 主队角球数
  final int? homeCorn;

  /// 主队加时比分
  final int? homeAddScore;

  /// 主队点球比分
  final int? homePointScore;

  /// 客队常规比分
  final int? awayNormalScore;

  /// 客队半场比分
  final int? awayHalfScore;

  /// 客队红牌数
  final int? awayRed;

  /// 客队黄牌数
  final int? awayYellow;

  /// 客队角球数
  final int? awayCorn;

  /// 客队加时比分
  final int? awayAddScore;

  /// 客队点球比分
  final int? awayPointScore;

  /// 是否有阵容数据
  final int? lineup;

  /// 阶段ID
  final int? stageId;

  /// 是否已订阅关注
  final bool? subscribed;

  /// 主队排名
  final String? homePosition;

  /// 客队排名
  final String? awayPosition;

  /// 是否有加时
  final bool? hasOt;

  /// 是否有点球大战
  final bool? hasPenalty;

  /// 胜负结果（1=主胜，2=平，3=客胜）
  final int? win;

  /// 备注（如：半场比分、总比分等）
  final String? note;

  /// 进行中分钟数（如: "78'"）
  final String? minutes;

  /// 是否有动画直播
  final int? mlive;

  /// 动画直播URL
  final String? mliveUrl;

  /// 是否有视频直播
  final int? liveVideo;

  /// 是否有相关文章
  final int? hasArticle;

  /// 阶段名称
  final String? stageName;

  /// 分组号
  final String? groupNum;

  /// 轮次
  final int? roundNum;

  /// 方案数
  final int? schemeCount;

  /// 倒计时（秒）
  final int? countdown;

  /// 是否世界杯
  final int? isWorldCup;

  /// 运动分类（1=足球）
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

  /// 从JSON解析（snake_case → camelCase）
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

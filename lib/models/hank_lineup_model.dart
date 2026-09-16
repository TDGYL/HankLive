/// HankLineupIncident: 球员事件（进球/黄牌/红牌等）
/// 对应API字段：incidents 数组中的元素
class HankLineupIncident {
  /// 事件类型（0: 未知, 1: 进球, 2: 黄牌, 3: 红牌, 4: 换人 等）
  final int type;

  /// 事件时间（如: "45'"）
  final String time;

  HankLineupIncident({
    required this.type,
    required this.time,
  });

  /// 从JSON映射
  factory HankLineupIncident.fromJson(Map<String, dynamic> json) {
    return HankLineupIncident(
      type: json['type'] as int? ?? 0,
      time: json['time'] as String? ?? '',
    );
  }
}

/// HankLineupPlayer: 阵容球员模型
/// 对应API字段：first/sub → home/away 数组中的元素
class HankLineupPlayer {
  /// 球员ID
  final int playerId;

  /// 球员头像URL
  final String playerLogo;

  /// 球员姓名
  final String playerName;

  /// 球员位置（如: "GK", "DF", "MF", "FW"）
  final String position;

  /// X坐标（0-100，百分比，用于球场定位）
  final double x;

  /// Y坐标（0-100，百分比，用于球场定位）
  final double y;

  /// 评分
  final String rating;

  /// 球衣号码
  final int shirtNumber;

  /// 事件列表（进球、黄牌等）
  final List<HankLineupIncident> incidents;

  HankLineupPlayer({
    required this.playerId,
    required this.playerLogo,
    required this.playerName,
    required this.position,
    required this.x,
    required this.y,
    required this.rating,
    required this.shirtNumber,
    required this.incidents,
  });

  /// 从JSON映射
  factory HankLineupPlayer.fromJson(Map<String, dynamic> json) {
    return HankLineupPlayer(
      playerId: json['player_id'] as int? ?? 0,
      playerLogo: json['player_logo'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      rating: json['rating'] as String? ?? '',
      shirtNumber: json['shirt_number'] as int? ?? 0,
      incidents: (json['incidents'] as List<dynamic>?)
              ?.map((e) => HankLineupIncident.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// HankLineupInjuryPlayer: 伤停球员模型
/// 对应API字段：injury → home/away 数组中的元素
class HankLineupInjuryPlayer {
  /// 球员ID
  final int playerId;

  /// 球员头像URL
  final String playerLogo;

  /// 球员姓名
  final String playerName;

  /// 伤停类型
  final String type;

  /// 伤停原因
  final String reason;

  /// 球员位置
  final String position;

  HankLineupInjuryPlayer({
    required this.playerId,
    required this.playerLogo,
    required this.playerName,
    required this.type,
    required this.reason,
    required this.position,
  });

  /// 从JSON映射
  factory HankLineupInjuryPlayer.fromJson(Map<String, dynamic> json) {
    return HankLineupInjuryPlayer(
      playerId: json['player_id'] as int? ?? 0,
      playerLogo: json['player_logo'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
      type: (json['type'] ?? '').toString(),
      reason: json['reason'] as String? ?? '',
      position: json['position'] as String? ?? '',
    );
  }
}

/// HankLineupCoach: 教练模型
/// 对应API字段：home_coach / away_coach
class HankLineupCoach {
  /// 教练ID
  final int id;

  /// 教练头像URL
  final String logo;

  /// 教练姓名
  final String name;

  HankLineupCoach({
    required this.id,
    required this.logo,
    required this.name,
  });

  /// 从JSON映射
  factory HankLineupCoach.fromJson(Map<String, dynamic> json) {
    return HankLineupCoach(
      id: json['id'] as int? ?? 0,
      logo: json['logo'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// HankLineupTeam: 单支球队的阵容数据（首发/替补/伤停）
class HankLineupTeam {
  /// 首发球员列表
  final List<HankLineupPlayer> first;

  /// 替补球员列表
  final List<HankLineupPlayer> sub;

  /// 伤停球员列表
  final List<HankLineupInjuryPlayer> injury;

  HankLineupTeam({
    required this.first,
    required this.sub,
    required this.injury,
  });
}

/// HankLineupData: 阵容完整数据模型
/// 对应API返回的data对象
/// 包含：first（首发）、sub（替补）、injury（伤停）、教练、阵型、身价
class HankLineupData {
  /// 主队首发
  final List<HankLineupPlayer> homeFirst;

  /// 客队首发
  final List<HankLineupPlayer> awayFirst;

  /// 主队替补
  final List<HankLineupPlayer> homeSub;

  /// 客队替补
  final List<HankLineupPlayer> awaySub;

  /// 主队伤停
  final List<HankLineupInjuryPlayer> homeInjury;

  /// 客队伤停
  final List<HankLineupInjuryPlayer> awayInjury;

  /// 主队教练
  final HankLineupCoach homeCoach;

  /// 客队教练
  final HankLineupCoach awayCoach;

  /// 主队阵型（如: "4-3-3"）
  final String homeFormation;

  /// 客队阵型
  final String awayFormation;

  /// 主队身价
  final int homeMarketValue;

  /// 客队身价
  final int awayMarketValue;

  HankLineupData({
    required this.homeFirst,
    required this.awayFirst,
    required this.homeSub,
    required this.awaySub,
    required this.homeInjury,
    required this.awayInjury,
    required this.homeCoach,
    required this.awayCoach,
    required this.homeFormation,
    required this.awayFormation,
    required this.homeMarketValue,
    required this.awayMarketValue,
  });

  /// 从JSON映射
  /// data结构: { first: { home: [...], away: [...] }, sub: { home: [...], away: [...] }, injury: {...}, home_coach: {...}, away_coach: {...}, home_formation: "4-3-3", away_formation: "4-3-3", home_market_value: 0, away_market_value: 0 }
  factory HankLineupData.fromJson(Map<String, dynamic> json) {
    // 首发阵容
    final firstMap = json['first'] as Map<String, dynamic>? ?? {};
    final homeFirstRaw = firstMap['home'] as List<dynamic>? ?? [];
    final awayFirstRaw = firstMap['away'] as List<dynamic>? ?? [];

    // 替补席
    final subMap = json['sub'] as Map<String, dynamic>? ?? {};
    final homeSubRaw = subMap['home'] as List<dynamic>? ?? [];
    final awaySubRaw = subMap['away'] as List<dynamic>? ?? [];

    // 伤停
    final injuryMap = json['injury'] as Map<String, dynamic>? ?? {};
    final homeInjuryRaw = injuryMap['home'] as List<dynamic>? ?? [];
    final awayInjuryRaw = injuryMap['away'] as List<dynamic>? ?? [];

    return HankLineupData(
      homeFirst: homeFirstRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      awayFirst: awayFirstRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeSub: homeSubRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      awaySub: awaySubRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeInjury: homeInjuryRaw
          .map((e) => HankLineupInjuryPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      awayInjury: awayInjuryRaw
          .map((e) => HankLineupInjuryPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeCoach: HankLineupCoach.fromJson(
          json['home_coach'] as Map<String, dynamic>? ?? {}),
      awayCoach: HankLineupCoach.fromJson(
          json['away_coach'] as Map<String, dynamic>? ?? {}),
      homeFormation: json['home_formation'] as String? ?? '',
      awayFormation: json['away_formation'] as String? ?? '',
      homeMarketValue: json['home_market_value'] as int? ?? 0,
      awayMarketValue: json['away_market_value'] as int? ?? 0,
    );
  }
}

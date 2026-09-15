/// HankMatchEventType: 赛况事件类型枚举
/// goal: 进球 | penaltyGoal: 点球进球 | yellowCard: 黄牌 | redCard: 红牌 | substitution: 换人
enum HankMatchEventType {
  /// 进球
  goal,
  /// 点球进球
  penaltyGoal,
  /// 黄牌
  yellowCard,
  /// 红牌
  redCard,
  /// 换人
  substitution,
}

/// HankMatchEvent: 赛况时间线事件模型
/// 用于图文赛况Tab中的事件展示
class HankMatchEvent {
  /// 事件唯一ID
  final String id;

  /// 事件类型
  final HankMatchEventType type;

  /// 发生时间（分钟，如: 58）
  final int minute;

  /// 事件标题（如: "GOAL! 进球得分!"）
  final String title;

  /// 事件描述
  final String description;

  /// 所属球队名称
  final String teamName;

  /// 比分变化（如: "阿森纳 2 - 1 曼城"）
  final String? scoreChange;

  /// 附加信息（如: "助攻: 厄德高 · xG: 0.08"）
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

/// HankMatchPlayer: 球员模型（首发阵容）
class HankMatchPlayer {
  /// 球员姓名
  final String name;

  /// 球衣号码
  final String number;

  /// 位置（如: 中锋、左边锋、门将）
  final String position;

  /// 评分
  final String rating;

  /// 是否为关键球员（星级标记）
  final bool isStar;

  /// 进球标记
  final bool hasGoal;

  /// 黄牌标记
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

/// HankMatchStatItem: 技术统计项模型
/// 用于技术统计Tab中的对比数据条
class HankMatchStatItem {
  /// 统计项名称（如: 控球率、射门次数）
  final String label;

  /// 主队数值
  final String homeValue;

  /// 客队数值
  final String awayValue;

  /// 主队占比百分比（0-100，用于进度条）
  final int homePercent;

  /// 客队占比百分比（0-100，用于进度条）
  final int awayPercent;

  HankMatchStatItem({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    required this.homePercent,
    required this.awayPercent,
  });
}

/// HankMatchOddsRow: 指数行模型
/// 用于指数分析Tab中的让球/欧赔表格
class HankMatchOddsRow {
  /// 盘口阶段（如: 即盘、初盘）
  final String stage;

  /// 主胜赔率
  final String homeOdds;

  /// 盘口/平局赔率
  final String middleOdds;

  /// 客胜赔率
  final String awayOdds;

  /// 主胜赔率趋势（up: 上升, down: 下降, null: 无变化）
  final String? homeTrend;

  /// 客胜赔率趋势
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

/// HankMatchLineupFormation: 球队阵型与首发球员
class HankMatchLineupFormation {
  /// 球队名称
  final String teamName;

  /// 阵型（如: 4-3-3）
  final String formation;

  /// 球队颜色（主队红色/客队蓝色）
  final int teamColor;

  /// 球员列表（按阵型行排列）
  final List<List<HankMatchPlayer>> playerRows;

  HankMatchLineupFormation({
    required this.teamName,
    required this.formation,
    required this.teamColor,
    required this.playerRows,
  });
}

/// HankMatchBenchPlayer: 替补席球员
class HankMatchBenchPlayer {
  /// 球员号码-姓名
  final String name;

  /// 所属球队名称
  final String teamName;

  /// 是否已登场
  final bool isPlayed;

  /// 登场时间（如: 65'）
  final String? playedMinute;

  HankMatchBenchPlayer({
    required this.name,
    required this.teamName,
    this.isPlayed = false,
    this.playedMinute,
  });
}

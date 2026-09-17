/// HankPlayerRank: 球员排行数据模型
/// 用于展示球员在某个分类下的排名信息（如进球榜、助攻榜）
class HankPlayerRank {
  /// 球员唯一ID
  final int playerId;

  /// 排行分类名称（如 进球）
  final String rankName;

  /// 排名位置
  final int position;

  /// 球员名称
  final String playerName;

  /// 球员头像URL
  final String playerLogo;

  /// 所属球队名称
  final String teamName;

  /// 数据总数（如进球数、助攻数）
  final int total;

  HankPlayerRank({
    required this.playerId,
    required this.rankName,
    required this.position,
    required this.playerName,
    required this.playerLogo,
    required this.teamName,
    required this.total,
  });

  /// 从JSON解析
  factory HankPlayerRank.fromJson(Map<String, dynamic> json) {
    return HankPlayerRank(
      playerId: json['player_id'] as int? ?? 0,
      rankName: json['rank_name'] as String? ?? '',
      position: json['position'] as int? ?? 0,
      playerName: json['player_name'] as String? ?? '',
      playerLogo: (json['player_logo'] as String?)?.trim() ?? '',
      teamName: json['team_name'] as String? ?? '',
      total: json['total'] as int? ?? 0,
    );
  }
}

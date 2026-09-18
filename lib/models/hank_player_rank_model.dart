/// HankPlayerRank: Player StatsDatamodel
/// for displayPlayerinsomeeachcategorytypedownrankinfo（e.g.Goalsboard、assistsboard）
class HankPlayerRank {
  /// PlayeruniqueID
  final int playerId;

  /// rankrowcategorytypename（e.g. Goals）
  final String rankName;

  /// rankPosition
  final int position;

  /// Playername
  final String playerName;

  /// PlayeravatarURL
  final String playerLogo;

  /// belongs toTeamname
  final String teamName;

  /// Datatotalcount（e.g.Goalscount、assistscount）
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

  /// fromJSONparse
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

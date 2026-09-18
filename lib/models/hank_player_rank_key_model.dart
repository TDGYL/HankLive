/// HankPlayerRankKey: Player StatsmenuKeymodel
/// usedescriptionPlayer Statscategorytypemenuitem（e.g.Goals、assistsetc）
class HankPlayerRankKey {
  /// rankrowcategorytypeKey（e.g. k_goals、k_assists）
  final String key;

  /// rankrowcategorytypename（e.g. Goals、assists）
  final String name;

  HankPlayerRankKey({
    required this.key,
    required this.name,
  });

  /// fromJSONparse
  factory HankPlayerRankKey.fromJson(Map<String, dynamic> json) {
    return HankPlayerRankKey(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// HankPlayerRankKey: 球员排行菜单Key模型
/// 用于描述球员排行的分类菜单项（如进球、助攻等）
class HankPlayerRankKey {
  /// 排行分类Key（如 k_goals、k_assists）
  final String key;

  /// 排行分类名称（如 进球、助攻）
  final String name;

  HankPlayerRankKey({
    required this.key,
    required this.name,
  });

  /// 从JSON解析
  factory HankPlayerRankKey.fromJson(Map<String, dynamic> json) {
    return HankPlayerRankKey(
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

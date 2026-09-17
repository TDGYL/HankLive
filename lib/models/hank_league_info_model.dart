/// HankLeagueInfo: 联赛信息模型
/// 对应接口 GET /api/livespeed/football/competition/list 返回的数据元素
class HankLeagueInfo {
  /// 联赛ID
  final int id;

  /// 联赛名称
  final String name;

  /// 联赛标识符（如 "O"、"D" 等）
  final String cap;

  /// 是否为主联赛（1=是, 0=否）
  final int main;

  /// 联赛Logo URL
  final String logo;

  HankLeagueInfo({
    required this.id,
    required this.name,
    required this.cap,
    required this.main,
    required this.logo,
  });

  /// 从JSON映射
  factory HankLeagueInfo.fromJson(Map<String, dynamic> json) {
    return HankLeagueInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      cap: json['cap'] as String? ?? '',
      main: json['main'] as int? ?? 0,
      logo: json['logo'] as String? ?? '',
    );
  }
}
/// HankSeasonInfo: 赛季信息模型
/// 对应接口 GET /api/livespeed/football/competition/season-list 返回的数据元素
class HankSeasonInfo {
  /// 赛季ID
  final int seasonId;

  /// 赛季年份（如 "2024-2025"）
  final String year;

  /// 是否为当前赛季（1=是, 0=否）
  final int isCurrent;

  HankSeasonInfo({
    required this.seasonId,
    required this.year,
    required this.isCurrent,
  });

  /// 从JSON映射
  factory HankSeasonInfo.fromJson(Map<String, dynamic> json) {
    return HankSeasonInfo(
      seasonId: json['season_id'] as int? ?? 0,
      year: json['year'] as String? ?? '',
      isCurrent: json['is_current'] as int? ?? 0,
    );
  }
}
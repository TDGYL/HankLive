/// HankSeasonInfo: Seasoninfomodel
/// maps to API GET /api/livespeed/football/competition/season-list BackDataelement
class HankSeasonInfo {
  /// SeasonID
  final int seasonId;

  /// Seasonyear（e.g. "2024-2025"）
  final String year;

  /// is currentSeason（1=is, 0=no）
  final int isCurrent;

  HankSeasonInfo({
    required this.seasonId,
    required this.year,
    required this.isCurrent,
  });

  /// fromJSONmapping
  factory HankSeasonInfo.fromJson(Map<String, dynamic> json) {
    return HankSeasonInfo(
      seasonId: json['season_id'] as int? ?? 0,
      year: json['year'] as String? ?? '',
      isCurrent: json['is_current'] as int? ?? 0,
    );
  }
}
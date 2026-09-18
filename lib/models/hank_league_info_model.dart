/// HankLeagueInfo: Leagueinfomodel
/// maps to API GET /api/livespeed/football/competition/list BackDataelement
class HankLeagueInfo {
  /// LeagueID
  final int id;

  /// Leaguename
  final String name;

  /// Leagueidentifier（e.g. "O"、"D" etc）
  final String cap;

  /// whetherishomeLeague（1=is, 0=no）
  final int main;

  /// LeagueLogo URL
  final String logo;

  HankLeagueInfo({
    required this.id,
    required this.name,
    required this.cap,
    required this.main,
    required this.logo,
  });

  /// fromJSONmapping
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
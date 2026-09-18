/// TeamModel: Teaminfomodel
/// storeTeamID、name、short name、team color、Logoetcbaseinfo
class TeamModel {
  /// TeamuniqueID
  final String teamId;

  /// TeamChineseallname
  final String teamName;

  /// TeamEnglish abbreviation（e.g. ARS / CHE）
  final String teamShort;

  /// team logo imageURL（canempty，use initial as placeholder）
  final String? logoUrl;

  /// teamhomecolor（usefor initial placeholder background）
  final int primaryColor;

  /// team text color（usefor initial placeholder text）
  final int textColor;

  TeamModel({
    required this.teamId,
    required this.teamName,
    required this.teamShort,
    this.logoUrl,
    this.primaryColor = 0xFFF3E8FF,
    this.textColor = 0xFF7C3AED,
  });

  /// fromJSONparse
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      teamId: json['teamId'] ?? '',
      teamName: json['teamName'] ?? '',
      teamShort: json['teamShort'] ?? '',
      logoUrl: json['logoUrl'],
      primaryColor: json['primaryColor'] ?? 0xFFF3E8FF,
      textColor: json['textColor'] ?? 0xFF7C3AED,
    );
  }

  /// convert toJSON
  Map<String, dynamic> toJson() {
    return {
      'teamId': teamId,
      'teamName': teamName,
      'teamShort': teamShort,
      'logoUrl': logoUrl,
      'primaryColor': primaryColor,
      'textColor': textColor,
    };
  }
}

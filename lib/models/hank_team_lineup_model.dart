/// HankTeamLineupGroup: TeamLineupgroupingmodel
/// maps to API GET /api/livespeed/football/team/lineup Backcountgroupelement
/// byPositiongrouping（Coach/F/M/D/G），each group hasPlayerlist
class HankTeamLineupGroup {
  /// Positioncode（Coach=Coach, F=before, M=halftime, D=defender, G=goalkeeper）
  final String? position;

  /// Playerlist
  final List<HankTeamPlayer>? personList;

  HankTeamLineupGroup({this.position, this.personList});

  /// fromJSONparse
  /// field mapping：person_list→personList
  factory HankTeamLineupGroup.fromJson(Map<String, dynamic> json) {
    return HankTeamLineupGroup(
      position: json['position'] as String?,
      personList: json['person_list'] != null
          ? (json['person_list'] as List)
              .map((e) => HankTeamPlayer.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// PositionChinesename
  String get positionName {
    switch (position) {
      case 'Coach':
        return 'Coach';
      case 'F':
        return 'before';
      case 'M':
        return 'halftime';
      case 'D':
        return 'defender';
      case 'G':
        return 'goalkeeper';
      default:
        return position ?? '';
    }
  }
}

/// HankTeamPlayer: Playerinfomodel
/// containsPlayername、Number、Position、Goalscount、appearancecountetc
class HankTeamPlayer {
  /// PlayerID
  final int? id;

  /// Playername
  final String? name;

  /// PlayeravatarURL
  final String? logo;

  /// Positioncode
  final String? position;

  /// jerseyNumber
  final int? shirtNumber;

  /// Goalscount
  final int? goals;

  /// appearancetimecount
  final int? matches;

  HankTeamPlayer({
    this.id,
    this.name,
    this.logo,
    this.position,
    this.shirtNumber,
    this.goals,
    this.matches,
  });

  /// fromJSONparse
  /// field mapping：shirt_number→shirtNumber
  factory HankTeamPlayer.fromJson(Map<String, dynamic> json) {
    return HankTeamPlayer(
      id: json['id'] != null ? (json['id'] as num).toInt() : null,
      name: json['name'] as String?,
      logo: json['logo'] as String?,
      position: json['position'] as String?,
      shirtNumber: json['shirt_number'] != null
          ? (json['shirt_number'] as num).toInt()
          : null,
      goals: json['goals'] != null ? (json['goals'] as num).toInt() : null,
      matches:
          json['matches'] != null ? (json['matches'] as num).toInt() : null,
    );
  }
}

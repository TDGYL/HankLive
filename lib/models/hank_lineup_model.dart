/// HankLineupIncident: Playerevent（Goals/Yellow Cards/Red Cardsetc）
/// maps toAPIfield：incidents countgroupinelement
class HankLineupIncident {
  /// eventtype（0: unknown, 1: Goals, 2: Yellow Cards, 3: Red Cards, 4: substitution etc）
  final int type;

  /// eventTime（e.g.: "45'"）
  final String time;

  HankLineupIncident({
    required this.type,
    required this.time,
  });

  /// fromJSONmapping
  factory HankLineupIncident.fromJson(Map<String, dynamic> json) {
    return HankLineupIncident(
      type: json['type'] as int? ?? 0,
      time: json['time'] as String? ?? '',
    );
  }
}

/// HankLineupPlayer: LineupPlayermodel
/// maps toAPIfield：first/sub → home/away countgroupinelement
class HankLineupPlayer {
  /// PlayerID
  final int playerId;

  /// PlayeravatarURL
  final String playerLogo;

  /// Playername
  final String playerName;

  /// PlayerPosition（e.g.: "GK", "DF", "MF", "FW"）
  final String position;

  /// Xcoordinates（0-100，percentcategorymatch，useStadiumposition）
  final double x;

  /// Ycoordinates（0-100，percentcategorymatch，useStadiumposition）
  final double y;

  /// rating
  final String rating;

  /// jerseyNumber
  final int shirtNumber;

  /// eventlist（Goals、Yellow Cardsetc）
  final List<HankLineupIncident> incidents;

  HankLineupPlayer({
    required this.playerId,
    required this.playerLogo,
    required this.playerName,
    required this.position,
    required this.x,
    required this.y,
    required this.rating,
    required this.shirtNumber,
    required this.incidents,
  });

  /// fromJSONmapping
  factory HankLineupPlayer.fromJson(Map<String, dynamic> json) {
    return HankLineupPlayer(
      playerId: json['player_id'] as int? ?? 0,
      playerLogo: json['player_logo'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
      position: json['position'] as String? ?? '',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      rating: json['rating'] as String? ?? '',
      shirtNumber: json['shirt_number'] as int? ?? 0,
      incidents: (json['incidents'] as List<dynamic>?)
              ?.map((e) => HankLineupIncident.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// HankLineupInjuryPlayer: injuredPlayermodel
/// maps toAPIfield：injury → home/away countgroupinelement
class HankLineupInjuryPlayer {
  /// PlayerID
  final int playerId;

  /// PlayeravatarURL
  final String playerLogo;

  /// Playername
  final String playerName;

  /// injuredtype
  final String type;

  /// injuredreason
  final String reason;

  /// PlayerPosition
  final String position;

  HankLineupInjuryPlayer({
    required this.playerId,
    required this.playerLogo,
    required this.playerName,
    required this.type,
    required this.reason,
    required this.position,
  });

  /// fromJSONmapping
  factory HankLineupInjuryPlayer.fromJson(Map<String, dynamic> json) {
    return HankLineupInjuryPlayer(
      playerId: json['player_id'] as int? ?? 0,
      playerLogo: json['player_logo'] as String? ?? '',
      playerName: json['player_name'] as String? ?? '',
      type: (json['type'] ?? '').toString(),
      reason: json['reason'] as String? ?? '',
      position: json['position'] as String? ?? '',
    );
  }
}

/// HankLineupCoach: Coachmodel
/// maps toAPIfield：home_coach / away_coach
class HankLineupCoach {
  /// CoachID
  final int id;

  /// CoachavatarURL
  final String logo;

  /// Coachname
  final String name;

  HankLineupCoach({
    required this.id,
    required this.logo,
    required this.name,
  });

  /// fromJSONmapping
  factory HankLineupCoach.fromJson(Map<String, dynamic> json) {
    return HankLineupCoach(
      id: json['id'] as int? ?? 0,
      logo: json['logo'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}

/// HankLineupTeam: singlesingleTeamLineupData（starter/substitute/injured）
class HankLineupTeam {
  /// starterPlayerlist
  final List<HankLineupPlayer> first;

  /// substitutePlayerlist
  final List<HankLineupPlayer> sub;

  /// injuredPlayerlist
  final List<HankLineupInjuryPlayer> injury;

  HankLineupTeam({
    required this.first,
    required this.sub,
    required this.injury,
  });
}

/// HankLineupData: LineupfullDatamodel
/// maps toAPIBackdataobject
/// contains：first（starter）、sub（substitute）、injury（injured）、Coach、formation、Value
class HankLineupData {
  /// Homestarter
  final List<HankLineupPlayer> homeFirst;

  /// Awaystarter
  final List<HankLineupPlayer> awayFirst;

  /// Homesubstitute
  final List<HankLineupPlayer> homeSub;

  /// Awaysubstitute
  final List<HankLineupPlayer> awaySub;

  /// Homeinjured
  final List<HankLineupInjuryPlayer> homeInjury;

  /// Awayinjured
  final List<HankLineupInjuryPlayer> awayInjury;

  /// HomeCoach
  final HankLineupCoach homeCoach;

  /// AwayCoach
  final HankLineupCoach awayCoach;

  /// Homeformation（e.g.: "4-3-3"）
  final String homeFormation;

  /// Awayformation
  final String awayFormation;

  /// HomeValue
  final int homeMarketValue;

  /// AwayValue
  final int awayMarketValue;

  HankLineupData({
    required this.homeFirst,
    required this.awayFirst,
    required this.homeSub,
    required this.awaySub,
    required this.homeInjury,
    required this.awayInjury,
    required this.homeCoach,
    required this.awayCoach,
    required this.homeFormation,
    required this.awayFormation,
    required this.homeMarketValue,
    required this.awayMarketValue,
  });

  /// fromJSONmapping
  /// datastructure: { first: { home: [...], away: [...] }, sub: { home: [...], away: [...] }, injury: {...}, home_coach: {...}, away_coach: {...}, home_formation: "4-3-3", away_formation: "4-3-3", home_market_value: 0, away_market_value: 0 }
  factory HankLineupData.fromJson(Map<String, dynamic> json) {
    // starterLineup
    final firstMap = json['first'] as Map<String, dynamic>? ?? {};
    final homeFirstRaw = firstMap['home'] as List<dynamic>? ?? [];
    final awayFirstRaw = firstMap['away'] as List<dynamic>? ?? [];

    // bench
    final subMap = json['sub'] as Map<String, dynamic>? ?? {};
    final homeSubRaw = subMap['home'] as List<dynamic>? ?? [];
    final awaySubRaw = subMap['away'] as List<dynamic>? ?? [];

    // injured
    final injuryMap = json['injury'] as Map<String, dynamic>? ?? {};
    final homeInjuryRaw = injuryMap['home'] as List<dynamic>? ?? [];
    final awayInjuryRaw = injuryMap['away'] as List<dynamic>? ?? [];

    return HankLineupData(
      homeFirst: homeFirstRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      awayFirst: awayFirstRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeSub: homeSubRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      awaySub: awaySubRaw
          .map((e) => HankLineupPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeInjury: homeInjuryRaw
          .map((e) => HankLineupInjuryPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      awayInjury: awayInjuryRaw
          .map((e) => HankLineupInjuryPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      homeCoach: HankLineupCoach.fromJson(
          json['home_coach'] as Map<String, dynamic>? ?? {}),
      awayCoach: HankLineupCoach.fromJson(
          json['away_coach'] as Map<String, dynamic>? ?? {}),
      homeFormation: json['home_formation'] as String? ?? '',
      awayFormation: json['away_formation'] as String? ?? '',
      homeMarketValue: json['home_market_value'] as int? ?? 0,
      awayMarketValue: json['away_market_value'] as int? ?? 0,
    );
  }
}

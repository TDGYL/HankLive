/// HankOddsData: OddsDatamodel
/// maps to API GET /api/livespeed/football/match/odds BackDatabody
/// containsfour typesHandicaptypebookmakerBookmakerOddslist
class HankOddsData {
  /// AHhandicapgoal（WL）Oddslist
  final List<HankOddsCompany>? asia;

  /// 1X2（WDL）Oddslist
  final List<HankOddsCompany>? eu;

  /// O/Ugoal（totalGoals）Oddslist
  final List<HankOddsCompany>? bs;

  /// CornersOddslist
  final List<HankOddsCompany>? cr;

  HankOddsData({this.asia, this.eu, this.bs, this.cr});

  /// fromJSONparse
  /// field mapping：asia=handicapgoal, eu=WDL, bs=totalGoals, cr=Corners
  factory HankOddsData.fromJson(Map<String, dynamic> json) {
    return HankOddsData(
      asia: _parseList(json['asia']),
      eu: _parseList(json['eu']),
      bs: _parseList(json['bs']),
      cr: _parseList(json['cr']),
    );
  }

  /// parseOddsBookmakerlist
  static List<HankOddsCompany>? _parseList(dynamic data) {
    if (data == null || data is! List) return null;
    return data.map((e) => HankOddsCompany.fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// HankOddsCompany: bookmakerBookmakerOddsData
/// containsBookmakernameand threeeachphaseOdds（Opening/Live/livematch）
class HankOddsCompany {
  /// bookmakerBookmakername
  final String? name;

  /// bookmakerBookmakerID
  final String? companyId;

  /// OpeningOdds
  final HankOddsDetail? ini;

  /// livematchOdds（Pre）
  final HankOddsDetail? pre;

  /// LiveOdds（Live）
  final HankOddsDetail? spot;

  HankOddsCompany({this.name, this.companyId, this.ini, this.pre, this.spot});

  /// fromJSONparse
  /// inifield compatible init writemethod
  factory HankOddsCompany.fromJson(Map<String, dynamic> json) {
    return HankOddsCompany(
      name: json['name']?.toString(),
      companyId: json['company_id']?.toString(),
      ini: json['ini'] != null
          ? HankOddsDetail.fromJson(json['ini'])
          : (json['init'] != null ? HankOddsDetail.fromJson(json['init']) : null),
      pre: json['pre'] != null ? HankOddsDetail.fromJson(json['pre']) : null,
      spot: json['spot'] != null ? HankOddsDetail.fromJson(json['spot']) : null,
    );
  }
}

/// HankOddsDetail: singleeachOddsdetails
/// home/draw/away maps tohomeW/Dmatch/awayW（orbig/Handicap/under）
class HankOddsDetail {
  /// homeW（orover）Odds
  final String? home;

  /// Dmatch（orHandicapline）Odds
  final String? draw;

  /// awayW（orundergoal）Odds
  final String? away;

  HankOddsDetail({this.home, this.draw, this.away});

  /// fromJSONparse
  factory HankOddsDetail.fromJson(Map<String, dynamic> json) {
    return HankOddsDetail(
      home: json['home']?.toString(),
      draw: json['draw']?.toString(),
      away: json['away']?.toString(),
    );
  }
}

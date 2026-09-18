/// HankOddsHistoryData: oddscounthistoryDatamodel
/// maps to API GET /api/livespeed/football/match/odd-histories BackDatabody
/// containsfour typesHandicaptypehistoryOddslist（asia/eu/bs/cr）
class HankOddsHistoryData {
  /// AHhandicapgoal（WL）historyOddslist
  final List<HankOddsHistoryItem>? asia;

  /// 1X2（WDL）historyOddslist
  final List<HankOddsHistoryItem>? eu;

  /// O/Ugoal（totalGoals）historyOddslist
  final List<HankOddsHistoryItem>? bs;

  /// CornershistoryOddslist
  final List<HankOddsHistoryItem>? cr;

  HankOddsHistoryData({this.asia, this.eu, this.bs, this.cr});

  /// fromJSONparse
  /// field mapping：asia=handicapgoal, eu=WDL, bs=totalGoals, cr=Corners
  factory HankOddsHistoryData.fromJson(Map<String, dynamic> json) {
    return HankOddsHistoryData(
      asia: _parseList(json['asia']),
      eu: _parseList(json['eu']),
      bs: _parseList(json['bs']),
      cr: _parseList(json['cr']),
    );
  }

  /// parse historyOddslist
  /// [data] rawJSONcountgroupData
  /// Back HankOddsHistoryItem list，emptyDataBacknull
  static List<HankOddsHistoryItem>? _parseList(dynamic data) {
    if (data == null || data is! List) return null;
    return data
        .map((e) => HankOddsHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// HankOddsHistoryItem: singleoddscounthistoryrecordin
/// records aTimepointOddschange snapshot
class HankOddsHistoryItem {
  /// updateTimetimestamp（secondslevel）
  final int? updatedAt;

  /// matchoffsetTime（e.g.: "HT", "55'", "Open"）
  final String? matchOffset;

  /// homeW（orover）Oddsvalue
  final String? home;

  /// Dmatch（orHandicapline）Oddsvalue
  final String? draw;

  /// awayW（orundergoal）Oddsvalue
  final String? away;

  /// Handicapstatus（0=normal, 1=pausedetc）
  final int? state;

  /// is closed（0=notclosed, 1=alreadyclosed）
  final int? closed;

  /// whenbeforescore（e.g.: "1-0"）
  final String? score;

  HankOddsHistoryItem({
    this.updatedAt,
    this.matchOffset,
    this.home,
    this.draw,
    this.away,
    this.state,
    this.closed,
    this.score,
  });

  /// fromJSONparse
  /// field mapping：updated_at→updatedAt, match_offset→matchOffset, itsremaindermapping
  factory HankOddsHistoryItem.fromJson(Map<String, dynamic> json) {
    return HankOddsHistoryItem(
      updatedAt:
          json['updated_at'] != null ? (json['updated_at'] as num).toInt() : null,
      matchOffset: json['match_offset']?.toString(),
      home: json['home']?.toString(),
      draw: json['draw']?.toString(),
      away: json['away']?.toString(),
      state: json['state'] != null ? (json['state'] as num).toInt() : null,
      closed: json['closed'] != null ? (json['closed'] as num).toInt() : null,
      score: json['score']?.toString(),
    );
  }
}

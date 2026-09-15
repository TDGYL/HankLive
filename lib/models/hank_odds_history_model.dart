/// HankOddsHistoryData: 指数历史数据模型
/// 对应接口 GET /api/livespeed/football/match/odd-histories 返回的数据体
/// 包含四种盘口类型的历史赔率列表（asia/eu/bs/cr）
class HankOddsHistoryData {
  /// 亚盘让球（胜负）历史赔率列表
  final List<HankOddsHistoryItem>? asia;

  /// 欧赔（胜平负）历史赔率列表
  final List<HankOddsHistoryItem>? eu;

  /// 大小球（总进球）历史赔率列表
  final List<HankOddsHistoryItem>? bs;

  /// 角球历史赔率列表
  final List<HankOddsHistoryItem>? cr;

  HankOddsHistoryData({this.asia, this.eu, this.bs, this.cr});

  /// 从JSON解析
  /// 字段映射：asia=让球, eu=胜平负, bs=总进球, cr=角球
  factory HankOddsHistoryData.fromJson(Map<String, dynamic> json) {
    return HankOddsHistoryData(
      asia: _parseList(json['asia']),
      eu: _parseList(json['eu']),
      bs: _parseList(json['bs']),
      cr: _parseList(json['cr']),
    );
  }

  /// 解析历史赔率列表
  /// [data] 原始JSON数组数据
  /// 返回 HankOddsHistoryItem 列表，空数据返回null
  static List<HankOddsHistoryItem>? _parseList(dynamic data) {
    if (data == null || data is! List) return null;
    return data
        .map((e) => HankOddsHistoryItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// HankOddsHistoryItem: 单条指数历史记录
/// 记录某个时间点的赔率变化快照
class HankOddsHistoryItem {
  /// 更新时间戳（秒级）
  final int? updatedAt;

  /// 比赛偏移时间（如: "HT", "55'", "Open"）
  final String? matchOffset;

  /// 主胜（或大球）赔率值
  final String? home;

  /// 平局（或盘口线）赔率值
  final String? draw;

  /// 客胜（或小球）赔率值
  final String? away;

  /// 盘口状态（0=正常, 1=暂停等）
  final int? state;

  /// 是否已收盘（0=未收盘, 1=已收盘）
  final int? closed;

  /// 当前比分（如: "1-0"）
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

  /// 从JSON解析
  /// 字段映射：updated_at→updatedAt, match_offset→matchOffset, 其余直接映射
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

/// HankOddsData: 指数分析数据模型
/// 对应接口 GET /api/livespeed/football/match/odds 返回的数据体
/// 包含四种盘口类型的博彩公司赔率列表
class HankOddsData {
  /// 亚盘让球（胜负）赔率列表
  final List<HankOddsCompany>? asia;

  /// 欧赔（胜平负）赔率列表
  final List<HankOddsCompany>? eu;

  /// 大小球（总进球）赔率列表
  final List<HankOddsCompany>? bs;

  /// 角球赔率列表
  final List<HankOddsCompany>? cr;

  HankOddsData({this.asia, this.eu, this.bs, this.cr});

  /// 从JSON解析
  /// 字段映射：asia=让球, eu=胜平负, bs=总进球, cr=角球
  factory HankOddsData.fromJson(Map<String, dynamic> json) {
    return HankOddsData(
      asia: _parseList(json['asia']),
      eu: _parseList(json['eu']),
      bs: _parseList(json['bs']),
      cr: _parseList(json['cr']),
    );
  }

  /// 解析赔率公司列表
  static List<HankOddsCompany>? _parseList(dynamic data) {
    if (data == null || data is! List) return null;
    return data.map((e) => HankOddsCompany.fromJson(e as Map<String, dynamic>)).toList();
  }
}

/// HankOddsCompany: 博彩公司赔率数据
/// 包含公司名称及三个阶段的赔率（初盘/即时/临场）
class HankOddsCompany {
  /// 博彩公司名称
  final String? name;

  /// 博彩公司ID
  final String? companyId;

  /// 初盘赔率
  final HankOddsDetail? ini;

  /// 临场赔率（Pre）
  final HankOddsDetail? pre;

  /// 即时赔率（Live）
  final HankOddsDetail? spot;

  HankOddsCompany({this.name, this.companyId, this.ini, this.pre, this.spot});

  /// 从JSON解析
  /// ini字段兼容 init 写法
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

/// HankOddsDetail: 单个赔率明细
/// home/draw/away 对应主胜/平局/客胜（或大/盘口/小）
class HankOddsDetail {
  /// 主胜（或大球）赔率
  final String? home;

  /// 平局（或盘口线）赔率
  final String? draw;

  /// 客胜（或小球）赔率
  final String? away;

  HankOddsDetail({this.home, this.draw, this.away});

  /// 从JSON解析
  factory HankOddsDetail.fromJson(Map<String, dynamic> json) {
    return HankOddsDetail(
      home: json['home']?.toString(),
      draw: json['draw']?.toString(),
      away: json['away']?.toString(),
    );
  }
}

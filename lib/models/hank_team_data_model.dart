/// HankTeamData: 球队详情数据模型
/// 对应接口 GET /api/livespeed/football/team/data 返回的数据体
/// 包含球队基本信息、联赛、场馆、教练、身价等
class HankTeamData {
  /// 联赛ID
  final int? competitionId;

  /// 联赛名称
  final String? competitionName;

  /// 球队名称
  final String? name;

  /// 球队Logo URL
  final String? logo;

  /// 成立年份
  final int? foundationTime;

  /// 国家名称
  final String? countryName;

  /// 国家旗帜URL
  final String? countryLogo;

  /// 主场名称
  final String? venueName;

  /// 主场容量
  final int? venueCapacity;

  /// 主教练姓名
  final String? managerName;

  /// 主教练头像URL
  final String? managerLogo;

  /// 球队总身价（欧元）
  final int? marketValue;

  /// 是否已订阅
  final bool? isSubscribe;

  /// 官方网站
  final String? website;

  HankTeamData({
    this.competitionId,
    this.competitionName,
    this.name,
    this.logo,
    this.foundationTime,
    this.countryName,
    this.countryLogo,
    this.venueName,
    this.venueCapacity,
    this.managerName,
    this.managerLogo,
    this.marketValue,
    this.isSubscribe,
    this.website,
  });

  /// 从JSON解析
  /// 字段映射：competition_id→competitionId, foundation_time→foundationTime 等
  factory HankTeamData.fromJson(Map<String, dynamic> json) {
    return HankTeamData(
      competitionId: json['competition_id'] != null
          ? (json['competition_id'] as num).toInt()
          : null,
      competitionName: json['competition_name']?.toString(),
      name: json['name']?.toString(),
      logo: json['logo']?.toString(),
      foundationTime: json['foundation_time'] != null
          ? (json['foundation_time'] as num).toInt()
          : null,
      countryName: json['country_name']?.toString(),
      countryLogo: json['country_logo']?.toString(),
      venueName: json['venue_name']?.toString(),
      venueCapacity: json['venue_capacity'] != null
          ? (json['venue_capacity'] as num).toInt()
          : null,
      managerName: json['manager_name']?.toString(),
      managerLogo: json['manager_logo']?.toString(),
      marketValue: json['market_value'] != null
          ? (json['market_value'] as num).toInt()
          : null,
      isSubscribe: json['is_subscribe'] as bool?,
      website: json['website']?.toString(),
    );
  }
}

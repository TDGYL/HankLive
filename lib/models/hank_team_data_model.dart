/// HankTeamData: TeamDetailsDatamodel
/// maps to API GET /api/livespeed/football/team/data BackDatabody
/// containsTeamInfo、League、matchvenue、Coach、Valueetc
class HankTeamData {
  /// LeagueID
  final int? competitionId;

  /// Leaguename
  final String? competitionName;

  /// Teamname
  final String? name;

  /// TeamLogo URL
  final String? logo;

  /// foundedyear
  final int? foundationTime;

  /// Countryname
  final String? countryName;

  /// CountryflagURL
  final String? countryLogo;

  /// homematchname
  final String? venueName;

  /// homematchcapacitycount
  final int? venueCapacity;

  /// homeCoachname
  final String? managerName;

  /// homeCoachavatarURL
  final String? managerLogo;

  /// TeamtotalValue（EUR）
  final int? marketValue;

  /// whetheralreadysubscribe
  final bool? isSubscribe;

  /// official website
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

  /// fromJSONparse
  /// field mapping：competition_id→competitionId, foundation_time→foundationTime etc
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

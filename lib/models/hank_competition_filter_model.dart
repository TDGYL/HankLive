/// HankCompetition: LeaguefilterLeagueentitybody
/// containsLeagueID、logo、name、matchmatchtime
class HankCompetition {
  /// LeagueID
  final int id;

  /// Leaguelogo URL
  final String logo;

  /// Leaguename
  final String name;

  /// matchmatchtime
  final int matches;

  HankCompetition({
    required this.id,
    required this.logo,
    required this.name,
    required this.matches,
  });

  /// from JSON Map constructor
  factory HankCompetition.fromJson(Map<String, dynamic> json) {
    return HankCompetition(
      id: json['id'] as int? ?? 0,
      logo: json['logo'] as String? ?? '',
      name: json['name'] as String? ?? '',
      matches: json['matches'] as int? ?? 0,
    );
  }
}

/// HankFilterCategory: Leaguefilter category entity
/// containscategorytypename、whetherhomecategorytype、Leaguelist
class HankFilterCategory {
  /// categorytypename
  final String name;

  /// whetherhomecategorytype
  final bool main;

  /// thiscategorytypedownLeaguelist
  final List<HankCompetition> competitions;

  HankFilterCategory({
    required this.name,
    required this.main,
    required this.competitions,
  });

  /// from JSON Map constructor
  factory HankFilterCategory.fromJson(Map<String, dynamic> json) {
    final competitionList = json['competitions'] as List? ?? [];
    return HankFilterCategory(
      name: json['name'] as String? ?? '',
      main: json['main'] as bool? ?? false,
      competitions: competitionList
          .map((e) => HankCompetition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// HankLotteryCategory: lotterycategorytypeentitybody
/// containscategorytypename、type、whetherhomecategorytype、Leaguelist
class HankLotteryCategory {
  /// categorytypename
  final String name;

  /// type
  final int type;

  /// whetherhomecategorytype
  final bool main;

  /// thiscategorytypedownLeaguelist
  final List<HankCompetition> competitions;

  HankLotteryCategory({
    required this.name,
    required this.type,
    required this.main,
    required this.competitions,
  });

  /// from JSON Map constructor
  factory HankLotteryCategory.fromJson(Map<String, dynamic> json) {
    final competitionList = json['competitions'] as List? ?? [];
    return HankLotteryCategory(
      name: json['name'] as String? ?? '',
      type: json['type'] as int? ?? 0,
      main: json['main'] as bool? ?? false,
      competitions: competitionList
          .map((e) => HankCompetition.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// HankCompetitionFilterData: LeaguefilterAPIBackDatabody
/// containscategorytypelistandlotterycategorytypelist
class HankCompetitionFilterData {
  /// categorytypelist（menu）
  final List<HankFilterCategory> categories;

  /// lotterycategorytypelist
  final List<HankLotteryCategory> lotteries;

  HankCompetitionFilterData({
    required this.categories,
    required this.lotteries,
  });

  /// from JSON Map constructor
  factory HankCompetitionFilterData.fromJson(Map<String, dynamic> json) {
    final categoryList = json['categories'] as List? ?? [];
    final lotteryList = json['lotteries'] as List? ?? [];
    return HankCompetitionFilterData(
      categories: categoryList
          .map((e) => HankFilterCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      lotteries: lotteryList
          .map((e) => HankLotteryCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

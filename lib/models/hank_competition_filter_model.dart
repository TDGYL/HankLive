/// HankCompetition: 联赛筛选中的联赛实体
/// 包含联赛ID、logo、名称、比赛场次
class HankCompetition {
  /// 联赛ID
  final int id;

  /// 联赛logo URL
  final String logo;

  /// 联赛名称
  final String name;

  /// 比赛场次
  final int matches;

  HankCompetition({
    required this.id,
    required this.logo,
    required this.name,
    required this.matches,
  });

  /// 从 JSON Map 构造
  factory HankCompetition.fromJson(Map<String, dynamic> json) {
    return HankCompetition(
      id: json['id'] as int? ?? 0,
      logo: json['logo'] as String? ?? '',
      name: json['name'] as String? ?? '',
      matches: json['matches'] as int? ?? 0,
    );
  }
}

/// HankFilterCategory: 联赛筛选分类实体
/// 包含分类名称、是否主分类、联赛列表
class HankFilterCategory {
  /// 分类名称
  final String name;

  /// 是否主分类
  final bool main;

  /// 该分类下的联赛列表
  final List<HankCompetition> competitions;

  HankFilterCategory({
    required this.name,
    required this.main,
    required this.competitions,
  });

  /// 从 JSON Map 构造
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

/// HankLotteryCategory: 彩票分类实体
/// 包含分类名称、类型、是否主分类、联赛列表
class HankLotteryCategory {
  /// 分类名称
  final String name;

  /// 类型
  final int type;

  /// 是否主分类
  final bool main;

  /// 该分类下的联赛列表
  final List<HankCompetition> competitions;

  HankLotteryCategory({
    required this.name,
    required this.type,
    required this.main,
    required this.competitions,
  });

  /// 从 JSON Map 构造
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

/// HankCompetitionFilterData: 联赛筛选接口返回数据体
/// 包含分类列表和彩票分类列表
class HankCompetitionFilterData {
  /// 分类列表（菜单）
  final List<HankFilterCategory> categories;

  /// 彩票分类列表
  final List<HankLotteryCategory> lotteries;

  HankCompetitionFilterData({
    required this.categories,
    required this.lotteries,
  });

  /// 从 JSON Map 构造
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

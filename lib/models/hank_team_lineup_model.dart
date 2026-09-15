/// HankTeamLineupGroup: 球队阵容分组模型
/// 对应接口 GET /api/livespeed/football/team/lineup 返回的数组元素
/// 按位置分组（Coach/F/M/D/G），每组含球员列表
class HankTeamLineupGroup {
  /// 位置代码（Coach=教练, F=前锋, M=中场, D=后卫, G=门将）
  final String? position;

  /// 球员列表
  final List<HankTeamPlayer>? personList;

  HankTeamLineupGroup({this.position, this.personList});

  /// 从JSON解析
  /// 字段映射：person_list→personList
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

  /// 位置中文名称
  String get positionName {
    switch (position) {
      case 'Coach':
        return '教练';
      case 'F':
        return '前锋';
      case 'M':
        return '中场';
      case 'D':
        return '后卫';
      case 'G':
        return '门将';
      default:
        return position ?? '';
    }
  }
}

/// HankTeamPlayer: 球员信息模型
/// 包含球员姓名、号码、位置、进球数、出场数等
class HankTeamPlayer {
  /// 球员ID
  final int? id;

  /// 球员姓名
  final String? name;

  /// 球员头像URL
  final String? logo;

  /// 位置代码
  final String? position;

  /// 球衣号码
  final int? shirtNumber;

  /// 进球数
  final int? goals;

  /// 出场次数
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

  /// 从JSON解析
  /// 字段映射：shirt_number→shirtNumber
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

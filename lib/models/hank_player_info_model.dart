/// HankPlayerTransfer: 球员转会记录模型
/// 描述球员的一次转会信息（转出球队、转入球队、转会费等）
class HankPlayerTransfer {

  /// 安全转换为String，兼容int/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// 转会记录ID
  final int id;

  /// 球员ID
  final int playerId;

  /// 球员名称
  final String playerName;

  /// 球员头像URL
  final String playerLogo;

  /// 转出球队ID
  final int fromTeamId;

  /// 转出球队名称
  final String fromTeamName;

  /// 转出球队Logo URL
  final String fromTeamLogo;

  /// 转入球队ID
  final int toTeamId;

  /// 转入球队名称
  final String toTeamName;

  /// 转入球队Logo URL
  final String toTeamLogo;

  /// 转会类型（1=转会，2=租借结束，3=签约/提拔）
  final int transferType;

  /// 转会时间（ISO 8601）
  final String transferTime;

  /// 转会费
  final int transferFee;

  /// 转会描述
  final String transferDesc;

  HankPlayerTransfer({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.playerLogo,
    required this.fromTeamId,
    required this.fromTeamName,
    required this.fromTeamLogo,
    required this.toTeamId,
    required this.toTeamName,
    required this.toTeamLogo,
    required this.transferType,
    required this.transferTime,
    required this.transferFee,
    required this.transferDesc,
  });

  /// 从JSON解析
  factory HankPlayerTransfer.fromJson(Map<String, dynamic> json) {
    return HankPlayerTransfer(
      id: (json['id'] as num?)?.toInt() ?? 0,
      playerId: (json['player_id'] as num?)?.toInt() ?? 0,
      playerName: _str(json['player_name']),
      playerLogo: _str(json['player_logo']),
      fromTeamId: (json['from_team_id'] as num?)?.toInt() ?? 0,
      fromTeamName: _str(json['from_team_name']),
      fromTeamLogo: _str(json['from_team_logo']),
      toTeamId: (json['to_team_id'] as num?)?.toInt() ?? 0,
      toTeamName: _str(json['to_team_name']),
      toTeamLogo: _str(json['to_team_logo']),
      transferType: (json['transfer_type'] as num?)?.toInt() ?? 0,
      transferTime: _str(json['transfer_time']),
      transferFee: (json['transfer_fee'] as num?)?.toInt() ?? 0,
      transferDesc: _str(json['transfer_desc'], def: '-'),
    );
  }

  /// 获取格式化的转会时间（YYYY-MM-DD）
  String get formattedTime {
    if (transferTime.isEmpty) return '';
    final dt = DateTime.tryParse(transferTime);
    if (dt == null) return transferTime;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// 获取转会类型文本
  String get transferTypeText {
    switch (transferType) {
      case 1:
        return '转会';
      case 2:
        return '租借结束';
      case 3:
        return '签约';
      default:
        return '转会';
    }
  }
}

/// HankPlayerHonorItem: 球员荣誉条目模型
/// 描述球员在某赛季获得的某个荣誉
class HankPlayerHonorItem {

  /// 安全转换为String，兼容int/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// 赛季（如 2018-2019）
  final String season;

  /// 荣誉中文标题
  final String honorTitleZh;

  /// 荣誉Logo URL
  final String honorLogo;

  /// 球队名称
  final String teamName;

  HankPlayerHonorItem({
    required this.season,
    required this.honorTitleZh,
    required this.honorLogo,
    required this.teamName,
  });

  /// 从JSON解析
  factory HankPlayerHonorItem.fromJson(Map<String, dynamic> json) {
    return HankPlayerHonorItem(
      season: _str(json['season']),
      honorTitleZh: _str(json['honor_title_zh']),
      honorLogo: _str(json['honor_logo']),
      teamName: _str(json['team_name']),
    );
  }
}

/// HankPlayerHonorGroup: 球员荣誉分组模型
/// 按荣誉类型分组，包含多条赛季荣誉
class HankPlayerHonorGroup {

  /// 安全转换为String，兼容int/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// 荣誉ID
  final int honorId;

  /// 荣誉标题
  final String honorTitle;

  /// 荣誉条目列表
  final List<HankPlayerHonorItem> list;

  HankPlayerHonorGroup({
    required this.honorId,
    required this.honorTitle,
    required this.list,
  });

  /// 从JSON解析
  factory HankPlayerHonorGroup.fromJson(Map<String, dynamic> json) {
    final rawList = json['list'] as List? ?? [];
    return HankPlayerHonorGroup(
      honorId: (json['honor_id'] as num?)?.toInt() ?? 0,
      honorTitle: _str(json['honor_title']),
      list: rawList
          .map((e) => HankPlayerHonorItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// HankPlayerInfo: 球员详情模型
/// 包含球员基本信息、转会记录、荣誉列表
class HankPlayerInfo {

  /// 安全转换为String，兼容int/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// 球员唯一ID
  final int id;

  /// 所属球队ID
  final int teamId;

  /// 生日（ISO 8601）
  final String birthday;

  /// 年龄
  final int age;

  /// 体重（kg）
  final int weight;

  /// 身高（cm）
  final int height;

  /// 国籍
  final String nationality;

  /// 身价
  final int marketValue;

  /// 身价货币符号
  final String marketValueCurrency;

  /// 合同到期时间（ISO 8601）
  final String contractUntil;

  /// 主要位置（如 F=前锋）
  final String position;

  /// 中文名称
  final String nameZh;

  /// 英文名称
  final String nameEn;

  /// 中文简称
  final String shortNameZh;

  /// 英文简称
  final String shortNameEn;

  /// 球员头像URL
  final String logo;

  /// 国家ID
  final int countryId;

  /// 惯用脚（1=左脚，2=右脚）
  final int preferredFoot;

  /// 位置列表（原始JSON字符串）
  final String positions;

  /// 球队Logo URL
  final String teamLogo;

  /// 国家Logo URL
  final String countryLogo;

  /// 转会记录列表
  final List<HankPlayerTransfer> transferList;

  /// 荣誉列表
  final List<HankPlayerHonorGroup> honorList;

  HankPlayerInfo({
    required this.id,
    required this.teamId,
    required this.birthday,
    required this.age,
    required this.weight,
    required this.height,
    required this.nationality,
    required this.marketValue,
    required this.marketValueCurrency,
    required this.contractUntil,
    required this.position,
    required this.nameZh,
    required this.nameEn,
    required this.shortNameZh,
    required this.shortNameEn,
    required this.logo,
    required this.countryId,
    required this.preferredFoot,
    required this.positions,
    required this.teamLogo,
    required this.countryLogo,
    required this.transferList,
    required this.honorList,
  });

  /// 从JSON解析
  factory HankPlayerInfo.fromJson(Map<String, dynamic> json) {
    final rawTransfers = json['transfer_list'] as List? ?? [];
    final rawHonors = json['honor_list'] as List? ?? [];
    return HankPlayerInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      teamId: (json['team_id'] as num?)?.toInt() ?? 0,
      birthday: _str(json['birthday']),
      age: (json['age'] as num?)?.toInt() ?? 0,
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      height: (json['height'] as num?)?.toInt() ?? 0,
      nationality: _str(json['nationality']),
      marketValue: (json['market_value'] as num?)?.toInt() ?? 0,
      marketValueCurrency: _str(json['market_value_currency']),
      contractUntil: _str(json['contract_until']),
      position: _str(json['position']),
      nameZh: _str(json['name_zh']),
      nameEn: _str(json['name_en']),
      shortNameZh: _str(json['short_name_zh']),
      shortNameEn: _str(json['short_name_en']),
      logo: _str(json['logo']),
      countryId: (json['country_id'] as num?)?.toInt() ?? 0,
      preferredFoot: (json['preferred_foot'] as num?)?.toInt() ?? 0,
      positions: _str(json['positions']),
      teamLogo: _str(json['team_logo']),
      countryLogo: _str(json['country_logo']),
      transferList: rawTransfers
          .map((e) => HankPlayerTransfer.fromJson(e as Map<String, dynamic>))
          .toList(),
      honorList: rawHonors
          .map((e) => HankPlayerHonorGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取格式化的生日（YYYY-MM-DD）
  String get formattedBirthday {
    if (birthday.isEmpty) return '';
    final dt = DateTime.tryParse(birthday);
    if (dt == null) return birthday;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// 获取格式化的合同到期时间（YYYY-MM-DD）
  String get formattedContractUntil {
    if (contractUntil.isEmpty) return '';
    final dt = DateTime.tryParse(contractUntil);
    if (dt == null) return contractUntil;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// 获取惯用脚文本
  String get preferredFootText {
    switch (preferredFoot) {
      case 1:
        return '左脚';
      case 2:
        return '右脚';
      default:
        return '未知';
    }
  }

  /// 获取位置文本
  String get positionText {
    switch (position) {
      case 'F':
        return '前锋';
      case 'M':
        return '中场';
      case 'D':
        return '后卫';
      case 'G':
        return '门将';
      default:
        return position;
    }
  }

  /// 获取格式化的身价文本
  String get formattedMarketValue {
    if (marketValue == 0) return '-';
    if (marketValue >= 1000000) {
      return '$marketValueCurrency${(marketValue / 1000000).toStringAsFixed(1)}M';
    } else if (marketValue >= 1000) {
      return '$marketValueCurrency${(marketValue / 1000).toStringAsFixed(0)}K';
    }
    return '$marketValueCurrency$marketValue';
  }
}
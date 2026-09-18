/// HankPlayerTransfer: PlayerTransfersmodel
/// descriptionPlayeratimetransferinfo（transfer outTeam、transfer inTeam、transferfeeetc）
class HankPlayerTransfer {

  /// Safeconvert toString，compatibleint/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// TransfersID
  final int id;

  /// PlayerID
  final int playerId;

  /// Playername
  final String playerName;

  /// PlayeravatarURL
  final String playerLogo;

  /// transfer outTeamID
  final int fromTeamId;

  /// transfer outTeamname
  final String fromTeamName;

  /// transfer outTeamLogo URL
  final String fromTeamLogo;

  /// transfer inTeamID
  final int toTeamId;

  /// transfer inTeamname
  final String toTeamName;

  /// transfer inTeamLogo URL
  final String toTeamLogo;

  /// transfertype（1=transfer，2=loanended，3=signed/promotion）
  final int transferType;

  /// transferTime（ISO 8601）
  final String transferTime;

  /// transferfee
  final int transferFee;

  /// transferdescription
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

  /// fromJSONparse
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

  /// getformattransferTime（YYYY-MM-DD）
  String get formattedTime {
    if (transferTime.isEmpty) return '';
    final dt = DateTime.tryParse(transferTime);
    if (dt == null) return transferTime;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// gettransfertypetext
  String get transferTypeText {
    switch (transferType) {
      case 1:
        return 'transfer';
      case 2:
        return 'loanended';
      case 3:
        return 'signed';
      default:
        return 'transfer';
    }
  }
}

/// HankPlayerHonorItem: PlayerHonorsitemitemmodel
/// descriptionPlayerinsomeSeasongetgotsomeeachHonors
class HankPlayerHonorItem {

  /// Safeconvert toString，compatibleint/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// Season（e.g. 2018-2019）
  final String season;

  /// HonorsChinesetitle
  final String honorTitleZh;

  /// HonorsLogo URL
  final String honorLogo;

  /// Teamname
  final String teamName;

  HankPlayerHonorItem({
    required this.season,
    required this.honorTitleZh,
    required this.honorLogo,
    required this.teamName,
  });

  /// fromJSONparse
  factory HankPlayerHonorItem.fromJson(Map<String, dynamic> json) {
    return HankPlayerHonorItem(
      season: _str(json['season']),
      honorTitleZh: _str(json['honor_title_zh']),
      honorLogo: _str(json['honor_logo']),
      teamName: _str(json['team_name']),
    );
  }
}

/// HankPlayerHonorGroup: PlayerHonorsgroupingmodel
/// byHonorstypegrouping，containsmultipleitemSeasonHonors
class HankPlayerHonorGroup {

  /// Safeconvert toString，compatibleint/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// HonorsID
  final int honorId;

  /// Honorstitle
  final String honorTitle;

  /// Honorsitemitemlist
  final List<HankPlayerHonorItem> list;

  HankPlayerHonorGroup({
    required this.honorId,
    required this.honorTitle,
    required this.list,
  });

  /// fromJSONparse
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

/// HankPlayerInfo: PlayerDetailsmodel
/// containsPlayerInfo、Transfers、Honorslist
class HankPlayerInfo {

  /// Safeconvert toString，compatibleint/double/null
  static String _str(dynamic v, {String def = ''}) {
    if (v == null) return def;
    if (v is String) return v.trim();
    return v.toString();
  }
  /// PlayeruniqueID
  final int id;

  /// belongs toTeamID
  final int teamId;

  /// birthday（ISO 8601）
  final String birthday;

  /// age
  final int age;

  /// Weight（kg）
  final int weight;

  /// Height（cm）
  final int height;

  /// Nationality
  final String nationality;

  /// Value
  final int marketValue;

  /// Valuecurrency symbol
  final String marketValueCurrency;

  /// contracttoexpiryTime（ISO 8601）
  final String contractUntil;

  /// homeneedPosition（e.g. F=before）
  final String position;

  /// Chinesename
  final String nameZh;

  /// Englishname
  final String nameEn;

  /// Chinese short name
  final String shortNameZh;

  /// Englishshort name
  final String shortNameEn;

  /// PlayeravatarURL
  final String logo;

  /// CountryID
  final int countryId;

  /// Preferred Foot（1=leftfoot，2=rightfoot）
  final int preferredFoot;

  /// Positionlist（rawJSONstring）
  final String positions;

  /// TeamLogo URL
  final String teamLogo;

  /// CountryLogo URL
  final String countryLogo;

  /// Transferslist
  final List<HankPlayerTransfer> transferList;

  /// Honorslist
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

  /// fromJSONparse
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

  /// getformatbirthday（YYYY-MM-DD）
  String get formattedBirthday {
    if (birthday.isEmpty) return '';
    final dt = DateTime.tryParse(birthday);
    if (dt == null) return birthday;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// getformatcontracttoexpiryTime（YYYY-MM-DD）
  String get formattedContractUntil {
    if (contractUntil.isEmpty) return '';
    final dt = DateTime.tryParse(contractUntil);
    if (dt == null) return contractUntil;
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// getPreferred Foottext
  String get preferredFootText {
    switch (preferredFoot) {
      case 1:
        return 'leftfoot';
      case 2:
        return 'rightfoot';
      default:
        return 'unknown';
    }
  }

  /// getPositiontext
  String get positionText {
    switch (position) {
      case 'F':
        return 'before';
      case 'M':
        return 'halftime';
      case 'D':
        return 'defender';
      case 'G':
        return 'goalkeeper';
      default:
        return position;
    }
  }

  /// getformatValuetext
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
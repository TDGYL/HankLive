import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// HankProcessData: matchprogressData（incidents + stats）
/// maps to API GET /api/livespeed/football/match/process BackDatabody
class HankProcessData {
  /// technicalstatslist
  final List<HankStatItem>? stats;

  /// match event list
  final List<HankIncidentItem>? incidents;

  HankProcessData({this.stats, this.incidents});

  /// fromJSONparse
  factory HankProcessData.fromJson(Map<String, dynamic> json) {
    return HankProcessData(
      stats: json['stats'] != null
          ? (json['stats'] as List).map((i) => HankStatItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
      incidents: json['incidents'] != null
          ? (json['incidents'] as List).map((i) => HankIncidentItem.fromJson(i as Map<String, dynamic>)).toList()
          : null,
    );
  }
}

/// HankStatItem: technicalstat item
/// typefieldmaps todifferent stattype，home/awayisd u a lsidecountvalue
class HankStatItem {
  /// Awaycountvalue
  final int? away;

  /// Homecountvalue
  final int? home;

  /// statstypeID
  final int? type;

  HankStatItem({this.away, this.home, this.type});

  /// fromJSONparse
  factory HankStatItem.fromJson(Map<String, dynamic> json) {
    return HankStatItem(
      away: json['away'] != null ? (json['away'] as num).toInt() : null,
      home: json['home'] != null ? (json['home'] as num).toInt() : null,
      type: json['type'] != null ? (json['type'] as num).toInt() : null,
    );
  }

  /// stat itemChinesename
  String get typeName {
    switch (type) {
      case 25:
        return 'Possession';
      case 21:
        return 'On Target';
      case 22:
        return 'shot off target';
      case 23:
        return 'Attacks';
      case 24:
        return 'DangerousAttacks';
      case 2:
        return 'Corners';
      case 4:
        return 'Red Cards';
      case 3:
        return 'Yellow Cards';
      case 1:
        return 'Goals';
      default:
        return 'unknownstats';
    }
  }

  /// Homeproportion（0.0-1.0）
  double get homeProgress {
    final int total = (home ?? 0) + (away ?? 0);
    if (total == 0 || home == 0) return 0.0;
    return (home!) / total;
  }

  /// Awayproportion（0.0-1.0）
  double get awayProgress {
    final int total = (home ?? 0) + (away ?? 0);
    if (total == 0 || away == 0) return 0.0;
    return (away!) / total;
  }

  /// Homepercentcategorymatchdisplaytext（e.g.: "54%"）
  String get homePercentText {
    if (type == 25) {
      // Possessiondirectlydisplaypercentcategorymatch
      return '${home ?? 0}%';
    }
    return '${home ?? 0}';
  }

  /// Awaypercentcategorymatchdisplaytext
  String get awayPercentText {
    if (type == 25) {
      return '${away ?? 0}%';
    }
    return '${away ?? 0}';
  }
}

/// HankIncidentItem: match eventseventitem
/// maps to APIincidentscountgroupinsingleevent
class HankIncidentItem {
  /// eventtypeID
  final int? type;

  /// eventPosition（0=increate, 1=Home, 2=Away）
  final int? position;

  /// occurredTime（min）
  final int? time;

  /// Homescore（eventoccurredwhen）
  final int? homeScore;

  /// Awayscore（eventoccurredwhen）
  final int? awayScore;

  /// PlayerID
  final int? playerId;

  /// Playername
  final String? playerName;

  /// assistsPlayer1 ID
  final int? assist1Id;

  /// assistsPlayer2 ID
  final int? assist2Id;

  /// entermatchPlayerID（substitution）
  final int? inPlayerId;

  /// appearancePlayerID（substitution）
  final int? outPlayerId;

  /// assistsPlayer1name
  final String? assist1Name;

  /// assistsPlayer2name
  final String? assist2Name;

  /// entermatchPlayername（substitution）
  final String? inPlayerName;

  /// appearancePlayername（substitution）
  final String? outPlayerName;

  HankIncidentItem({
    this.type,
    this.position,
    this.time,
    this.homeScore,
    this.awayScore,
    this.playerId,
    this.playerName,
    this.assist1Id,
    this.assist2Id,
    this.inPlayerId,
    this.outPlayerId,
    this.assist1Name,
    this.assist2Name,
    this.inPlayerName,
    this.outPlayerName,
  });

  /// fromJSONparse（snake_case → camelCase）
  factory HankIncidentItem.fromJson(Map<String, dynamic> json) {
    return HankIncidentItem(
      type: json['type'] != null ? (json['type'] as num).toInt() : null,
      position: json['position'] != null ? (json['position'] as num).toInt() : null,
      time: json['time'] != null ? (json['time'] as num).toInt() : null,
      homeScore: json['home_score'] != null ? (json['home_score'] as num).toInt() : null,
      awayScore: json['away_score'] != null ? (json['away_score'] as num).toInt() : null,
      playerId: json['player_id'] != null ? (json['player_id'] as num).toInt() : null,
      playerName: json['player_name'] as String?,
      assist1Id: json['assist1_id'] != null ? (json['assist1_id'] as num).toInt() : null,
      assist2Id: json['assist2_id'] != null ? (json['assist2_id'] as num).toInt() : null,
      inPlayerId: json['in_player_id'] != null ? (json['in_player_id'] as num).toInt() : null,
      outPlayerId: json['out_player_id'] != null ? (json['out_player_id'] as num).toInt() : null,
      assist1Name: json['assist1_name'] as String?,
      assist2Name: json['assist2_name'] as String?,
      inPlayerName: json['in_player_name'] as String?,
      outPlayerName: json['out_player_name'] as String?,
    );
  }

  /// get displayPlayername
  /// substitution eventdisplayappearancePlayer，assist eventdisplayassistsPlayer，other displayGoalsPlayer
  String get custPlayerName {
    // substitution event type=9
    if (type == 9) {
      return outPlayerName ?? '';
    }
    // assist event type=18
    if (type == 18) {
      return (assist1Name != null && assist1Name!.isNotEmpty)
          ? assist1Name!
          : (assist2Name ?? '');
    }
    return playerName ?? '';
  }

  /// geteventtypeChinesename
  String get custTypeName {
    switch (type) {
      case 4:
        return 'Red Cards';
      case 3:
        return 'Yellow Cards';
      case 15:
        return 'twoyellow tored';
      case 1:
        return 'Goals';
      case 17:
        return 'own goalgoal';
      case 9:
        return 'substitution';
      case 2:
        return 'Corners';
      case 8:
        return 'PENGoals';
      case 16:
        return 'PENnot entered';
      case 18:
        return 'assists';
      case 24:
        return 'DangerousAttacks';
      default:
        return 'unknownevent';
    }
  }

  /// geteventicon
  IconData get iconData {
    switch (type) {
      case 4: // Red Cards
      case 15: // twoyellow tored
        return Icons.square;
      case 3: // Yellow Cards
        return Icons.square;
      case 1: // Goals
      case 8: // PENGoals
      case 17: // own goalgoal
        return Icons.sports_soccer;
      case 9: // substitution
        return Icons.swap_horiz;
      case 2: // Corners
        return Icons.flag;
      default:
        return Icons.info_outline;
    }
  }

  /// geteventiconcolor
  Color get iconColor {
    switch (type) {
      case 4:
      case 15:
        return AppColors.rose500;
      case 3:
        return AppColors.amber500;
      case 1:
      case 8:
        return AppColors.emerald500;
      case 17:
        return AppColors.rose500;
      case 9:
        return AppColors.emerald500;
      case 2:
        return AppColors.amber500;
      default:
        return AppColors.slate500;
    }
  }
}

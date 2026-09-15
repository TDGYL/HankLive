import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// HankProcessData: 比赛进程数据（incidents + stats）
/// 对应接口 GET /api/livespeed/football/match/process 返回的数据体
class HankProcessData {
  /// 技术统计列表
  final List<HankStatItem>? stats;

  /// 赛况事件列表
  final List<HankIncidentItem>? incidents;

  HankProcessData({this.stats, this.incidents});

  /// 从JSON解析
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

/// HankStatItem: 技术统计项
/// type字段对应不同统计类型，home/away为双方数值
class HankStatItem {
  /// 客队数值
  final int? away;

  /// 主队数值
  final int? home;

  /// 统计类型ID
  final int? type;

  HankStatItem({this.away, this.home, this.type});

  /// 从JSON解析
  factory HankStatItem.fromJson(Map<String, dynamic> json) {
    return HankStatItem(
      away: json['away'] != null ? (json['away'] as num).toInt() : null,
      home: json['home'] != null ? (json['home'] as num).toInt() : null,
      type: json['type'] != null ? (json['type'] as num).toInt() : null,
    );
  }

  /// 统计项中文名称
  String get typeName {
    switch (type) {
      case 25:
        return '控球率';
      case 21:
        return '射正';
      case 22:
        return '射偏';
      case 23:
        return '进攻';
      case 24:
        return '危险进攻';
      case 2:
        return '角球';
      case 4:
        return '红牌';
      case 3:
        return '黄牌';
      case 1:
        return '进球';
      default:
        return '未知统计';
    }
  }

  /// 主队占比（0.0-1.0）
  double get homeProgress {
    final int total = (home ?? 0) + (away ?? 0);
    if (total == 0 || home == 0) return 0.0;
    return (home!) / total;
  }

  /// 客队占比（0.0-1.0）
  double get awayProgress {
    final int total = (home ?? 0) + (away ?? 0);
    if (total == 0 || away == 0) return 0.0;
    return (away!) / total;
  }

  /// 主队百分比显示文字（如: "54%"）
  String get homePercentText {
    if (type == 25) {
      // 控球率直接显示百分比
      return '${home ?? 0}%';
    }
    return '${home ?? 0}';
  }

  /// 客队百分比显示文字
  String get awayPercentText {
    if (type == 25) {
      return '${away ?? 0}%';
    }
    return '${away ?? 0}';
  }
}

/// HankIncidentItem: 赛况事件项
/// 对应接口incidents数组中的单条事件
class HankIncidentItem {
  /// 事件类型ID
  final int? type;

  /// 事件位置（0=中立, 1=主队, 2=客队）
  final int? position;

  /// 发生时间（分钟）
  final int? time;

  /// 主队比分（事件发生时）
  final int? homeScore;

  /// 客队比分（事件发生时）
  final int? awayScore;

  /// 球员ID
  final int? playerId;

  /// 球员姓名
  final String? playerName;

  /// 助攻球员1 ID
  final int? assist1Id;

  /// 助攻球员2 ID
  final int? assist2Id;

  /// 进场球员ID（换人）
  final int? inPlayerId;

  /// 出场球员ID（换人）
  final int? outPlayerId;

  /// 助攻球员1姓名
  final String? assist1Name;

  /// 助攻球员2姓名
  final String? assist2Name;

  /// 进场球员姓名（换人）
  final String? inPlayerName;

  /// 出场球员姓名（换人）
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

  /// 从JSON解析（snake_case → camelCase）
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

  /// 获取展示用球员姓名
  /// 换人事件显示出场球员，助攻事件显示助攻球员，其他显示进球球员
  String get custPlayerName {
    // 换人事件 type=9
    if (type == 9) {
      return outPlayerName ?? '';
    }
    // 助攻事件 type=18
    if (type == 18) {
      return (assist1Name != null && assist1Name!.isNotEmpty)
          ? assist1Name!
          : (assist2Name ?? '');
    }
    return playerName ?? '';
  }

  /// 获取事件类型中文名称
  String get custTypeName {
    switch (type) {
      case 4:
        return '红牌';
      case 3:
        return '黄牌';
      case 15:
        return '两黄变红';
      case 1:
        return '进球';
      case 17:
        return '乌龙球';
      case 9:
        return '换人';
      case 2:
        return '角球';
      case 8:
        return '点球进球';
      case 16:
        return '点球未进';
      case 18:
        return '助攻';
      case 24:
        return '危险进攻';
      default:
        return '未知事件';
    }
  }

  /// 获取事件图标
  IconData get iconData {
    switch (type) {
      case 4: // 红牌
      case 15: // 两黄变红
        return Icons.square;
      case 3: // 黄牌
        return Icons.square;
      case 1: // 进球
      case 8: // 点球进球
      case 17: // 乌龙球
        return Icons.sports_soccer;
      case 9: // 换人
        return Icons.swap_horiz;
      case 2: // 角球
        return Icons.flag;
      default:
        return Icons.info_outline;
    }
  }

  /// 获取事件图标颜色
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

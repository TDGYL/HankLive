import 'package:flutter/foundation.dart';
import '../utils/hank_network_manager.dart';
import '../models/hank_process_model.dart';
import '../models/hank_odds_model.dart';
import '../models/hank_odds_history_model.dart';
import '../models/hank_lineup_model.dart';
import '../models/hank_h2h_model.dart';

/// HankMatchDetailApiService: 比赛详情接口服务
/// 封装 /api/livespeed/football/match/detail 和 /api/livespeed/football/match/process 接口
/// 参考ZogoLive的FootballDetailPage请求逻辑
class HankMatchDetailApiService {
  /// 单例实例
  static final HankMatchDetailApiService _instance = HankMatchDetailApiService._internal();

  /// 工厂构造，返回单例
  factory HankMatchDetailApiService() {
    return _instance;
  }

  /// 私有构造
  HankMatchDetailApiService._internal();

  /// 请求比赛详情
  /// 接口：GET /api/livespeed/football/match/detail
  /// 参数：match_id - 比赛ID
  /// 返回：Map<String, dynamic> 原始响应数据，供页面解析比赛信息
  Future<Map<String, dynamic>?> fetchMatchDetail({
    required int matchId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/match/detail',
      queryParameters: {'match_id': matchId},
    );

    if (response.isSuccess && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    return null;
  }

  /// 请求比赛进程数据（incidents + stats）
  /// 接口：GET /api/livespeed/football/match/process
  /// 参数：match_id - 比赛ID
  /// 返回：HankProcessData 包含赛况事件和技术统计
  Future<HankProcessData?> fetchMatchProcess({
    required int matchId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/match/process',
      queryParameters: {'match_id': matchId},
    );

    if (response.isSuccess && response.data != null) {
      return HankProcessData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求比赛指数数据（亚盘/欧赔/大小球/角球）
  /// 接口：GET /api/livespeed/football/match/odds
  /// 参数：match_id - 比赛ID
  /// 返回：HankOddsData 包含四种盘口类型的博彩公司赔率列表
  Future<HankOddsData?> fetchMatchOdds({
    required int matchId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/match/odds',
      queryParameters: {'match_id': matchId},
    );

    if (response.isSuccess && response.data != null) {
      return HankOddsData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求指数历史数据（亚盘/欧赔/大小球/角球）
  /// 接口：GET /api/livespeed/football/match/odd-histories
  /// 参数：match_id - 比赛ID, company_id - 博彩公司ID
  /// 返回：HankOddsHistoryData 包含四种盘口类型的历史赔率列表
  Future<HankOddsHistoryData?> fetchOddsHistory({
    required int matchId,
    required String companyId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/match/odd-histories',
      queryParameters: {
        'match_id': matchId,
        'company_id': companyId,
      },
    );

    if (response.isSuccess && response.data != null) {
      return HankOddsHistoryData.fromJson(
          response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求比赛阵容数据（首发/替补/伤停/教练/阵型）
  /// 接口：GET /api/livespeed/football/match/lineup
  /// 参数：match_id - 比赛ID
  /// 返回：HankLineupData 包含双方首发、替补、伤停、教练、阵型、身价
  Future<HankLineupData?> fetchMatchLineup({
    required int matchId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/match/lineup',
      queryParameters: {'match_id': matchId},
    );

    if (response.isSuccess && response.data != null) {
      return HankLineupData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求历史交锋数据
  /// 接口：GET /api/livespeed/football/match/analysis
  /// 参数：match_id - 比赛ID
  /// 返回：List<HankH2HMatch> 全部历史交锋数据，由调用方根据筛选条件截取
  Future<List<HankH2HMatch>> fetchH2HData({
    required int matchId,
  }) async {
    try {
      final response = await HankNetworkManager().getRequest(
        '/api/livespeed/football/match/analysis',
        queryParameters: {'match_id': matchId},
      );

      if (response.isSuccess && response.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final history = data['history'];
        if (history is Map<String, dynamic>) {
          final vs = history['vs'];
          if (vs is List) {
            return vs
                .whereType<Map<String, dynamic>>()
                .map((e) => HankH2HMatch.fromJson(e))
                .toList();
          }
        }
      }
    } catch (e) {
      debugPrint('H2H数据解析异常: $e');
    }

    return [];
  }
}

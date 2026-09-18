import 'package:flutter/foundation.dart';
import '../utils/hank_network_manager.dart';
import '../models/hank_process_model.dart';
import '../models/hank_odds_model.dart';
import '../models/hank_odds_history_model.dart';
import '../models/hank_lineup_model.dart';
import '../models/hank_h2h_model.dart';

/// HankMatchDetailApiService: matchDetailsAPI service
/// wrap /api/livespeed/football/match/detail and /api/livespeed/football/match/process API
/// referenceZogoLiveFootballDetailPagerequestlogic
class HankMatchDetailApiService {
  /// singleton instance
  static final HankMatchDetailApiService _instance = HankMatchDetailApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankMatchDetailApiService() {
    return _instance;
  }

  /// private constructor
  HankMatchDetailApiService._internal();

  /// requestmatchDetails
  /// API：GET /api/livespeed/football/match/detail
  /// paramcount：match_id - matchID
  /// Back：Map<String, dynamic> rawresponseData，forpageparsematchinfo
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

  /// requestmatchprogressData（incidents + stats）
  /// API：GET /api/livespeed/football/match/process
  /// paramcount：match_id - matchID
  /// Back：HankProcessData containsmatch eventseventandtechnicalstats
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

  /// requestmatchoddscountData（AH/1X2/O/Ugoal/Corners）
  /// API：GET /api/livespeed/football/match/odds
  /// paramcount：match_id - matchID
  /// Back：HankOddsData containsfour typesHandicaptypebookmakerBookmakerOddslist
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

  /// requestoddscounthistoryData（AH/1X2/O/Ugoal/Corners）
  /// API：GET /api/livespeed/football/match/odd-histories
  /// paramcount：match_id - matchID, company_id - bookmakerBookmakerID
  /// Back：HankOddsHistoryData containsfour typesHandicaptypehistoryOddslist
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

  /// requestmatchLineupData（starter/substitute/injured/Coach/formation）
  /// API：GET /api/livespeed/football/match/lineup
  /// paramcount：match_id - matchID
  /// Back：HankLineupData containsd u a lsidestarter、substitute、injured、Coach、formation、Value
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

  /// requestH2HData
  /// API：GET /api/livespeed/football/match/analysis
  /// paramcount：match_id - matchID
  /// Back：List<HankH2HMatch> AllH2HData，called byusesiderootbased onfilteritemitemtruncateget
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
      debugPrint('H2HDataparseerror: $e');
    }

    return [];
  }
}

import '../utils/hank_network_manager.dart';
import '../models/hank_team_data_model.dart';
import '../models/hank_team_lineup_model.dart';
import '../models/hank_team_rank_model.dart';
import '../models/hank_news_api_model.dart';
import '../models/hank_match_api_model.dart';

/// HankTeamApiService: 球队详情接口服务
/// 封装球队数据、阵容、排名、资讯、赛程接口
/// 参考ZogoLive的TeamDetailPage请求逻辑
class HankTeamApiService {
  /// 单例实例
  static final HankTeamApiService _instance = HankTeamApiService._internal();

  /// 工厂构造，返回单例
  factory HankTeamApiService() {
    return _instance;
  }

  /// 私有构造
  HankTeamApiService._internal();

  /// 请求球队详情数据
  /// 接口：GET /api/livespeed/football/team/data
  /// 参数：team_id - 球队ID
  /// 返回：HankTeamData 球队详情
  Future<HankTeamData?> fetchTeamData({
    required int teamId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/team/data',
      queryParameters: {'team_id': teamId},
    );

    if (response.isSuccess && response.data != null) {
      return HankTeamData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求球队阵容数据
  /// 接口：GET /api/livespeed/football/team/lineup
  /// 参数：team_id - 球队ID
  /// 返回：List<HankTeamLineupGroup> 阵容分组列表
  Future<List<HankTeamLineupGroup>> fetchTeamLineup({
    required int teamId,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/team/lineup',
      queryParameters: {'team_id': teamId},
    );

    if (response.isSuccess && response.data != null && response.data is List) {
      return (response.data as List)
          .map((e) => HankTeamLineupGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 请求球队积分榜数据
  /// 接口：GET /api/livespeed/football/team/rank
  /// 参数：competition_id - 联赛ID, season_id - 赛季ID
  /// 返回：List<HankTeamRankGroup> 排名分组列表
  Future<List<HankTeamRankGroup>> fetchTeamRank({
    required int competitionId,
    int seasonId = 2025,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/team/rank',
      queryParameters: {
        'competition_id': competitionId,
        'season_id': seasonId,
      },
    );

    if (response.isSuccess && response.data != null && response.data is List) {
      return (response.data as List)
          .map((e) => HankTeamRankGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// 请求球队相关资讯
  /// 接口：GET /api/livespeed/info/list
  /// 参数：competition_id - 联赛ID, page, size
  /// 返回：HankNewsData 资讯列表
  Future<HankNewsData?> fetchTeamNews({
    required int competitionId,
    int page = 1,
    int size = 5,
  }) async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/info/list',
      queryParameters: {
        'competition_id': competitionId,
        'page': page,
        'size': size,
      },
    );

    if (response.isSuccess && response.data != null) {
      return HankNewsData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求球队赛程数据
  /// 接口：POST /api/livespeed/football/matches
  /// 参数：competition_id - 联赛ID, timestamp - 时间戳
  /// 返回：HankMatchData 比赛列表
  Future<HankMatchData?> fetchTeamMatches({
    required int competitionId,
  }) async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timestamp = (tomorrow.millisecondsSinceEpoch / 1000).floor();

    final response = await HankNetworkManager().postRequest(
      '/api/livespeed/football/matches',
      data: {
        'tab': 0,
        'page': 1,
        'size': 10,
        'timestamp': timestamp,
        'competition_ids': [competitionId],
      },
    );

    if (response.isSuccess && response.data != null) {
      return HankMatchData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }
}

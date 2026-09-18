import '../utils/hank_network_manager.dart';
import '../models/hank_team_data_model.dart';
import '../models/hank_team_lineup_model.dart';
import '../models/hank_team_rank_model.dart';
import '../models/hank_news_api_model.dart';
import '../models/hank_match_api_model.dart';

/// HankTeamApiService: TeamDetailsAPI service
/// wrapTeamData、Lineup、rank、news、FixturesAPI
/// referenceZogoLiveTeamDetailPagerequestlogic
class HankTeamApiService {
  /// singleton instance
  static final HankTeamApiService _instance = HankTeamApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankTeamApiService() {
    return _instance;
  }

  /// private constructor
  HankTeamApiService._internal();

  /// requestTeamDetailsData
  /// API：GET /api/livespeed/football/team/data
  /// paramcount：team_id - TeamID
  /// Back：HankTeamData TeamDetails
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

  /// requestTeamLineupData
  /// API：GET /api/livespeed/football/team/lineup
  /// paramcount：team_id - TeamID
  /// Back：List<HankTeamLineupGroup> Lineupgroupinglist
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

  /// requestTeamStandingsData
  /// API：GET /api/livespeed/football/team/rank
  /// paramcount：competition_id - LeagueID, season_id - SeasonID
  /// Back：List<HankTeamRankGroup> rankgroupinglist
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

  /// requestTeamphasematchnews
  /// API：GET /api/livespeed/info/list
  /// paramcount：competition_id - LeagueID, page, size
  /// Back：HankNewsData newslist
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

  /// requestTeamFixturesData
  /// API：POST /api/livespeed/football/matches
  /// paramcount：competition_id - LeagueID, timestamp - Timetimestamp
  /// Back：HankMatchData matchlist
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

import '../utils/hank_network_manager.dart';
import '../utils/hank_match_status_util.dart';
import '../models/hank_match_api_model.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';

/// HankMatchTab: matchlistTabtypeenum
/// maps to API tab paramcount：Follow=4，All=0，In Progress=1，Featured=5，Fixtures=2，result=3
enum HankMatchTab {
  /// Follow
  follow(4),
  /// All
  all(0),
  /// In Progress
  live(1),
  /// Featured
  recommend(5),
  /// Fixtures
  schedule(2),
  /// result
  results(3);

  /// APImaps to tab value
  final int value;
  const HankMatchTab(this.value);
}

/// HankMatchApiService: matchlistAPI service
/// wrap /api/livespeed/football/matches POST request
/// BackDatapasspass HankMatchItem → MatchModel convertfor UI useuse
class HankMatchApiService {
  /// singleton instance
  static final HankMatchApiService _instance = HankMatchApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankMatchApiService() {
    return _instance;
  }

  /// private constructor
  HankMatchApiService._internal();

  /// APIpath
  static const String _apiPath = '/api/livespeed/football/matches';

  /// requestmatchlist
  /// [tab] - menuTabtype
  /// [page] - categorypagepagecode（from1start）
  /// [size] - eachpageitemcount
  /// [timestamp] - whendayTimetimestamp（seconds）；Fixtures/resultpassed incalendarselectedDateTimetimestamp
  /// [competitionIds] - matchIDfilter，uploademptycountgroupiscan
  /// Back：HankMatchData rawresponseData
  Future<HankMatchData?> fetchMatchList({
    required HankMatchTab tab,
    int page = 1,
    int size = 10,
    required int timestamp,
    List<int> competitionIds = const [],
  }) async {
    final params = <String, dynamic>{
      'tab': tab.value,
      'page': page,
      'size': size,
      'timestamp': timestamp,
      'competition_ids': competitionIds,
    };

    final response = await HankNetworkManager().postRequest(
      _apiPath,
      data: params,
    );

    if (response.isSuccess && response.data != null) {
      return HankMatchData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// requestmatchlistandconvert to MatchModel list
  /// paramcountsame [fetchMatchList]
  /// Back：List<MatchModel>，for UI componentdirectlyuseuse
  Future<List<MatchModel>> fetchMatchModels({
    required HankMatchTab tab,
    int page = 1,
    int size = 10,
    required int timestamp,
    List<int> competitionIds = const [],
  }) async {
    final data = await fetchMatchList(
      tab: tab,
      page: page,
      size: size,
      timestamp: timestamp,
      competitionIds: competitionIds,
    );

    if (data == null || data.results.isEmpty) {
      return [];
    }

    return data.results.map((item) => HankMatchApiService.convertToMatchModel(item)).toList();
  }

  /// convert APImodel HankMatchItem convert to UI model MatchModel
  /// [item] - APIBacksinglematchmatchData
  /// Back：MatchModel
  static MatchModel convertToMatchModel(HankMatchItem item) {
    // checkmatchstatus
    MatchStatus status;
    if (HankMatchStatusUtil.isLive(item.statusId)) {
      status = MatchStatus.live;
    } else if (HankMatchStatusUtil.isFinished(item.statusId)) {
      status = MatchStatus.finished;
    } else {
      status = MatchStatus.upcoming;
    }

    // formatmatchTime (Timetimestampseconds → HH:mm)
    String matchTimeStr = '';
    if (item.matchTime != null && item.matchTime! > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item.matchTime! * 1000);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      matchTimeStr = '$hour:$minute';
    }

    // buildHomemodel
    final homeTeam = TeamModel(
      teamId: item.homeTeamId?.toString() ?? '',
      teamName: item.homeTeamName ?? '',
      teamShort: extractShort(item.homeTeamName),
      logoUrl: item.homeTeamLogo,
    );

    // buildAwaymodel
    final awayTeam = TeamModel(
      teamId: item.awayTeamId?.toString() ?? '',
      teamName: item.awayTeamName ?? '',
      teamShort: extractShort(item.awayTeamName),
      logoUrl: item.awayTeamLogo,
    );

    // HTscore
    String? halfTimeScore;
    if (item.homeHalfScore != null || item.awayHalfScore != null) {
      halfTimeScore = 'half ${item.homeHalfScore ?? 0}-${item.awayHalfScore ?? 0}';
    }

    // Livemincount
    String? liveMinute;
    if (status == MatchStatus.live && item.minutes != null && item.minutes!.isNotEmpty) {
      liveMinute = item.minutes;
    }

    // whetherFeatured（LiveinmatchdefaultFeatureddisplayisbigcard）
    final isFeatured = status == MatchStatus.live;

    // whetherFollow
    final isFollowed = item.subscribed ?? false;

    return MatchModel(
      matchId: item.matchId?.toString() ?? '',
      leagueName: item.competitionName ?? '',
      leagueColor: 0xFF8B5CF6,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      homeScore: item.homeNormalScore,
      awayScore: item.awayNormalScore,
      matchTime: matchTimeStr,
      status: status,
      liveMinute: liveMinute,
      halfTimeScore: halfTimeScore,
      goalEvents: [],
      isFeatured: isFeatured,
      isFollowed: isFollowed,
      homeWinRate: 0,
      drawRate: 0,
      awayWinRate: 0,
      matchTag: item.competitionName,
    );
  }

  /// fromTeamnameextractgetabbrevwrite（getbefore3eachbigwritecharcharorbefore3eachcharchar）
  /// [name] - Teamname
  /// Back：3charcharabbrevwrite
  static String extractShort(String? name) {
    if (name == null || name.isEmpty) return '';
    if (name.length <= 3) return name.toUpperCase();
    return name.substring(0, 3).toUpperCase();
  }
}

import '../utils/hank_network_manager.dart';
import '../utils/hank_match_status_util.dart';
import '../models/hank_match_api_model.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';

/// HankMatchTab: 比赛列表Tab类型枚举
/// 对应接口 tab 参数：关注=4，全部=0，进行中=1，推荐=5，赛程=2，赛果=3
enum HankMatchTab {
  /// 关注
  follow(4),
  /// 全部
  all(0),
  /// 进行中
  live(1),
  /// 推荐
  recommend(5),
  /// 赛程
  schedule(2),
  /// 赛果
  results(3);

  /// 接口对应的 tab 值
  final int value;
  const HankMatchTab(this.value);
}

/// HankMatchApiService: 比赛列表接口服务
/// 封装 /api/livespeed/football/matches POST 请求
/// 返回数据通过 HankMatchItem → MatchModel 转换供 UI 使用
class HankMatchApiService {
  /// 单例实例
  static final HankMatchApiService _instance = HankMatchApiService._internal();

  /// 工厂构造，返回单例
  factory HankMatchApiService() {
    return _instance;
  }

  /// 私有构造
  HankMatchApiService._internal();

  /// 接口路径
  static const String _apiPath = '/api/livespeed/football/matches';

  /// 请求比赛列表
  /// [tab] - 菜单Tab类型
  /// [page] - 分页页码（从1开始）
  /// [size] - 每页条数
  /// [timestamp] - 当天时间戳（秒）；赛程/赛果传入日历选中日期的时间戳
  /// [competitionIds] - 赛事ID过滤，传空数组即可
  /// 返回：HankMatchData 原始响应数据
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

  /// 请求比赛列表并转换为 MatchModel 列表
  /// 参数同 [fetchMatchList]
  /// 返回：List<MatchModel>，供 UI 组件直接使用
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

  /// 将接口模型 HankMatchItem 转换为 UI 模型 MatchModel
  /// [item] - 接口返回的单场比赛数据
  /// 返回：MatchModel
  static MatchModel convertToMatchModel(HankMatchItem item) {
    // 判断比赛状态
    MatchStatus status;
    if (HankMatchStatusUtil.isLive(item.statusId)) {
      status = MatchStatus.live;
    } else if (HankMatchStatusUtil.isFinished(item.statusId)) {
      status = MatchStatus.finished;
    } else {
      status = MatchStatus.upcoming;
    }

    // 格式化比赛时间 (时间戳秒 → HH:mm)
    String matchTimeStr = '';
    if (item.matchTime != null && item.matchTime! > 0) {
      final dt = DateTime.fromMillisecondsSinceEpoch(item.matchTime! * 1000);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      matchTimeStr = '$hour:$minute';
    }

    // 构建主队模型
    final homeTeam = TeamModel(
      teamId: item.homeTeamId?.toString() ?? '',
      teamName: item.homeTeamName ?? '',
      teamShort: extractShort(item.homeTeamName),
      logoUrl: item.homeTeamLogo,
    );

    // 构建客队模型
    final awayTeam = TeamModel(
      teamId: item.awayTeamId?.toString() ?? '',
      teamName: item.awayTeamName ?? '',
      teamShort: extractShort(item.awayTeamName),
      logoUrl: item.awayTeamLogo,
    );

    // 半场比分
    String? halfTimeScore;
    if (item.homeHalfScore != null || item.awayHalfScore != null) {
      halfTimeScore = '半 ${item.homeHalfScore ?? 0}-${item.awayHalfScore ?? 0}';
    }

    // 直播分钟数
    String? liveMinute;
    if (status == MatchStatus.live && item.minutes != null && item.minutes!.isNotEmpty) {
      liveMinute = item.minutes;
    }

    // 是否精选（直播中的比赛默认精选展示为大卡片）
    final isFeatured = status == MatchStatus.live;

    // 是否关注
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

  /// 从球队名称提取缩写（取前3个大写字母或前3个字符）
  /// [name] - 球队名称
  /// 返回：3字符缩写
  static String extractShort(String? name) {
    if (name == null || name.isEmpty) return '';
    if (name.length <= 3) return name.toUpperCase();
    return name.substring(0, 3).toUpperCase();
  }
}

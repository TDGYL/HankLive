import '../utils/hank_network_manager.dart';
import '../models/hank_post_api_model.dart';
import '../models/post_model.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';

/// HankCommunityTab: 社区列表Tab类型枚举
/// 对应接口 type 参数：推荐=1，最近=2，关注=3
enum HankCommunityTab {
  /// 推荐 type=1
  recommend(1),
  /// 最近 type=2
  recent(2),
  /// 关注 type=3
  follow(3);

  /// 接口对应的 type 值
  final int value;
  const HankCommunityTab(this.value);
}

/// HankCommunityApiService: 社区列表接口服务
/// 封装 /api/livespeed/community/list GET 请求
/// 返回数据通过 HankPostItem → PostModel 转换供 UI 使用
class HankCommunityApiService {
  /// 单例实例
  static final HankCommunityApiService _instance = HankCommunityApiService._internal();

  /// 工厂构造，返回单例
  factory HankCommunityApiService() {
    return _instance;
  }

  /// 私有构造
  HankCommunityApiService._internal();

  /// 接口路径
  static const String _apiPath = '/api/livespeed/community/list';

  /// 请求社区帖子列表
  /// [tab] - 菜单Tab类型（推荐/最近/关注）
  /// [page] - 分页页码（从1开始）
  /// [size] - 每页条数
  /// [matchType] - 比赛类型，默认1
  /// 返回：HankPostData 原始响应数据
  Future<HankPostData?> fetchPostList({
    required HankCommunityTab tab,
    int page = 1,
    int size = 10,
    int matchType = 1,
  }) async {
    final params = <String, dynamic>{
      'type': tab.value,
      'page': page,
      'size': size,
      'match_type': matchType,
    };

    final response = await HankNetworkManager().getRequest(
      _apiPath,
      queryParameters: params,
    );

    if (response.isSuccess && response.data != null) {
      return HankPostData.fromJson(response.data as Map<String, dynamic>);
    }

    return null;
  }

  /// 请求社区帖子列表并转换为 PostModel 列表
  /// 参数同 [fetchPostList]
  /// 返回：List<PostModel>，供 UI 组件直接使用
  Future<List<PostModel>> fetchPostModels({
    required HankCommunityTab tab,
    int page = 1,
    int size = 10,
    int matchType = 1,
  }) async {
    final data = await fetchPostList(
      tab: tab,
      page: page,
      size: size,
      matchType: matchType,
    );

    if (data == null || data.results.isEmpty) {
      return [];
    }

    return data.results.map((item) => _convertToPostModel(item)).toList();
  }

  /// 将接口模型 HankPostItem 转换为 UI 模型 PostModel
  /// [item] - 接口返回的单条帖子数据
  /// 返回：PostModel
  PostModel _convertToPostModel(HankPostItem item) {
    // 解析话题标签：image 字段可能含 "com/" 前缀，逗号分隔
    final hashtags = _parseHashtags(item.image);

    // 构建内嵌比赛模型
    MatchModel? embeddedMatch;
    if (item.match != null) {
      final m = item.match!;
      embeddedMatch = MatchModel(
        matchId: m.matchId?.toString() ?? '',
        leagueName: m.competitionName ?? '',
        leagueColor: 0xFF8B5CF6,
        homeTeam: TeamModel(
          teamId: m.homeTeamId?.toString() ?? '',
          teamName: m.homeTeamName ?? '',
          teamShort: _extractShort(m.homeTeamName),
          logoUrl: m.homeTeamLogo,
        ),
        awayTeam: TeamModel(
          teamId: m.awayTeamId?.toString() ?? '',
          teamName: m.awayTeamName ?? '',
          teamShort: _extractShort(m.awayTeamName),
          logoUrl: m.awayTeamLogo,
        ),
        homeScore: m.homeScore,
        awayScore: m.awayScore,
        matchTime: _formatMatchTime(m.startTime),
        status: _matchStatusFromId(m.statusId),
        liveMinute: null,
        halfTimeScore: null,
        goalEvents: [],
        isFeatured: false,
        isFollowed: false,
        homeWinRate: 0,
        drawRate: 0,
        awayWinRate: 0,
        matchTag: m.competitionName,
      );
    }

    return PostModel(
      postId: item.id?.toString() ?? '',
      userId: item.author?.id?.toString() ?? '',
      userName: item.author?.name ?? '匿名球友',
      userAvatarUrl: item.author?.avatar,
      userBadge: item.author?.isSubscribe == true ? '已关注' : null,
      userBadgeBgColor: 0xFFEDE9FE,
      userBadgeTextColor: 0xFF7C3AED,
      publishTime: _formatPublishTime(item.createTime),
      location: null,
      hashtags: hashtags,
      content: item.content ?? '',
      embeddedMatch: embeddedMatch,
      isLiked: item.isLike ?? false,
      likeCount: item.likeCount ?? 0,
      commentCount: item.commentCount ?? 0,
      shareCount: 0,
    );
  }

  /// 解析话题标签
  /// [rawImage] - 接口返回的 image 字段，可能含 "com/" 前缀，逗号分隔
  /// 返回：List<String> 话题标签数组
  List<String> _parseHashtags(String? rawImage) {
    if (rawImage == null || rawImage.isEmpty) return [];

    String raw = rawImage;
    // 去除 "com/" 前缀
    if (raw.contains('com/')) {
      raw = raw.substring(raw.indexOf('com/') + 4);
    }

    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// 格式化发布时间为相对时间描述
  /// [timestamp] - 时间戳（秒）
  /// 返回：如 "2小时前"、"3天前"
  String _formatPublishTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final now = DateTime.now();
    final publishDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = now.difference(publishDate);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${publishDate.month}-${publishDate.day}';
    }
  }

  /// 格式化比赛时间（时间戳秒 → HH:mm）
  /// [timestamp] - 时间戳（秒）
  /// 返回：如 "20:00"
  String _formatMatchTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// 根据状态ID判断比赛状态
  /// [statusId] - 状态ID
  /// 返回：MatchStatus
  MatchStatus _matchStatusFromId(int? statusId) {
    if (statusId == 2 || statusId == 3 || statusId == 4) {
      return MatchStatus.live;
    } else if (statusId == 8 || statusId == 9) {
      return MatchStatus.finished;
    }
    return MatchStatus.upcoming;
  }

  /// 从球队名称提取缩写
  /// [name] - 球队名称
  /// 返回：3字符缩写
  String _extractShort(String? name) {
    if (name == null || name.isEmpty) return '';
    if (name.length <= 3) return name.toUpperCase();
    return name.substring(0, 3).toUpperCase();
  }
}

import '../utils/hank_network_manager.dart';
import '../models/hank_post_api_model.dart';
import '../models/post_model.dart';
import '../models/match_model.dart';
import '../models/team_model.dart';

/// HankCommunityTab: CommunitylistTabtypeenum
/// maps to API type paramcount：Featured=1，recent=2，Follow=3
enum HankCommunityTab {
  /// Featured type=1
  recommend(1),

  /// recent type=2
  recent(2),

  /// Follow type=3
  follow(3);

  /// APImaps to type value
  final int value;
  const HankCommunityTab(this.value);
}

/// HankCommunityApiService: CommunitylistAPI service
/// wrap /api/livespeed/community/list GET request
/// BackDatapasspass HankPostItem → PostModel convertfor UI useuse
class HankCommunityApiService {
  /// singleton instance
  static final HankCommunityApiService _instance =
      HankCommunityApiService._internal();

  /// factoryconstructor，Backsingleton
  factory HankCommunityApiService() {
    return _instance;
  }

  /// private constructor
  HankCommunityApiService._internal();

  /// APIpath
  static const String _apiPath = '/api/livespeed/community/list';

  /// requestCommunityPostlist
  /// [tab] - menuTabtype（Featured/recent/Follow）
  /// [page] - categorypagepagecode（from1start）
  /// [size] - eachpageitemcount
  /// [matchType] - matchtype，default1
  /// Back：HankPostData rawresponseData
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

  /// requestCommunityPostlistandconvert to PostModel list
  /// paramcountsame [fetchPostList]
  /// Back：List<PostModel>，for UI componentdirectlyuseuse
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

  /// convert APImodel HankPostItem convert to UI model PostModel
  /// [item] - APIBacksinglePostData
  /// Back：PostModel
  PostModel _convertToPostModel(HankPostItem item) {
    // parsetopictag：image fieldmaycontains "com/" beforesuffix，commacategoryseparated
    final hashtags = _parseHashtags(item.image);

    // buildembeddedmatchmodel
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
      userName: item.author?.name ?? 'anonymousnamegoalfan',
      userAvatarUrl: item.author?.avatar,
      userBadge: item.author?.isSubscribe == true ? 'Followed' : null,
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

  /// parsetopictag
  /// [rawImage] - APIBack image field，maycontains "com/" beforesuffix，commacategoryseparated
  /// Back：List<String> topictagcountgroup
  List<String> _parseHashtags(String? rawImage) {
    if (rawImage == null || rawImage.isEmpty) return [];

    String raw = rawImage;
    // goremove "com/" beforesuffix
    if (raw.contains('com/')) {
      raw = raw.substring(raw.indexOf('com/') + 4);
    }

    return raw
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
  }

  /// formatPostTimeisrelativeTimedescription
  /// [timestamp] - Timetimestamp（seconds）
  /// Back：e.g. "2underwhenbefore"、"3daybefore"
  String _formatPublishTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final now = DateTime.now();
    final publishDate = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final diff = now.difference(publishDate);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}minbefore';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}underwhenbefore';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}daybefore';
    } else {
      return '${publishDate.month}-${publishDate.day}';
    }
  }

  /// formatmatchTime（Timetimestampseconds → HH:mm）
  /// [timestamp] - Timetimestamp（seconds）
  /// Back：e.g. "20:00"
  String _formatMatchTime(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// rootbased onstatusIDcheckmatchstatus
  /// [statusId] - statusID
  /// Back：MatchStatus
  MatchStatus _matchStatusFromId(int? statusId) {
    if (statusId == 2 || statusId == 3 || statusId == 4) {
      return MatchStatus.live;
    } else if (statusId == 8 || statusId == 9) {
      return MatchStatus.finished;
    }
    return MatchStatus.upcoming;
  }

  /// fromTeamnameextractgetabbrevwrite
  /// [name] - Teamname
  /// Back：3charcharabbrevwrite
  String _extractShort(String? name) {
    if (name == null || name.isEmpty) return '';
    if (name.length <= 3) return name.toUpperCase();
    return name.substring(0, 3).toUpperCase();
  }
}

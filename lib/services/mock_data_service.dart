import '../models/match_model.dart';
import '../models/team_model.dart';
import '../models/news_model.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';

/// MockDataService: 模拟数据服务
/// 用于生成原型中展示的静态模拟数据，替代后端接口
class MockDataService {
  /// 获取模拟比赛列表
  static List<MatchModel> getMatchList() {
    return [
      MatchModel(
        matchId: 'm_001',
        leagueName: '欧洲冠军联赛 · 1/4决赛',
        leagueColor: 0xFFFBBF24,
        homeTeam: TeamModel(
          teamId: 't_rm',
          teamName: '皇家马德里',
          teamShort: 'RMA',
          logoUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=100',
          primaryColor: 0xFFFEF2F2,
          textColor: 0xFF991B1B,
        ),
        awayTeam: TeamModel(
          teamId: 't_mc',
          teamName: '曼彻斯特城',
          teamShort: 'MCI',
          logoUrl: 'https://images.unsplash.com/photo-1522778119026-d647f0596c20?w=100',
          primaryColor: 0xFFDBEAFE,
          textColor: 0xFF1D4ED8,
        ),
        homeScore: 2,
        awayScore: 1,
        matchTime: 'LIVE 78\'',
        status: MatchStatus.live,
        liveMinute: "78'",
        halfTimeScore: '半场 (1-0)',
        goalEvents: ['⚽ 34\' 贝林厄姆', '⚽ 62\' 哈兰德 (P)'],
        isFeatured: true,
        isFollowed: true,
        matchTag: '#欧冠半决赛',
      ),
      MatchModel(
        matchId: 'm_002',
        leagueName: '英格兰足球超级联赛',
        leagueColor: 0xFFFBBF24,
        homeTeam: TeamModel(
          teamId: 't_ars',
          teamName: '阿森纳',
          teamShort: 'ARS',
          primaryColor: 0xFFFEE2E2,
          textColor: 0xFF991B1B,
        ),
        awayTeam: TeamModel(
          teamId: 't_che',
          teamName: '切尔西',
          teamShort: 'CHE',
          primaryColor: 0xFFDBEAFE,
          textColor: 0xFF1E40AF,
        ),
        matchTime: '20:00 未开赛',
        status: MatchStatus.upcoming,
        isFollowed: true,
        homeWinRate: 52,
        drawRate: 26,
        awayWinRate: 22,
        matchTag: '#英超争冠',
      ),
      MatchModel(
        matchId: 'm_003',
        leagueName: '西班牙足球甲级联赛',
        leagueColor: 0xFF7C3AED,
        homeTeam: TeamModel(
          teamId: 't_bar',
          teamName: '巴塞罗那',
          teamShort: 'BAR',
          primaryColor: 0xFFFEE2E2,
          textColor: 0xFF991B1B,
        ),
        awayTeam: TeamModel(
          teamId: 't_atm',
          teamName: '马德里竞技',
          teamShort: 'ATM',
          primaryColor: 0xFF7F1D1D,
          textColor: 0xFF7F1D1D,
        ),
        homeScore: 3,
        awayScore: 0,
        matchTime: '已完赛',
        status: MatchStatus.finished,
        matchTag: '#西甲争冠',
      ),
      MatchModel(
        matchId: 'm_004',
        leagueName: '意大利足球甲级联赛',
        leagueColor: 0xFF10B981,
        homeTeam: TeamModel(
          teamId: 't_int',
          teamName: '国际米兰',
          teamShort: 'INT',
          primaryColor: 0xFF1E293B,
          textColor: 0xFFFFFFFF,
        ),
        awayTeam: TeamModel(
          teamId: 't_mil',
          teamName: 'AC米兰',
          teamShort: 'MIL',
          primaryColor: 0xFFDC2626,
          textColor: 0xFF000000,
        ),
        matchTime: '明日 03:45',
        status: MatchStatus.upcoming,
        matchTag: '#米兰德比',
      ),
    ];
  }

  /// 获取关注的比赛列表（模拟）
  static List<MatchModel> getFollowedMatches() {
    final all = getMatchList();
    return all.where((m) => m.isFollowed).toList();
  }

  /// 获取模拟资讯列表
  static List<NewsModel> getNewsList() {
    return [
      NewsModel(
        newsId: 'n_001',
        type: NewsType.feature,
        title: '【解析】高位逼抢的解毒剂：看安切洛蒂如何利用中场摆脱破解全场人盯人',
        coverImageUrl:
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600',
        categoryTag: '深度战术拆解',
        categoryBgColor: 0xFF7C3AED,
        categoryTextColor: 0xFFFFFFFF,
        source: '紫极战术室',
        timeDesc: '2小时前',
        readCountDesc: '1.8万阅读',
      ),
      NewsModel(
        newsId: 'n_002',
        type: NewsType.compact,
        title: '重磅！姆巴佩正式完成签约仪式，身披9号球衣亮相伯纳乌',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=200',
        categoryTag: '转会风云',
        categoryBgColor: 0xFFEDE9FE,
        categoryTextColor: 0xFF7C3AED,
        source: '天空体育',
        timeDesc: '3小时前',
        commentCount: 432,
      ),
      NewsModel(
        newsId: 'n_003',
        type: NewsType.compact,
        title: '阿森纳伤情报告：萨卡已恢复全队合练，有望在本周末北伦敦德比首发',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1560272564-669520742494?w=200',
        categoryTag: '伤情更新',
        categoryBgColor: 0xFFD1FAE5,
        categoryTextColor: 0xFF059669,
        source: '队医前线',
        timeDesc: '4小时前',
        commentCount: 189,
      ),
      NewsModel(
        newsId: 'n_004',
        type: NewsType.feature,
        title: '亚马尔的蜕变之路：从拉玛西亚神童到国家队核心',
        coverImageUrl:
            'https://images.unsplash.com/photo-1511886929837-354d827aae26?w=600',
        categoryTag: '金童奖观察',
        categoryBgColor: 0xFFF59E0B,
        categoryTextColor: 0xFF0F172A,
        source: '世界体育报',
        timeDesc: '5小时前',
      ),
    ];
  }

  /// 获取模拟社区帖子列表
  static List<PostModel> getPostList() {
    return [
      PostModel(
        postId: 'p_001',
        userId: 'u_001',
        userName: '伯纳乌饮水机',
        userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
        userBadge: 'LV.8',
        userBadgeBgColor: 0xFFEDE9FE,
        userBadgeTextColor: 0xFF7C3AED,
        publishTime: '15分钟前',
        location: '来自马德里',
        hashtags: ['#欧冠半决赛'],
        content:
            '今天皇马的中场转换真的太丝滑了！贝林厄姆的无球跑动拉开了巨大的空间，曼城后防完全被牵着走。大伙觉得次回合谁能晋级？',
        embeddedMatch: MatchModel(
          matchId: 'm_001_embed',
          leagueName: '欧冠 1/4决赛',
          leagueColor: 0xFFFBBF24,
          homeTeam: TeamModel(
            teamId: 't_rm_2',
            teamName: '皇马',
            teamShort: 'RMA',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF991B1B,
          ),
          awayTeam: TeamModel(
            teamId: 't_mc_2',
            teamName: '曼城',
            teamShort: 'MCI',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF1D4ED8,
          ),
          homeScore: 2,
          awayScore: 1,
          matchTime: 'LIVE',
          status: MatchStatus.live,
          liveMinute: "LIVE",
        ),
        likeCount: 352,
        commentCount: 84,
        shareCount: 12,
      ),
      PostModel(
        postId: 'p_002',
        userId: 'u_002',
        userName: '战术板大师',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        userBadge: 'VIP',
        userBadgeBgColor: 0xFFFEF3C7,
        userBadgeTextColor: 0xFF92400E,
        publishTime: '1小时前',
        hashtags: ['#英超争冠'],
        content:
            '阿森纳今晚的角球战术布置，近角抢点掩护后点，战术配合极其严密。',
        embeddedMatch: MatchModel(
          matchId: 'm_002_embed',
          leagueName: '英超 第32轮',
          leagueColor: 0xFFFBBF24,
          homeTeam: TeamModel(
            teamId: 't_ars_2',
            teamName: '阿森纳',
            teamShort: 'ARS',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF991B1B,
          ),
          awayTeam: TeamModel(
            teamId: 't_che_2',
            teamName: '切尔西',
            teamShort: 'CHE',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF1E40AF,
          ),
          matchTime: '今晚 20:00',
          status: MatchStatus.upcoming,
        ),
        likeCount: 128,
        commentCount: 32,
        shareCount: 5,
      ),
    ];
  }

  /// 获取社区话题标签
  static List<Map<String, dynamic>> getCommunityTopics() {
    return [
      {'name': '🔥 热门讨论', 'isHot': true},
      {'name': '#欧冠巅峰对决', 'isHot': false},
      {'name': '#英超争冠', 'isHot': false},
      {'name': '#战术演练', 'isHot': false},
      {'name': '#转会爆料', 'isHot': false},
    ];
  }

  /// 获取热门搜索关键词
  static List<String> getHotSearches() {
    return ['皇家马德里', '阿森纳', '迈阿密国际', '巴塞罗那', '姆巴佩', '欧冠'];
  }

  /// 获取用户个人中心信息
  static UserProfileModel getUserProfile() {
    return UserProfileModel(
      userId: 'u_me',
      nickname: 'Alex Vance',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      isPro: true,
      signature: '⚽ 枪手20年老球迷 | 深度足球战术分析师',
      followingCount: 128,
      followerCount: 2400,
      postCount: 86,
      predictWinRate: 68,
      profileCompletion: 85,
    );
  }
}

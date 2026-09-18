import '../models/match_model.dart';
import '../models/team_model.dart';
import '../models/news_model.dart';
import '../models/post_model.dart';
import '../models/user_profile_model.dart';

/// MockDataService: modesimulateDataservice
/// usegeneratecompleteprototypeindisplaycalmstatemodesimulateData，replaceafterendAPI
class MockDataService {
  /// getmodesimulatematchlist
  static List<MatchModel> getMatchList() {
    return [
      MatchModel(
        matchId: 'm_001',
        leagueName: 'EuropechampionLeague · 1/4Final',
        leagueColor: 0xFFFBBF24,
        homeTeam: TeamModel(
          teamId: 't_rm',
          teamName: 'Real Madriddefendin',
          teamShort: 'RMA',
          logoUrl: 'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?w=100',
          primaryColor: 0xFFFEF2F2,
          textColor: 0xFF991B1B,
        ),
        awayTeam: TeamModel(
          teamId: 't_mc',
          teamName: '',
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
        halfTimeScore: 'HT (1-0)',
        goalEvents: ['⚽ 34\' Bellingham', '⚽ 62\' Haalanddefend (P)'],
        isFeatured: true,
        isFollowed: true,
        matchTag: '#UCL semiFinal',
      ),
      MatchModel(
        matchId: 'm_002',
        leagueName: 'EnglandFootballoverlevelLeague',
        leagueColor: 0xFFFBBF24,
        homeTeam: TeamModel(
          teamId: 't_ars',
          teamName: 'Arsenal',
          teamShort: 'ARS',
          primaryColor: 0xFFFEE2E2,
          textColor: 0xFF991B1B,
        ),
        awayTeam: TeamModel(
          teamId: 't_che',
          teamName: 'toggleRice',
          teamShort: 'CHE',
          primaryColor: 0xFFDBEAFE,
          textColor: 0xFF1E40AF,
        ),
        matchTime: '20:00 not started',
        status: MatchStatus.upcoming,
        isFollowed: true,
        homeWinRate: 52,
        drawRate: 26,
        awayWinRate: 22,
        matchTag: '#Premier Leaguetitle race',
      ),
      MatchModel(
        matchId: 'm_003',
        leagueName: 'SpainFootballleaguelevelLeague',
        leagueColor: 0xFF7C3AED,
        homeTeam: TeamModel(
          teamId: 't_bar',
          teamName: 'Barcelona',
          teamShort: 'BAR',
          primaryColor: 0xFFFEE2E2,
          textColor: 0xFF991B1B,
        ),
        awayTeam: TeamModel(
          teamId: 't_atm',
          teamName: 'defendinathletic',
          teamShort: 'ATM',
          primaryColor: 0xFF7F1D1D,
          textColor: 0xFF7F1D1D,
        ),
        homeScore: 3,
        awayScore: 0,
        matchTime: 'alreadyfinishedmatch',
        status: MatchStatus.finished,
        matchTag: '#westleaguetitle race',
      ),
      MatchModel(
        matchId: 'm_004',
        leagueName: 'agreebigLiFootballleaguelevelLeague',
        leagueColor: 0xFF10B981,
        homeTeam: TeamModel(
          teamId: 't_int',
          teamName: 'nationalactualMilan',
          teamShort: 'INT',
          primaryColor: 0xFF1E293B,
          textColor: 0xFFFFFFFF,
        ),
        awayTeam: TeamModel(
          teamId: 't_mil',
          teamName: 'ACMilan',
          teamShort: 'MIL',
          primaryColor: 0xFFDC2626,
          textColor: 0xFF000000,
        ),
        matchTime: 'Tomorrow 03:45',
        status: MatchStatus.upcoming,
        matchTag: '#Milandefendmatch',
      ),
    ];
  }

  /// getFollowmatchlist（modesimulate）
  static List<MatchModel> getFollowedMatches() {
    final all = getMatchList();
    return all.where((m) => m.isFollowed).toList();
  }

  /// getmodesimulatenewslist
  static List<NewsModel> getNewsList() {
    return [
      NewsModel(
        newsId: 'n_001',
        type: NewsType.feature,
        title: '【parse】presssolveantidote：viewsafetoggleLottie.g.Henryusehalftimeshake offsolveallmatchpersonmarkperson',
        coverImageUrl:
            'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600',
        categoryTag: 'darkdepthtacticalbreakdownsolve',
        categoryBgColor: 0xFF7C3AED,
        categoryTextColor: 0xFFFFFFFF,
        source: 'violettacticalroom',
        timeDesc: '2underwhenbefore',
        readCountDesc: '1.80k views',
      ),
      NewsModel(
        newsId: 'n_002',
        type: NewsType.compact,
        title: '！Mbappeactivestylefinishedcompletesignedinstrumentstyle，wears9numberjerseyhighlightphaseBernabeu',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1518091043644-c1d4457512c6?w=200',
        categoryTag: 'transferdrama',
        categoryBgColor: 0xFFEDE9FE,
        categoryTextColor: 0xFF7C3AED,
        source: 'dayemptySports',
        timeDesc: '3underwhenbefore',
        commentCount: 432,
      ),
      NewsModel(
        newsId: 'n_003',
        type: NewsType.compact,
        title: 'Arsenalinjuryintel：Sakacardalreadyrestoreallteamtraining，hasexpectinnorth endLondondefendmatchstarter',
        thumbnailUrl:
            'https://images.unsplash.com/photo-1560272564-669520742494?w=200',
        categoryTag: 'injurynewsupdate',
        categoryBgColor: 0xFFD1FAE5,
        categoryTextColor: 0xFF059669,
        source: 'teammedicalbeforeline',
        timeDesc: '4underwhenbefore',
        commentCount: 189,
      ),
      NewsModel(
        newsId: 'n_004',
        type: NewsType.feature,
        title: 'Asiachangeroad：frompullMasseyAsiaprodigytoCountryteamcorecore',
        coverImageUrl:
            'https://images.unsplash.com/photo-1511886929837-354d827aae26?w=600',
        categoryTag: 'Golden Boy Watcher',
        categoryBgColor: 0xFFF59E0B,
        categoryTextColor: 0xFF0F172A,
        source: 'worldSportsreport',
        timeDesc: '5underwhenbefore',
      ),
    ];
  }

  /// getmodesimulateCommunityPostlist
  static List<PostModel> getPostList() {
    return [
      PostModel(
        postId: 'p_001',
        userId: 'u_001',
        userName: 'Bernabeudrinkoddsbot',
        userAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100',
        userBadge: 'LV.8',
        userBadgeBgColor: 0xFFEDE9FE,
        userBadgeTextColor: 0xFF7C3AED,
        publishTime: '15minbefore',
        location: 'from Madrid',
        hashtags: ['#UCL semiFinal'],
        content:
            'TodayReal Madridhalftimeconvertslide！Bellinghamnonegoalrunanimationpullopenhugebigemptybetween，Man Cityafterdefensefinishedallbylead by。bigfangottimebackwho will advancelevel？',
        embeddedMatch: MatchModel(
          matchId: 'm_001_embed',
          leagueName: 'UCL 1/4Final',
          leagueColor: 0xFFFBBF24,
          homeTeam: TeamModel(
            teamId: 't_rm_2',
            teamName: 'Real Madrid',
            teamShort: 'RMA',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF991B1B,
          ),
          awayTeam: TeamModel(
            teamId: 't_mc_2',
            teamName: 'Man City',
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
        userName: 'Tactical Master',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        userBadge: 'VIP',
        userBadgeBgColor: 0xFFFEF3C7,
        userBadgeTextColor: 0xFF92400E,
        publishTime: '1underwhenbefore',
        hashtags: ['#Premier Leaguetitle race'],
        content:
            'ArsenaltodaylaterCornerstacticallayoutset，nearcornerpresspointcoverafterpoint，tacticaldispatchextremeitstight。',
        embeddedMatch: MatchModel(
          matchId: 'm_002_embed',
          leagueName: 'Premier League 32round',
          leagueColor: 0xFFFBBF24,
          homeTeam: TeamModel(
            teamId: 't_ars_2',
            teamName: 'Arsenal',
            teamShort: 'ARS',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF991B1B,
          ),
          awayTeam: TeamModel(
            teamId: 't_che_2',
            teamName: 'toggleRice',
            teamShort: 'CHE',
            primaryColor: 0xFFFFFFFF,
            textColor: 0xFF1E40AF,
          ),
          matchTime: 'todaylater 20:00',
          status: MatchStatus.upcoming,
        ),
        likeCount: 128,
        commentCount: 32,
        shareCount: 5,
      ),
    ];
  }

  /// getCommunitytopictag
  static List<Map<String, dynamic>> getCommunityTopics() {
    return [
      {'name': '🔥 Trendingdiscussion', 'isHot': true},
      {'name': '#UCL peakmatchdecide', 'isHot': false},
      {'name': '#Premier Leaguetitle race', 'isHot': false},
      {'name': '#tactical', 'isHot': false},
      {'name': '#transferscoop', 'isHot': false},
    ];
  }

  /// getTrendingSearchkeyword
  static List<String> getHotSearches() {
    return ['Real Madriddefendin', 'Arsenal', 'Miami International', 'Barcelona', 'Mbappe', 'UCL'];
  }

  /// getuseaccountprofileinfo
  static UserProfileModel getUserProfile() {
    return UserProfileModel(
      userId: 'u_me',
      nickname: 'Alex Vance',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      isPro: true,
      signature: '⚽ hand20yearveterangoalfan | darkdepthFootballtacticalcategoryanalysis',
      followingCount: 128,
      followerCount: 2400,
      postCount: 86,
      predictWinRate: 68,
      profileCompletion: 85,
    );
  }
}

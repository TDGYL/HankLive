import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/hank_process_model.dart';
import '../../models/hank_odds_model.dart';
import '../../models/hank_lineup_model.dart';
import '../../services/hank_match_detail_api_service.dart';
import '../../utils/hank_auth_manager.dart';
import '../../utils/hank_network_manager.dart';
import '../../widgets/match/match_detail_scoreboard.dart';
import '../../widgets/match/match_detail_live_tab.dart';
import '../../widgets/match/match_detail_lineup_tab.dart';
import '../../widgets/match/match_detail_stats_tab.dart';
import '../../widgets/match/match_detail_odds_tab.dart';
import '../../widgets/match/match_detail_h2h_tab.dart';
import '../../widgets/match/hank_match_posts_tab.dart';
import '../../models/hank_h2h_model.dart';
import '../community/post_community_page.dart';
import '../login/login_page.dart';

/// MatchDetailTab: 详情页Tab枚举
/// live: 图文赛况 | lineup: 首发阵容 | stats: 技术统计 | odds: 指数分析 | posts: 帖子
enum MatchDetailTab {
  /// 图文赛况
  live,
  /// 首发阵容
  lineup,
  /// 技术统计
  stats,
  /// 指数分析
  odds,
  /// 历史交锋
  h2h,
  /// 帖子
  posts,
}

/// MatchDetailPage: 比赛详情页面
/// 包含顶部计分板 + 4个Tab（图文赛况/首发阵容/技术统计/指数分析）
/// 浅紫色+白色主题风格
/// 数据请求：
///   1. GET /api/livespeed/football/match/detail → 比赛详情（计分板数据）
///   2. GET /api/livespeed/football/match/process → 进程数据（incidents + stats）
/// 首发阵容和指数分析使用本地Mock数据
class MatchDetailPage extends StatefulWidget {
  /// 比赛数据
  final MatchModel match;

  MatchDetailPage({
    required this.match,
    Key? key,
  }) : super(key: key);

  @override
  _MatchDetailPageState createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  /// 当前选中的Tab
  MatchDetailTab _currentTab = MatchDetailTab.live;

  /// 详情接口服务
  final HankMatchDetailApiService _apiService = HankMatchDetailApiService();

  /// 比赛进程数据（incidents + stats）
  HankProcessData? _processData;

  /// 是否正在加载进程数据
  bool _isLoadingProcess = true;

  /// 阵容数据（首发/替补/伤停/教练/阵型）
  HankLineupData? _lineupData;

  /// 是否正在加载阵容数据
  bool _isLoadingLineup = false;

  /// 指数数据（亚盘/欧赔/大小球/角球）
  HankOddsData? _oddsData;

  /// 是否正在加载指数数据
  bool _isLoadingOdds = false;

  /// 历史交锋数据列表
  List<HankH2HMatch> _h2hMatches = [];

  /// 是否正在加载历史交锋数据
  bool _isLoadingH2H = false;

  /// 是否已请求过历史交锋数据
  bool _hasFetchedH2H = false;

  /// 是否已订阅比赛 - bool类型，true表示已订阅
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _fetchProcessData();
    _fetchMatchDetail();
  }

  /// 请求比赛详情（获取订阅状态）
  /// 接口：GET /api/livespeed/football/match/detail
  Future<void> _fetchMatchDetail() async {
    final matchId = int.tryParse(widget.match.matchId) ?? 0;
    if (matchId == 0) return;

    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/match/detail',
      queryParameters: {'match_id': matchId},
    );

    if (response.isSuccess && response.data != null && mounted) {
      final data = response.data as Map<String, dynamic>;
      setState(() {
        _isSubscribed = data['subscribed'] == true;
      });
    }
  }

  /// 切换比赛订阅状态
  /// 订阅接口：POST /api/livespeed/football/match/subscribe
  /// 取消订阅接口：POST /api/livespeed/football/match/unsubscribe
  Future<void> _toggleSubscribe() async {
    if (!HankAuthManager().isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HankLoginPage()),
      );
      return;
    }

    final matchId = int.tryParse(widget.match.matchId) ?? 0;
    if (matchId == 0) return;

    final willSubscribe = !_isSubscribed;
    final url = willSubscribe
        ? '/api/livespeed/football/match/subscribe'
        : '/api/livespeed/football/match/unsubscribe';

    try {
      final response = await HankNetworkManager().postRequest(
        url,
        data: {'match_id': matchId},
      );

      if (!mounted) return;

      if (response.isSuccess) {
        setState(() {
          _isSubscribed = willSubscribe;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(willSubscribe ? '已订阅' : '已取消订阅'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? '操作失败，请重试'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('网络错误，请重试'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  /// 请求比赛进程数据（incidents + stats）
  /// 接口：GET /api/livespeed/football/match/process
  Future<void> _fetchProcessData() async {
    final matchId = int.tryParse(widget.match.matchId) ?? 0;
    if (matchId == 0) {
      setState(() => _isLoadingProcess = false);
      return;
    }

    final data = await _apiService.fetchMatchProcess(matchId: matchId);

    if (mounted) {
      setState(() {
        _processData = data;
        _isLoadingProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTab == MatchDetailTab.posts) {
      return Scaffold(
        backgroundColor: AppColors.violet50,
        body: Column(
          children: [
            _buildAppBar(),
            _buildScoreboard(),
            _buildTabBar(),
            Expanded(child: _buildPostsTab()),
          ],
        ),
        floatingActionButton: _buildFloatingAddButton(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.violet50,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildScoreboard(),
                  _buildTabBar(),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 右下角发帖浮动按钮（圆形浅紫色，宽高40像素）
  Widget _buildFloatingAddButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HankPostCommunityPage(matchModel: widget.match),
          ),
        ).then((published) {
          if (published == true) {
            setState(() {
              _currentTab = MatchDetailTab.posts;
            });
          }
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.violet400, AppColors.violet600],
          ),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x407C3AED),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 顶部导航栏（仅返回按钮 + 联赛信息）
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // 返回按钮
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: AppColors.violet700,
                ),
              ),
            ),
            const Spacer(),
            // 联赛信息
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.violet100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.match.leagueName,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.violet700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Spacer(),
            // 订阅按钮（固定24x24，离屏幕右边15像素）
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: _toggleSubscribe,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: Icon(
                    _isSubscribed
                        ? Icons.notifications
                        : Icons.notifications_outlined,
                    size: 24,
                    color: _isSubscribed
                        ? AppColors.violet600
                        : AppColors.violet400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部计分板
  Widget _buildScoreboard() {
    return MatchDetailScoreboard(
      match: widget.match,
      roundInfo: widget.match.leagueName,
      venueInfo: '伦敦体育场 · 主裁判: 迈克尔·奥利弗',
      halfTimeScore: null,
      liveMinute: int.tryParse(widget.match.liveMinute?.replaceAll("'", '') ?? ''),
    );
  }

  /// Tab导航栏
  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(MatchDetailTab.live, '图文赛况'),
          _buildTabButton(MatchDetailTab.posts, '帖子'),
          _buildTabButton(MatchDetailTab.lineup, '首发阵容'),
          _buildTabButton(MatchDetailTab.stats, '技术统计'),
          _buildTabButton(MatchDetailTab.odds, '指数分析'),
          _buildTabButton(MatchDetailTab.h2h, '历史交锋'),
        ],
      ),
    );
  }

  /// Tab按钮
  Widget _buildTabButton(MatchDetailTab tab, String label) {
    final isSelected = _currentTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.violet600 : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.violet600 : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  /// Tab内容区域（帖子Tab在build中单独处理）
  Widget _buildTabContent() {
    switch (_currentTab) {
      case MatchDetailTab.live:
        return _buildLiveTab();
      case MatchDetailTab.lineup:
        return _buildLineupTab();
      case MatchDetailTab.stats:
        return _buildStatsTab();
      case MatchDetailTab.odds:
        return _buildOddsTab();
      case MatchDetailTab.h2h:
        return _buildH2HTab();
      case MatchDetailTab.posts:
        return const SizedBox.shrink();
    }
  }

  /// 图文赛况Tab（使用接口incidents数据）
  Widget _buildLiveTab() {
    if (_isLoadingProcess) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.violet600,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final incidents = _processData?.incidents ?? [];
    return MatchDetailLiveTab(incidents: incidents);
  }

  /// 首发阵容Tab（懒加载接口数据）
  /// 接口：GET /api/livespeed/football/match/lineup
  Widget _buildLineupTab() {
    if (_lineupData == null && !_isLoadingLineup) {
      _fetchLineupData();
    }
    return MatchDetailLineupTab(
      lineupData: _lineupData,
      isLoading: _isLoadingLineup || _lineupData == null,
      homeTeamName: widget.match.homeTeam.teamName,
      awayTeamName: widget.match.awayTeam.teamName,
      homeTeamLogo: widget.match.homeTeam.logoUrl,
      awayTeamLogo: widget.match.awayTeam.logoUrl,
    );
  }

  /// 请求比赛阵容数据（首发/替补/伤停/教练/阵型）
  /// 接口：GET /api/livespeed/football/match/lineup
  Future<void> _fetchLineupData() async {
    final matchId = int.tryParse(widget.match.matchId) ?? 0;
    if (matchId == 0) return;

    setState(() => _isLoadingLineup = true);

    final data = await _apiService.fetchMatchLineup(matchId: matchId);

    if (mounted) {
      setState(() {
        _lineupData = data;
        _isLoadingLineup = false;
      });
    }
  }

  /// 技术统计Tab（使用接口stats数据，无主导率UI）
  Widget _buildStatsTab() {
    if (_isLoadingProcess) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.violet600,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final stats = _processData?.stats ?? [];
    return MatchDetailStatsTab(stats: stats);
  }

  /// 帖子Tab（社区帖子列表，接口与community_page一致）
  Widget _buildPostsTab() {
    return HankMatchPostsTab(
      matchId: int.tryParse(widget.match.matchId) ?? 0,
    );
  }

  /// 指数分析Tab（使用接口odds数据）
  Widget _buildOddsTab() {
    if (_oddsData == null && !_isLoadingOdds) {
      _fetchOddsData();
    }
    return MatchDetailOddsTab(
      oddsData: _oddsData,
      isLoading: _isLoadingOdds || _oddsData == null,
      matchId: int.tryParse(widget.match.matchId) ?? 0,
    );
  }

  /// 请求比赛指数数据（亚盘/欧赔/大小球/角球）
  /// 接口：GET /api/livespeed/football/match/odds
  Future<void> _fetchOddsData() async {
    final matchId = int.tryParse(widget.match.matchId) ?? 0;
    if (matchId == 0) return;

    setState(() => _isLoadingOdds = true);

    final data = await _apiService.fetchMatchOdds(matchId: matchId);

    if (mounted) {
      setState(() {
        _oddsData = data;
        _isLoadingOdds = false;
      });
    }
  }

  /// 历史交锋Tab（暂用Mock数据，还原h2h.html界面）
  Widget _buildH2HTab() {
    return MatchDetailH2HTab(
      matches: _getMockH2HMatches(),
      homeTeamId: int.tryParse(widget.match.homeTeam.teamId) ?? 0,
      homeTeamName: widget.match.homeTeam.teamName,
      homeTeamLogo: widget.match.homeTeam.logoUrl ?? '',
      awayTeamId: int.tryParse(widget.match.awayTeam.teamId) ?? 0,
      awayTeamName: widget.match.awayTeam.teamName,
      awayTeamLogo: widget.match.awayTeam.logoUrl ?? '',
      isLoading: false,
    );
  }

  /// Mock历史交锋数据（参照h2h.html）
  List<HankH2HMatch> _getMockH2HMatches() {
    final homeId = int.tryParse(widget.match.homeTeam.teamId) ?? 1;
    final awayId = int.tryParse(widget.match.awayTeam.teamId) ?? 2;
    return [
      HankH2HMatch(
        matchId: 1,
        competitionName: '西甲',
        competitionLogo: '',
        homeTeamId: homeId,
        homeTeamName: widget.match.homeTeam.teamName,
        homeTeamLogo: widget.match.homeTeam.logoUrl ?? '',
        awayTeamId: awayId,
        awayTeamName: widget.match.awayTeam.teamName,
        awayTeamLogo: widget.match.awayTeam.logoUrl ?? '',
        matchTime: 1713744000,
        homeNormalScore: 3,
        awayNormalScore: 2,
        homeHalfScore: 1,
        awayHalfScore: 1,
      ),
      HankH2HMatch(
        matchId: 2,
        competitionName: '西超杯',
        competitionLogo: '',
        homeTeamId: homeId,
        homeTeamName: widget.match.homeTeam.teamName,
        homeTeamLogo: widget.match.homeTeam.logoUrl ?? '',
        awayTeamId: awayId,
        awayTeamName: widget.match.awayTeam.teamName,
        awayTeamLogo: widget.match.awayTeam.logoUrl ?? '',
        matchTime: 1705276800,
        homeNormalScore: 4,
        awayNormalScore: 1,
        homeHalfScore: 3,
        awayHalfScore: 1,
      ),
      HankH2HMatch(
        matchId: 3,
        competitionName: '西甲',
        competitionLogo: '',
        homeTeamId: awayId,
        homeTeamName: widget.match.awayTeam.teamName,
        homeTeamLogo: widget.match.awayTeam.logoUrl ?? '',
        awayTeamId: homeId,
        awayTeamName: widget.match.homeTeam.teamName,
        awayTeamLogo: widget.match.homeTeam.logoUrl ?? '',
        matchTime: 1698470400,
        homeNormalScore: 1,
        awayNormalScore: 2,
        homeHalfScore: 1,
        awayHalfScore: 0,
      ),
      HankH2HMatch(
        matchId: 4,
        competitionName: '国王杯',
        competitionLogo: '',
        homeTeamId: awayId,
        homeTeamName: widget.match.awayTeam.teamName,
        homeTeamLogo: widget.match.awayTeam.logoUrl ?? '',
        awayTeamId: homeId,
        awayTeamName: widget.match.homeTeam.teamName,
        awayTeamLogo: widget.match.homeTeam.logoUrl ?? '',
        matchTime: 1680739200,
        homeNormalScore: 0,
        awayNormalScore: 4,
        homeHalfScore: 0,
        awayHalfScore: 1,
      ),
      HankH2HMatch(
        matchId: 5,
        competitionName: '西甲',
        competitionLogo: '',
        homeTeamId: awayId,
        homeTeamName: widget.match.awayTeam.teamName,
        homeTeamLogo: widget.match.awayTeam.logoUrl ?? '',
        awayTeamId: homeId,
        awayTeamName: widget.match.homeTeam.teamName,
        awayTeamLogo: widget.match.homeTeam.logoUrl ?? '',
        matchTime: 1679260800,
        homeNormalScore: 2,
        awayNormalScore: 1,
        homeHalfScore: 1,
        awayHalfScore: 1,
      ),
      HankH2HMatch(
        matchId: 6,
        competitionName: '国王杯',
        competitionLogo: '',
        homeTeamId: homeId,
        homeTeamName: widget.match.homeTeam.teamName,
        homeTeamLogo: widget.match.homeTeam.logoUrl ?? '',
        awayTeamId: awayId,
        awayTeamName: widget.match.awayTeam.teamName,
        awayTeamLogo: widget.match.awayTeam.logoUrl ?? '',
        matchTime: 1677782400,
        homeNormalScore: 0,
        awayNormalScore: 1,
        homeHalfScore: 0,
        awayHalfScore: 1,
      ),
    ];
  }
}

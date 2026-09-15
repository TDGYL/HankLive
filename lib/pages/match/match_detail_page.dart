import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/hank_process_model.dart';
import '../../models/hank_odds_model.dart';
import '../../services/hank_match_detail_api_service.dart';
import '../../widgets/match/match_detail_scoreboard.dart';
import '../../widgets/match/match_detail_live_tab.dart';
import '../../widgets/match/match_detail_lineup_tab.dart';
import '../../widgets/match/match_detail_stats_tab.dart';
import '../../widgets/match/match_detail_odds_tab.dart';
import '../../services/hank_match_detail_service.dart';
import '../../models/hank_match_detail_model.dart';

/// MatchDetailTab: 详情页Tab枚举
/// live: 图文赛况 | lineup: 首发阵容 | stats: 技术统计 | odds: 指数分析
enum MatchDetailTab {
  /// 图文赛况
  live,
  /// 首发阵容
  lineup,
  /// 技术统计
  stats,
  /// 指数分析
  odds,
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

  /// Mock数据服务（阵容 + 指数分析）
  final HankMatchDetailService _mockService = HankMatchDetailService();

  /// 比赛进程数据（incidents + stats）
  HankProcessData? _processData;

  /// 是否正在加载进程数据
  bool _isLoadingProcess = true;

  /// 主队阵型（懒加载）
  HankMatchLineupFormation? _homeLineup;

  /// 客队阵型（懒加载）
  HankMatchLineupFormation? _awayLineup;

  /// 替补席球员（懒加载）
  List<HankMatchBenchPlayer>? _benchPlayers;

  /// 指数数据（亚盘/欧赔/大小球/角球）
  HankOddsData? _oddsData;

  /// 是否正在加载指数数据
  bool _isLoadingOdds = false;

  @override
  void initState() {
    super.initState();
    _fetchProcessData();
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
            // 闹钟按钮（固定24x24，离屏幕右边15像素）
            Padding(
              padding: const EdgeInsets.only(right: 15),
              child: SizedBox(
                width: 24,
                height: 24,
                child: const Icon(
                  Icons.notifications_outlined,
                  size: 24,
                  color: AppColors.violet700,
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
          _buildTabButton(MatchDetailTab.lineup, '首发阵容'),
          _buildTabButton(MatchDetailTab.stats, '技术统计'),
          _buildTabButton(MatchDetailTab.odds, '指数分析'),
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

  /// Tab内容区域
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

  /// 首发阵容Tab（懒加载Mock数据）
  Widget _buildLineupTab() {
    _homeLineup ??= _mockService.getHomeLineup();
    _awayLineup ??= _mockService.getAwayLineup();
    _benchPlayers ??= _mockService.getBenchPlayers();
    return MatchDetailLineupTab(
      homeFormation: _homeLineup!,
      awayFormation: _awayLineup!,
      benchPlayers: _benchPlayers!,
    );
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
}

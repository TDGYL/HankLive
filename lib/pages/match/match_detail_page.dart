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

/// MatchDetailTab: DetailspageTabenum
/// live: Articlematch events | lineup: starterLineup | stats: technicalstats | odds: Odds | posts: Post
enum MatchDetailTab {
  /// Articlematch events
  live,
  /// starterLineup
  lineup,
  /// technicalstats
  stats,
  /// Odds
  odds,
  /// H2H
  h2h,
  /// Post
  posts,
}

/// MatchDetailPage: matchDetailspage
/// containstopstatscategoryboard + 4eachTab（Articlematch events/starterLineup/technicalstats/Odds）
/// lightpurple+whitecolorhomethemestyle
/// Datarequest：
///   1. GET /api/livespeed/football/match/detail → matchDetails（statscategoryboardData）
///   2. GET /api/livespeed/football/match/process → progressData（incidents + stats）
/// starterLineupandOddsuseuselocalMockData
class MatchDetailPage extends StatefulWidget {
  /// matchData
  final MatchModel match;

  MatchDetailPage({
    required this.match,
    Key? key,
  }) : super(key: key);

  @override
  _MatchDetailPageState createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends State<MatchDetailPage> {
  /// whenbeforeselectedTab
  MatchDetailTab _currentTab = MatchDetailTab.live;

  /// DetailsAPI service
  final HankMatchDetailApiService _apiService = HankMatchDetailApiService();

  /// matchprogressData（incidents + stats）
  HankProcessData? _processData;

  /// whetherLoadingprogressData
  bool _isLoadingProcess = true;

  /// LineupData（starter/substitute/injured/Coach/formation）
  HankLineupData? _lineupData;

  /// whetherLoadingLineupData
  bool _isLoadingLineup = false;

  /// oddscountData（AH/1X2/O/Ugoal/Corners）
  HankOddsData? _oddsData;

  /// whetherLoadingoddscountData
  bool _isLoadingOdds = false;

  /// H2HDatalist
  List<HankH2HMatch> _h2hMatches = [];

  /// whetherLoadingH2HData
  bool _isLoadingH2H = false;

  /// whetheralreadyrequestpassH2HData
  bool _hasFetchedH2H = false;

  /// whetheralreadysubscribematch - booltype，truemeansalreadysubscribe
  bool _isSubscribed = false;

  @override
  void initState() {
    super.initState();
    _fetchProcessData();
    _fetchMatchDetail();
  }

  /// requestmatchDetails（getsubscribestatus）
  /// API：GET /api/livespeed/football/match/detail
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

  /// togglematchsubscribestatus
  /// subscribeAPI：POST /api/livespeed/football/match/subscribe
  /// CancelsubscribeAPI：POST /api/livespeed/football/match/unsubscribe
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
            content: Text(willSubscribe ? 'alreadysubscribe' : 'alreadyCancelsubscribe'),
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed，please retry'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error，please retry'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  /// requestmatchprogressData（incidents + stats）
  /// API：GET /api/livespeed/football/match/process
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

  /// rightdowncornerNew Postfloatbutton（rounded lightpurple，dimensions40pixels）
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

  /// topnavbar（onlyBackbutton + Leagueinfo）
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
            // Backbutton
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
            // Leagueinfo
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
            // subscribebutton（fixed24x24，off-screenrightborder15pixels）
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

  /// topstatscategoryboard
  Widget _buildScoreboard() {
    return MatchDetailScoreboard(
      match: widget.match,
      roundInfo: widget.match.leagueName,
      venueInfo: 'LondonSportsmatch · homeReferee: Michael·Oliver',
      halfTimeScore: null,
      liveMinute: int.tryParse(widget.match.liveMinute?.replaceAll("'", '') ?? ''),
    );
  }

  /// Tabnavbar
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
          _buildTabButton(MatchDetailTab.live, 'Events'),
          _buildTabButton(MatchDetailTab.posts, 'Post'),
          _buildTabButton(MatchDetailTab.lineup, 'Lineup'),
          _buildTabButton(MatchDetailTab.stats, 'Stats'),
          _buildTabButton(MatchDetailTab.odds, 'Odds'),
          _buildTabButton(MatchDetailTab.h2h, 'H2H'),
        ],
      ),
    );
  }

  /// Tabbutton
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

  /// Tabcontentarea（PostTabinbuildinsinglehandle）
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

  /// Articlematch eventsTab（useAPIincidentsData）
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

  /// starterLineupTab（lazy loadAPIData）
  /// API：GET /api/livespeed/football/match/lineup
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

  /// requestmatchLineupData（starter/substitute/injured/Coach/formation）
  /// API：GET /api/livespeed/football/match/lineup
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

  /// technicalstatsTab（useAPIstatsData，nonehomenavrateUI）
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

  /// PostTab（CommunityPostlist，APIwithcommunity_pageamatch）
  Widget _buildPostsTab() {
    return HankMatchPostsTab(
      matchId: int.tryParse(widget.match.matchId) ?? 0,
    );
  }

  /// OddsTab（useAPIoddsData）
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

  /// requestmatchoddscountData（AH/1X2/O/Ugoal/Corners）
  /// API：GET /api/livespeed/football/match/odds
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

  /// H2HTab（lazy loadAPIData）
  /// API：GET /api/livespeed/football/match/analysis
  Widget _buildH2HTab() {
    if (!_hasFetchedH2H && !_isLoadingH2H) {
      _fetchH2HData();
    }
    return MatchDetailH2HTab(
      matches: _h2hMatches,
      homeTeamId: int.tryParse(widget.match.homeTeam.teamId) ?? 0,
      homeTeamName: widget.match.homeTeam.teamName,
      homeTeamLogo: widget.match.homeTeam.logoUrl ?? '',
      awayTeamId: int.tryParse(widget.match.awayTeam.teamId) ?? 0,
      awayTeamName: widget.match.awayTeam.teamName,
      awayTeamLogo: widget.match.awayTeam.logoUrl ?? '',
      isLoading: _isLoadingH2H,
    );
  }

  /// requestH2HData
  /// API：GET /api/livespeed/football/match/analysis
  /// paramcount：match_id - matchID
  Future<void> _fetchH2HData() async {
    final matchId = int.tryParse(widget.match.matchId) ?? 0;
    if (matchId == 0) return;

    setState(() => _isLoadingH2H = true);

    final data = await _apiService.fetchH2HData(matchId: matchId);

    if (mounted) {
      setState(() {
        _h2hMatches = data;
        _isLoadingH2H = false;
        _hasFetchedH2H = true;
      });
    }
  }
}

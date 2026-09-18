import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_search_model.dart';
import '../../services/hank_search_api_service.dart';
import '../../utils/hank_network_manager.dart';
import '../match/match_detail_page.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart';

/// HankSearchTab: Searchresultscategorytypeenum
/// all: All | match: match | user: useaccount | league: League
enum HankSearchTab {
  /// All
  all,

  /// match
  match,

  /// useaccount
  user,

  /// League
  league,
}

/// HankSearchPage: Searchpage
/// withZogoLivedifferentiatedlayoutmatch：lightpurple+whitecolorhometheme
/// topSearchfield + focuswhendisplaySearchhistory/Trendingmatch + Searchafterdisplaycategorytyperesults
class HankSearchPage extends StatefulWidget {
  const HankSearchPage({Key? key}) : super(key: key);

  @override
  State<HankSearchPage> createState() => _HankSearchPageState();
}

class _HankSearchPageState extends State<HankSearchPage> {
  /// Searchinputcontroller
  final TextEditingController _searchController = TextEditingController();

  /// Searchfieldfocusnode
  final FocusNode _searchFocusNode = FocusNode();

  /// whenbeforeselectedcategorytype
  HankSearchTab _currentTab = HankSearchTab.all;

  /// whenbeforeSearchkeyword
  String _keyword = '';

  /// Searchhistorylist
  List<String> _historyList = [];

  /// whetherdisplayhistoryview（true=history+Trending，false=Searchresults）
  bool _showHistory = true;

  /// Trendingmatchlist
  List<HankSearchMatch> _hotMatches = [];

  /// TrendingmatchwhetherLoading
  bool _isHotLoading = true;

  /// Searchresults
  HankSearchResult? _searchResult;

  /// SearchresultswhetherLoading
  bool _isSearchLoading = false;

  /// SearchAPI service
  final HankSearchApiService _apiService = HankSearchApiService();

  /// SharedPreferencesstorehistorykey
  static const String _historyKey = 'hank_search_history';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChanged);
    _loadHistory();
    _fetchHotMatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// focuschangecallback
  /// getgotfocusdisplayhistoryview，lostfocusandhaskeywordwhendisplayresults
  void _onFocusChanged() {
    if (!mounted) return;
    if (_searchFocusNode.hasFocus) {
      if (!_showHistory) {
        setState(() => _showHistory = true);
      }
    } else {
      if (_showHistory && _keyword.isNotEmpty) {
        setState(() => _showHistory = false);
      }
    }
  }

  /// loadlocalSearchhistory
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    if (mounted) {
      setState(() => _historyList = list);
    }
  }

  /// addSearchhistory（max8item，Latestinmostbefore）
  Future<void> _addHistory(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList(_historyKey) ?? [];
    list.remove(keyword);
    list.insert(0, keyword);
    if (list.length > 8) {
      list = list.sublist(0, 8);
    }
    await prefs.setStringList(_historyKey, list);
    if (mounted) {
      setState(() => _historyList = list);
    }
  }

  /// DeletesingleSearchhistory
  Future<void> _removeHistoryItem(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList(_historyKey) ?? [];
    list.remove(keyword);
    await prefs.setStringList(_historyKey, list);
    if (mounted) {
      setState(() => _historyList = list);
    }
  }

  /// ClearSearchhistory
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (mounted) {
      setState(() => _historyList = []);
    }
  }

  /// runrowSearch
  void _doSearch(String keyword) {
    final trimmed = keyword.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _keyword = trimmed;
      _showHistory = false;
    });
    FocusScope.of(context).unfocus();
    _addHistory(trimmed);
    _fetchSearchResults();
  }

  /// requestSearchresults
  /// API：GET /api/livespeed/index/search
  Future<void> _fetchSearchResults() async {
    if (_keyword.isEmpty) return;

    setState(() => _isSearchLoading = true);

    final result = await _apiService.fetchSearchResults(text: _keyword);

    if (mounted) {
      setState(() {
        _searchResult = result;
        _isSearchLoading = false;
      });
    }
  }

  /// requestTrendingmatchlist
  /// API：GET /api/livespeed/index/search/match/hot
  Future<void> _fetchHotMatches() async {
    setState(() => _isHotLoading = true);

    final list = await _apiService.fetchHotMatches();

    if (mounted) {
      setState(() {
        _hotMatches = list;
        _isHotLoading = false;
      });
    }
  }

  /// CancelSearch，Clearinputbacktohistoryview
  void _cancelSearch() {
    setState(() {
      _searchController.clear();
      _keyword = '';
      _showHistory = true;
      _searchResult = null;
    });
  }

  /// togglecategorytype
  void _switchTab(HankSearchTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
  }

  /// navigate tomatchDetails
  void _pushToMatchDetail(HankSearchMatch match) {
    FocusScope.of(context).unfocus();
    // buildMatchModelusenav
    final matchModel = MatchModel(
      matchId: match.matchId?.toString() ?? '',
      leagueName: match.competitionName ?? '',
      leagueColor: 0xFF7C3AED,
      homeTeam: TeamModel(
        teamId: match.homeTeamId?.toString() ?? '',
        teamName: match.homeTeamName ?? '',
        teamShort: '',
        logoUrl: match.homeTeamLogo,
      ),
      awayTeam: TeamModel(
        teamId: match.awayTeamId?.toString() ?? '',
        teamName: match.awayTeamName ?? '',
        teamShort: '',
        logoUrl: match.awayTeamLogo,
      ),
      homeScore: match.homeTeamScore,
      awayScore: match.awayTeamScore,
      matchTime: _formatMatchTime(match.matchTime),
      status: match.homeTeamScore != null
          ? MatchStatus.finished
          : MatchStatus.upcoming,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MatchDetailPage(match: matchModel)),
    );
  }

  /// formatmatchTimeisdisplaytext
  String _formatMatchTime(int? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.violet50,
        body: Column(
          children: [
            _buildSearchHeader(),
            Expanded(
              child: _showHistory
                  ? _buildHistoryView()
                  : _buildSearchResultsView(),
            ),
          ],
        ),
      ),
    );
  }

  /// topSearchfieldarea
  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 12,
        right: 12,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Backbutton
          GestureDetector(
            onTap: () {
              if (!_showHistory) {
                _cancelSearch();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.violet100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.violet700,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Searchfield
          Expanded(
            child: Container(
              height: 38,
              padding: const EdgeInsets.only(left: 14, right: 8),
              decoration: BoxDecoration(
                color: AppColors.violet50,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: AppColors.violet200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: AppColors.violet400, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      style: const TextStyle(
                        color: AppColors.slate800,
                        fontSize: 14,
                      ),
                      textInputAction: TextInputAction.search,
                      onSubmitted: _doSearch,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        hintText: 'SearchTeam、match、useaccount',
                        hintStyle: TextStyle(
                          color: AppColors.slate400,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _cancelSearch();
                        _searchFocusNode.requestFocus();
                      },
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.violet300,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Cancelbutton
          GestureDetector(
            onTap: _cancelSearch,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.violet600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== historySearchview（defaultvisualimage） ====================

  /// historySearch + Trendingmatch
  Widget _buildHistoryView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHistorySection(),
        const SizedBox(height: 24),
        _buildHotSearchSection(),
      ],
    );
  }

  /// Searchhistoryareablock
  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.access_time, color: AppColors.violet600, size: 14),
                SizedBox(width: 6),
                Text(
                  'Searchhistory',
                  style: TextStyle(
                    color: AppColors.slate700,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (_historyList.isNotEmpty)
              GestureDetector(
                onTap: _clearHistory,
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline,
                        color: AppColors.slate500, size: 13),
                    SizedBox(width: 2),
                    Text(
                      'Clear',
                      style: TextStyle(color: AppColors.slate500, fontSize: 11),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_historyList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'NoSearchhistory',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _historyList
                .map((keyword) => _buildHistoryChip(keyword))
                .toList(),
          ),
      ],
    );
  }

  /// singleeachhistorySearchtag
  Widget _buildHistoryChip(String keyword) {
    return GestureDetector(
      onTap: () {
        _searchController.text = keyword;
        _doSearch(keyword);
      },
      child: Container(
        padding: const EdgeInsets.only(left: 12, top: 6, bottom: 6, right: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.violet200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              keyword,
              style: const TextStyle(color: AppColors.slate700, fontSize: 12),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _removeHistoryItem(keyword),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, color: AppColors.slate400, size: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trendingmatchareablock
  Widget _buildHotSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.local_fire_department,
                color: AppColors.amber500, size: 14),
            SizedBox(width: 6),
            Text(
              'Trendingmatch',
              style: TextStyle(
                color: AppColors.slate700,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isHotLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(
                color: AppColors.violet600,
                strokeWidth: 2,
              ),
            ),
          )
        else if (_hotMatches.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                'NoTrendingData',
                style: TextStyle(color: AppColors.slate400, fontSize: 12),
              ),
            ),
          )
        else
          ..._hotMatches.map((match) => _buildHotMatchCard(match)),
      ],
    );
  }

  /// singleeachTrendingmatchcard（standalonecreatecard，noneordernumber）
  Widget _buildHotMatchCard(HankSearchMatch match) {
    return GestureDetector(
      onTap: () => _pushToMatchDetail(match),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F8B5CF6),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Home（right aligned）
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      match.homeTeamName ?? '',
                      style: const TextStyle(
                        color: AppColors.slate800,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _buildTeamLogo(match.homeTeamLogo, 20),
                ],
              ),
            ),
            // scorecenterin
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child:
                  (match.homeTeamScore != null && match.awayTeamScore != null)
                      ? Text(
                          '${match.homeTeamScore} - ${match.awayTeamScore}',
                          style: const TextStyle(
                            color: AppColors.violet700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.violet100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: AppColors.violet600,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
            ),
            // Away（left aligned）
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildTeamLogo(match.awayTeamLogo, 20),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      match.awayTeamName ?? '',
                      style: const TextStyle(
                        color: AppColors.slate800,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TeamLogo
  Widget _buildTeamLogo(String? logoUrl, double size) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.violet100,
          shape: BoxShape.circle,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: size,
          height: size,
          color: AppColors.violet100,
        ),
      ),
    );
  }

  // ==================== Searchresultsview ====================

  /// Searchresultsvisualimage：categorytypeTab + result list
  Widget _buildSearchResultsView() {
    return Column(
      children: [
        _buildTabMenu(),
        Expanded(child: _buildResultBody()),
      ],
    );
  }

  /// categorytypemenu（All/match/useaccount）
  Widget _buildTabMenu() {
    final tabMap = const {
      HankSearchTab.all: 'All',
      HankSearchTab.match: 'match',
      HankSearchTab.user: 'useaccount',
      HankSearchTab.league: 'League',
    };

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200.withOpacity(0.6)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (final entry in tabMap.entries) ...[
            if (entry.key != HankSearchTab.all) const SizedBox(width: 10),
            _buildTabItem(entry.key, entry.value),
          ],
        ],
      ),
    );
  }

  /// singleeachcategorytypeTabitem
  Widget _buildTabItem(HankSearchTab tab, String label) {
    final isSelected = _currentTab == tab;
    return GestureDetector(
      onTap: () => _switchTab(tab),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
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
          style: TextStyle(
            color: isSelected ? AppColors.violet600 : AppColors.slate500,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// result listhomebody
  Widget _buildResultBody() {
    if (_isSearchLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    final matches = _searchResult?.matches ?? [];
    final users = _searchResult?.users ?? [];
    final competitions = _searchResult?.competitions ?? [];

    final showMatchSection = matches.isNotEmpty &&
        _currentTab != HankSearchTab.user &&
        _currentTab != HankSearchTab.league;
    final showUserSection = users.isNotEmpty &&
        _currentTab != HankSearchTab.match &&
        _currentTab != HankSearchTab.league;
    final showLeagueSection = competitions.isNotEmpty &&
        _currentTab != HankSearchTab.match &&
        _currentTab != HankSearchTab.user;

    if (!showMatchSection && !showUserSection && !showLeagueSection) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.violet100,
              ),
              child: const Icon(Icons.search,
                  color: AppColors.violet400, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              'notfindtophasematchresults',
              style: TextStyle(
                color: AppColors.slate500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'trySearch"Premier League"、"Real Madrid"or"NBA"',
              style: TextStyle(color: AppColors.slate400, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showMatchSection) ...[
          _buildSectionTitle('match', matches.length),
          const SizedBox(height: 10),
          ...matches.map((match) => _buildMatchCard(match)),
        ],
        if (showUserSection) ...[
          if (showMatchSection) const SizedBox(height: 20),
          _buildSectionTitle('useaccount', users.length),
          const SizedBox(height: 10),
          ...users.map((user) => _buildUserCard(user)),
        ],
        if (showLeagueSection) ...[
          if (showMatchSection || showUserSection) const SizedBox(height: 20),
          _buildSectionTitle('League', competitions.length),
          const SizedBox(height: 10),
          ...competitions.map((comp) => _buildCompetitionCard(comp)),
        ],
      ],
    );
  }

  /// paragraphtitle + countcount
  Widget _buildSectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.slate700,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: AppColors.violet100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.violet700,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// matchresultscard（differentiated：whitecolorroundedcard+lightpurpledecoration）
  Widget _buildMatchCard(HankSearchMatch match) {
    return GestureDetector(
      onTap: () => _pushToMatchDetail(match),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F8B5CF6),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Leaguename + Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.competitionName ?? '',
                    style: const TextStyle(
                      color: AppColors.slate500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (match.matchTime != null)
                  Text(
                    _formatMatchTime(match.matchTime),
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // homeAway + score
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          match.homeTeamName ?? '',
                          style: const TextStyle(
                            color: AppColors.slate800,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTeamLogo(match.homeTeamLogo, 24),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.violet50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: (match.homeTeamScore != null &&
                          match.awayTeamScore != null)
                      ? Text(
                          '${match.homeTeamScore} - ${match.awayTeamScore}',
                          style: const TextStyle(
                            color: AppColors.violet700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          'VS',
                          style: TextStyle(
                            color: AppColors.violet600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTeamLogo(match.awayTeamLogo, 24),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          match.awayTeamName ?? '',
                          style: const TextStyle(
                            color: AppColors.slate800,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// useaccountresultscard（differentiated：lightpurplecard+verified badge+Followbutton）
  Widget _buildUserCard(HankSearchUser user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5CF6),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: (user.avatar != null && user.avatar!.isNotEmpty)
                    ? Image.network(
                        user.avatar!,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          width: 44,
                          height: 44,
                          color: AppColors.violet100,
                          child: const Icon(Icons.person,
                              color: AppColors.violet400, size: 22),
                        ),
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: AppColors.violet100,
                        child: const Icon(Icons.person,
                            color: AppColors.violet400, size: 22),
                      ),
              ),
              // Liveincornermark
              if (user.isLiving == 1)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.rose500,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // nickname + verified badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    user.nickname ?? '',
                    style: const TextStyle(
                      color: AppColors.slate800,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (user.isExpert == 1) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified,
                      color: AppColors.violet600, size: 14),
                ],
              ],
            ),
          ),
          // Followbutton
          GestureDetector(
            onTap: () => _toggleFollow(user),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color:
                    user.isFollowed ? AppColors.violet100 : AppColors.violet600,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: user.isFollowed
                      ? AppColors.violet200
                      : AppColors.violet600,
                ),
              ),
              child: Text(
                user.isFollowed ? 'Followed' : '+ Follow',
                style: TextStyle(
                  color: user.isFollowed ? AppColors.violet700 : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Leagueresultscard
  /// [competition] - Leaguemodel
  Widget _buildCompetitionCard(HankSearchCompetition competition) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5CF6),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Leaguelogo
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: (competition.logo != null && competition.logo!.isNotEmpty)
                ? Image.network(
                    competition.logo!,
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) =>
                        _buildCompetitionLogoPlaceholder(),
                  )
                : _buildCompetitionLogoPlaceholder(),
          ),
          const SizedBox(width: 12),
          // Leaguename
          Expanded(
            child: Text(
              competition.name ?? '',
              style: const TextStyle(
                color: AppColors.slate800,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // matchmatchtime
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.violet100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${competition.matches ?? 0} match',
              style: const TextStyle(
                color: AppColors.violet700,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// LeagueLogoplaceholderimage
  Widget _buildCompetitionLogoPlaceholder() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.violet100,
        borderRadius: BorderRadius.circular(6),
      ),
      child:
          const Icon(Icons.sports_soccer, size: 18, color: AppColors.violet400),
    );
  }

  /// toggleuseaccountFollowstatus
  /// API：POST /api/livespeed/imchat/subscribe
  /// paramcount：target_id=useaccountID（int），type=1Follow/2CancelFollow
  /// [user] - itemmarkuseaccountmodel
  Future<void> _toggleFollow(HankSearchUser user) async {
    final int type = user.isFollowed ? 2 : 1;
    final userId = user.id ?? 0;
    if (userId == 0) return;

    try {
      final response = await HankNetworkManager().postRequest(
        '/api/livespeed/imchat/subscribe',
        data: {
          'target_id': userId,
          'type': type,
        },
      );

      if (!mounted) return;

      if (response.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(type == 1 ? 'alreadyFollow' : 'alreadyCancelFollow'),
            duration: const Duration(seconds: 1),
          ),
        );

        setState(() {
          user.followType = type == 1 ? 1 : 0;
        });
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
}

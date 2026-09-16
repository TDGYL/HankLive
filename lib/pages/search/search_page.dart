import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_search_model.dart';
import '../../services/hank_search_api_service.dart';
import '../../utils/hank_network_manager.dart';
import '../match/match_detail_page.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart';

/// HankSearchTab: 搜索结果分类枚举
/// all: 全部 | match: 比赛 | user: 用户
enum HankSearchTab {
  /// 全部
  all,
  /// 比赛
  match,
  /// 用户
  user,
}

/// HankSearchPage: 搜索页面
/// 与ZogoLive差异化布局：浅紫色+白色主题
/// 顶部搜索框 + 焦点时展示搜索历史/热门比赛 + 搜索后展示分类结果
class HankSearchPage extends StatefulWidget {
  const HankSearchPage({Key? key}) : super(key: key);

  @override
  State<HankSearchPage> createState() => _HankSearchPageState();
}

class _HankSearchPageState extends State<HankSearchPage> {
  /// 搜索输入控制器
  final TextEditingController _searchController = TextEditingController();

  /// 搜索框焦点节点
  final FocusNode _searchFocusNode = FocusNode();

  /// 当前选中的分类
  HankSearchTab _currentTab = HankSearchTab.all;

  /// 当前搜索关键词
  String _keyword = '';

  /// 搜索历史列表
  List<String> _historyList = [];

  /// 是否展示历史界面（true=历史+热门，false=搜索结果）
  bool _showHistory = true;

  /// 热门比赛列表
  List<HankSearchMatch> _hotMatches = [];

  /// 热门比赛是否加载中
  bool _isHotLoading = true;

  /// 搜索结果
  HankSearchResult? _searchResult;

  /// 搜索结果是否加载中
  bool _isSearchLoading = false;

  /// 搜索接口服务
  final HankSearchApiService _apiService = HankSearchApiService();

  /// SharedPreferences存储历史的key
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

  /// 焦点变化回调
  /// 获得焦点展示历史界面，失去焦点且有关键词时展示结果
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

  /// 加载本地搜索历史
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_historyKey) ?? [];
    if (mounted) {
      setState(() => _historyList = list);
    }
  }

  /// 添加搜索历史（最多8条，最新在最前）
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

  /// 删除单条搜索历史
  Future<void> _removeHistoryItem(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList(_historyKey) ?? [];
    list.remove(keyword);
    await prefs.setStringList(_historyKey, list);
    if (mounted) {
      setState(() => _historyList = list);
    }
  }

  /// 清空搜索历史
  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    if (mounted) {
      setState(() => _historyList = []);
    }
  }

  /// 执行搜索
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

  /// 请求搜索结果
  /// 接口：GET /api/livespeed/index/search
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

  /// 请求热门比赛列表
  /// 接口：GET /api/livespeed/index/search/match/hot
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

  /// 取消搜索，清空输入回到历史界面
  void _cancelSearch() {
    setState(() {
      _searchController.clear();
      _keyword = '';
      _showHistory = true;
      _searchResult = null;
    });
  }

  /// 切换分类
  void _switchTab(HankSearchTab tab) {
    if (_currentTab == tab) return;
    setState(() => _currentTab = tab);
  }

  /// 跳转到比赛详情
  void _pushToMatchDetail(HankSearchMatch match) {
    FocusScope.of(context).unfocus();
    // 构建MatchModel用于跳转
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
      status: match.homeTeamScore != null ? MatchStatus.finished : MatchStatus.upcoming,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MatchDetailPage(match: matchModel)),
    );
  }

  /// 格式化比赛时间为展示文案
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

  /// 顶部搜索框区域
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
          // 返回按钮
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
          // 搜索框
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
                  const Icon(Icons.search, color: AppColors.violet400, size: 16),
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
                        hintText: '搜索球队、比赛、用户',
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
          // 取消按钮
          GestureDetector(
            onTap: _cancelSearch,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Text(
                '取消',
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

  // ==================== 历史搜索界面（默认视图） ====================

  /// 历史搜索 + 热门比赛
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

  /// 搜索历史区块
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
                  '搜索历史',
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
                    Icon(Icons.delete_outline, color: AppColors.slate500, size: 13),
                    SizedBox(width: 2),
                    Text(
                      '清空',
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
              '暂无搜索历史',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _historyList.map((keyword) => _buildHistoryChip(keyword)).toList(),
          ),
      ],
    );
  }

  /// 单个历史搜索标签
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

  /// 热门比赛区块
  Widget _buildHotSearchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.local_fire_department, color: AppColors.amber500, size: 14),
            SizedBox(width: 6),
            Text(
              '热门比赛',
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
                '暂无热门数据',
                style: TextStyle(color: AppColors.slate400, fontSize: 12),
              ),
            ),
          )
        else
          ..._hotMatches.map((match) => _buildHotMatchCard(match)),
      ],
    );
  }

  /// 单个热门比赛卡片（独立卡片，无序号）
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
            // 主队（右对齐）
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
            // 比分居中
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: (match.homeTeamScore != null && match.awayTeamScore != null)
                  ? Text(
                      '${match.homeTeamScore} - ${match.awayTeamScore}',
                      style: const TextStyle(
                        color: AppColors.violet700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            // 客队（左对齐）
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

  /// 球队Logo
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

  // ==================== 搜索结果界面 ====================

  /// 搜索结果视图：分类Tab + 结果列表
  Widget _buildSearchResultsView() {
    return Column(
      children: [
        _buildTabMenu(),
        Expanded(child: _buildResultBody()),
      ],
    );
  }

  /// 分类菜单（全部/比赛/用户）
  Widget _buildTabMenu() {
    final tabMap = const {
      HankSearchTab.all: '全部',
      HankSearchTab.match: '比赛',
      HankSearchTab.user: '用户',
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

  /// 单个分类Tab项
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

  /// 结果列表主体
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

    final showMatchSection = matches.isNotEmpty && _currentTab != HankSearchTab.user;
    final showUserSection = users.isNotEmpty && _currentTab != HankSearchTab.match;

    if (!showMatchSection && !showUserSection) {
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
              child: const Icon(Icons.search, color: AppColors.violet400, size: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              '未找到相关结果',
              style: TextStyle(
                color: AppColors.slate500,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '试试搜索"英超"、"皇马"或"NBA"',
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
          _buildSectionTitle('比赛', matches.length),
          const SizedBox(height: 10),
          ...matches.map((match) => _buildMatchCard(match)),
        ],
        if (showUserSection) ...[
          if (showMatchSection) const SizedBox(height: 20),
          _buildSectionTitle('用户', users.length),
          const SizedBox(height: 10),
          ...users.map((user) => _buildUserCard(user)),
        ],
      ],
    );
  }

  /// 段落标题 + 数量
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

  /// 比赛结果卡片（差异化：白色圆角卡片+浅紫色装饰）
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
            // 联赛名 + 时间
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
            // 主客队 + 比分
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.violet50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: (match.homeTeamScore != null && match.awayTeamScore != null)
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

  /// 用户结果卡片（差异化：浅紫色卡片+认证标+关注按钮）
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
          // 头像
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
                          child: const Icon(Icons.person, color: AppColors.violet400, size: 22),
                        ),
                      )
                    : Container(
                        width: 44,
                        height: 44,
                        color: AppColors.violet100,
                        child: const Icon(Icons.person, color: AppColors.violet400, size: 22),
                      ),
              ),
              // 直播中角标
              if (user.isLiving == 1)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.rose500,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Text(
                      '直播',
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
          // 昵称 + 认证标
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
                  const Icon(Icons.verified, color: AppColors.violet600, size: 14),
                ],
              ],
            ),
          ),
          // 关注按钮
          GestureDetector(
            onTap: () => _toggleFollow(user),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: user.isFollowed
                    ? AppColors.violet100
                    : AppColors.violet600,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: user.isFollowed ? AppColors.violet200 : AppColors.violet600,
                ),
              ),
              child: Text(
                user.isFollowed ? '已关注' : '+ 关注',
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

  /// 切换用户关注状态
  /// 接口：POST /api/livespeed/imchat/subscribe
  /// 参数：target_id=用户ID（int），type=1关注/2取消关注
  /// [user] - 目标用户模型
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
            content: Text(type == 1 ? '已关注' : '已取消关注'),
            duration: const Duration(seconds: 1),
          ),
        );

        setState(() {
          user.followType = type == 1 ? 1 : 0;
        });
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
}

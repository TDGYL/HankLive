import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_network_manager.dart';
import '../../models/hank_league_info_model.dart';
import '../../models/hank_season_info_model.dart';
import '../../models/hank_team_rank_model.dart';
import '../../models/hank_player_rank_key_model.dart';
import '../../models/hank_player_rank_model.dart';
import '../match/team_detail_page.dart';
import '../match/match_detail_page.dart';
import 'hank_player_detail_page.dart';
import '../search/search_page.dart';
import '../../services/hank_match_api_service.dart';
import '../../models/hank_match_api_model.dart';

/// HankLeagueTab: 赛事页面内容Tab枚举
/// standings: 球队积分 | players: 球员排行 | fixtures: 赛程结果
enum HankLeagueTab {
  /// 球队积分
  standings,

  /// 球员排行
  players,

  /// 赛程结果
  fixtures,
}

/// HankLeagueFixtureFilter: 赛程筛选枚举
/// all: 全部 | live: 进行中 | finished: 已完赛
enum HankLeagueFixtureFilter {
  /// 全部
  all,

  /// 进行中
  live,

  /// 已完赛
  finished,
}

/// HankLeaguePage: 赛事页面
/// 严格按照 hankLeague.html 布局生成
/// 功能：联赛选择 + 赛季选择 + 三个Tab（球队积分/球员排行/赛程结果）
/// 主题：浅紫色 + 白色
class HankLeaguePage extends StatefulWidget {
  /// 构造函数
  const HankLeaguePage({Key? key}) : super(key: key);

  @override
  State<HankLeaguePage> createState() => _HankLeaguePageState();
}

class _HankLeaguePageState extends State<HankLeaguePage> {
  /// 联赛列表（来自接口）
  List<HankLeagueInfo> _leagues = [];

  /// 当前选中的联赛索引
  int _currentLeagueIndex = 0;

  /// 赛季列表（来自接口）
  List<HankSeasonInfo> _seasons = [];

  /// 当前选中的赛季索引
  int _currentSeasonIndex = 0;

  /// 积分榜数据（来自接口，按分组存储）
  List<HankTeamRankGroup> _standingGroups = [];

  /// 是否正在加载联赛列表
  bool _isLoadingLeagues = true;

  /// 是否正在加载赛季
  bool _isLoadingSeasons = false;

  /// 是否正在加载积分
  bool _isLoadingStandings = false;

  /// 赛程结果数据（来自接口，按轮次分组）
  List<List<HankMatchItem>> _fixturesData = [];

  /// 是否正在加载赛程
  bool _isLoadingFixtures = false;

  /// 当前Tab
  HankLeagueTab _currentTab = HankLeagueTab.standings;

  /// 球员排行菜单Key列表（来自接口）
  List<HankPlayerRankKey> _rankKeys = [];

  /// 当前选中的球员排行菜单Key索引
  int _currentRankKeyIndex = 0;

  /// 球员排行数据（来自接口）
  List<HankPlayerRank> _playerRanks = [];

  /// 是否正在加载球员排行菜单Key
  bool _isLoadingRankKeys = false;

  /// 是否正在加载球员排行数据
  bool _isLoadingPlayers = false;

  /// 赛程筛选
  HankLeagueFixtureFilter _fixtureFilter = HankLeagueFixtureFilter.all;

  @override
  void initState() {
    super.initState();
    _fetchLeagues();
    _fetchRankKeys();
  }

  /// 第一步：请求联赛列表
  /// 接口：GET /api/livespeed/football/competition/list
  Future<void> _fetchLeagues() async {
    final response = await HankNetworkManager()
        .getRequest('/api/livespeed/football/competition/list');

    if (response.isSuccess && response.data != null) {
      final list = response.data as List;
      setState(() {
        _leagues = list
            .map((e) => HankLeagueInfo.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingLeagues = false;
      });
      // 默认选择第一个，并触发赛季请求
      if (_leagues.isNotEmpty) {
        _fetchSeasons();
      }
    } else {
      setState(() {
        _isLoadingLeagues = false;
      });
    }
  }

  /// 第二步：请求赛季列表
  /// 接口：GET /api/livespeed/football/competition/season-list
  /// 参数：competition_id
  Future<void> _fetchSeasons() async {
    if (_leagues.isEmpty) return;
    setState(() {
      _isLoadingSeasons = true;
    });

    final competitionId = _leagues[_currentLeagueIndex].id;
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/competition/season-list',
      queryParameters: {'competition_id': competitionId},
    );

    if (response.isSuccess && response.data != null) {
      final list = response.data as List;
      final seasons = list
          .map((e) => HankSeasonInfo.fromJson(e as Map<String, dynamic>))
          .toList();

      // 选择当前赛季：is_current=1 优先，否则选第一个
      int selectedIndex = 0;
      for (int i = 0; i < seasons.length; i++) {
        if (seasons[i].isCurrent == 1) {
          selectedIndex = i;
          break;
        }
      }

      setState(() {
        _seasons = seasons;
        _currentSeasonIndex = selectedIndex;
        _isLoadingSeasons = false;
      });
      // 触发积分请求
      _fetchStandings();
      // 触发赛程请求
      _fetchFixtures();
      // 触发球员排行请求
      _fetchPlayerRanks();
    } else {
      setState(() {
        _isLoadingSeasons = false;
      });
    }
  }

  /// 第三步：请求球队积分
  /// 接口：GET /api/livespeed/football/competition/table-list
  /// 参数：competition_id, season_id
  Future<void> _fetchStandings() async {
    if (_leagues.isEmpty || _seasons.isEmpty) return;
    setState(() {
      _isLoadingStandings = true;
    });

    final competitionId = _leagues[_currentLeagueIndex].id;
    final seasonId = _seasons[_currentSeasonIndex].seasonId;
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/competition/table-list',
      queryParameters: {
        'competition_id': competitionId,
        'season_id': seasonId,
      },
    );

    if (response.isSuccess && response.data != null) {
      final dataMap = response.data as Map<String, dynamic>;
      final isGroup = dataMap['is_group'] as bool? ?? false;
      final promotionName = dataMap['promotion_name'] as String? ?? '';

      if (isGroup) {
        // is_group=true：分段显示 groups 下的数据
        final groupsArray = dataMap['groups'] as List? ?? [];
        final List<HankTeamRankGroup> groups = [];
        for (final groupItem in groupsArray) {
          if (groupItem is List) {
            groups.add(HankTeamRankGroup(
              promotionName: promotionName,
              list: groupItem
                  .map((e) => HankTeamRank.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ));
          }
        }
        setState(() {
          _standingGroups = groups;
          _isLoadingStandings = false;
        });
      } else {
        // is_group=false：取 tables.all 数组
        final tables = dataMap['tables'] as Map<String, dynamic>? ?? {};
        final allList = tables['all'] as List? ?? [];
        setState(() {
          _standingGroups = [
            HankTeamRankGroup(
              promotionName: promotionName,
              list: allList
                  .map((e) => HankTeamRank.fromJson(e as Map<String, dynamic>))
                  .toList(),
            ),
          ];
          _isLoadingStandings = false;
        });
      }
    } else {
      setState(() {
        _standingGroups = [];
        _isLoadingStandings = false;
      });
    }
  }

  /// 第四步：请求赛程结果
  /// 接口：GET /api/livespeed/football/competition/fixtures
  /// 参数：competition_id, season_id
  Future<void> _fetchFixtures() async {
    if (_leagues.isEmpty || _seasons.isEmpty) return;
    setState(() {
      _isLoadingFixtures = true;
    });

    final competitionId = _leagues[_currentLeagueIndex].id;
    final seasonId = _seasons[_currentSeasonIndex].seasonId;
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/competition/fixtures',
      queryParameters: {
        'competition_id': competitionId,
        'season_id': seasonId,
      },
    );

    if (response.isSuccess && response.data != null) {
      final outerList = response.data as List;
      setState(() {
        _fixturesData = outerList.map((inner) {
          final innerList = inner as List;
          return innerList
              .map((e) => HankMatchItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }).toList();
        _isLoadingFixtures = false;
      });
    } else {
      setState(() {
        _fixturesData = [];
        _isLoadingFixtures = false;
      });
    }
  }

  /// 切换联赛
  /// [index] - 目标联赛索引
  void _switchLeague(int index) {
    if (index == _currentLeagueIndex) return;
    setState(() {
      _currentLeagueIndex = index;
    });
    _fetchSeasons();
  }

  /// 切换赛季
  /// [index] - 目标赛季索引
  void _switchSeason(int index) {
    if (index == _currentSeasonIndex) return;
    setState(() {
      _currentSeasonIndex = index;
    });
    _fetchStandings();
    _fetchFixtures();
    _fetchPlayerRanks();
  }

  /// 请求球员排行菜单Key列表
  /// 接口：GET /api/livespeed/football/competition/player-rank-keys
  Future<void> _fetchRankKeys() async {
    setState(() {
      _isLoadingRankKeys = true;
    });

    final response = await HankNetworkManager()
        .getRequest('/api/livespeed/football/competition/player-rank-keys');

    if (response.isSuccess && response.data != null) {
      final list = response.data as List;
      setState(() {
        _rankKeys = list
            .map((e) => HankPlayerRankKey.fromJson(e as Map<String, dynamic>))
            .toList();
        _currentRankKeyIndex = 0;
        _isLoadingRankKeys = false;
      });
    } else {
      setState(() {
        _isLoadingRankKeys = false;
      });
    }
  }

  /// 请求球员排行数据
  /// 接口：GET /api/livespeed/football/competition/player-rank
  /// 参数：competition_id, season_id, key
  Future<void> _fetchPlayerRanks() async {
    if (_leagues.isEmpty || _seasons.isEmpty || _rankKeys.isEmpty) return;
    setState(() {
      _isLoadingPlayers = true;
    });

    final competitionId = _leagues[_currentLeagueIndex].id;
    final seasonId = _seasons[_currentSeasonIndex].seasonId;
    final key = _rankKeys[_currentRankKeyIndex].key;
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/competition/player-rank',
      queryParameters: {
        'competition_id': competitionId,
        'season_id': seasonId,
        'key': key,
      },
    );

    if (response.isSuccess && response.data != null) {
      final list = response.data as List;
      setState(() {
        _playerRanks = list
            .map((e) => HankPlayerRank.fromJson(e as Map<String, dynamic>))
            .toList();
        _isLoadingPlayers = false;
      });
    } else {
      setState(() {
        _playerRanks = [];
        _isLoadingPlayers = false;
      });
    }
  }

  /// 切换球员排行菜单Key
  /// [index] - 目标Key索引
  void _switchRankKey(int index) {
    if (index == _currentRankKeyIndex) return;
    setState(() {
      _currentRankKeyIndex = index;
    });
    _fetchPlayerRanks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSubHeader(),
            _buildTabBar(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  /// 构建顶部Header（品牌+搜索+通知+联赛横滑选择器）
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.violet100)),
      ),
      child: Column(
        children: [
          // 品牌行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.violet500, AppColors.indigo600],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('H',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HankLive',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.slate800)),
                      Text('体育赛事数据',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.violet600,
                              letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HankSearchPage(),
                        ),
                      );
                    },
                    child: _buildHeaderIcon(Icons.search),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 联赛横滑选择器 + 下拉箭头
          Row(
            children: [
              // 联赛横滑选择器
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _leagues.length,
                    itemBuilder: (ctx, index) {
                      final league = _leagues[index];
                      final isSelected = index == _currentLeagueIndex;
                      return GestureDetector(
                        onTap: () => _switchLeague(index),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [
                                      AppColors.violet400,
                                      AppColors.violet600
                                    ],
                                  )
                                : null,
                            color: isSelected ? null : AppColors.violet100,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color:
                                            AppColors.violet600.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2))
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              if (league.logo.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(league.logo,
                                      width: 16,
                                      height: 16,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const SizedBox()),
                                ),
                              const SizedBox(width: 4),
                              Text(league.name,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.slate600)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 下拉箭头按钮：点击弹出半屏联赛列表
              GestureDetector(
                onTap: () => _showLeaguePickerSheet(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.violet100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.violet200),
                  ),
                  child: Icon(Icons.keyboard_arrow_down,
                      size: 18, color: AppColors.slate600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建Header图标按钮
  Widget _buildHeaderIcon(IconData icon, {bool hasDot = false}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.violet100,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: 14, color: AppColors.slate600)),
          if (hasDot)
            Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.rose500, shape: BoxShape.circle),
                )),
        ],
      ),
    );
  }

  /// 弹出半屏联赛列表，方便用户查看更多联赛
  void _showLeaguePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Column(
            children: [
              // 顶部标题栏
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: AppColors.violet100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('全部联赛',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Icon(Icons.close,
                          size: 18, color: AppColors.slate400),
                    ),
                  ],
                ),
              ),
              // 联赛网格列表
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.8,
                  ),
                  itemCount: _leagues.length,
                  itemBuilder: (c, index) {
                    final league = _leagues[index];
                    final isSelected = index == _currentLeagueIndex;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        _switchLeague(index);
                      },
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    AppColors.violet400,
                                    AppColors.violet600
                                  ],
                                )
                              : null,
                          color: isSelected ? null : AppColors.violet50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.violet600
                                : AppColors.violet100,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (league.logo.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(league.logo,
                                    width: 16,
                                    height: 16,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const SizedBox()),
                              ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(league.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.slate600)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建子Header（赛季选择）
  Widget _buildSubHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.violet100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 赛季选择
          Row(
            children: [
              Text('赛季:',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.violet200),
                ),
                child: DropdownButton<int>(
                  value: _currentSeasonIndex,
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.slate800),
                  items: List.generate(_seasons.length, (i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text('${_seasons[i].year} 赛季'),
                    );
                  }),
                  onChanged: (v) {
                    if (v != null) _switchSeason(v);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建Tab导航栏
  Widget _buildTabBar() {
    final tabs = [
      HankLeagueTab.standings,
      HankLeagueTab.players,
      HankLeagueTab.fixtures,
    ];
    final labels = ['球队积分', '球员排行', '赛程结果'];
    final icons = [Icons.list_alt, Icons.person, Icons.calendar_today_outlined];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.violet100)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _currentTab == tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = tabs[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color:
                          isSelected ? AppColors.violet600 : Colors.transparent,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i],
                        size: 13,
                        color: isSelected
                            ? AppColors.violet600
                            : AppColors.slate400),
                    const SizedBox(width: 5),
                    Text(labels[i],
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.violet600
                                : AppColors.slate400)),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent() {
    switch (_currentTab) {
      case HankLeagueTab.standings:
        return _buildStandings();
      case HankLeagueTab.players:
        return _buildPlayers();
      case HankLeagueTab.fixtures:
        return _buildFixtures();
    }
  }

  // ==================== TAB 1: 球队积分榜 ====================

  /// 构建积分榜
  Widget _buildStandings() {
    if (_isLoadingStandings) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.violet600));
    }
    if (_standingGroups.isEmpty) {
      return _buildEmptyView('暂无积分数据');
    }
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 遍历分组渲染积分表
        ..._standingGroups.map((group) => _buildStandingGroup(group)),
      ],
    );
  }

  /// 构建单个分组的积分表
  /// [group] - 分组数据
  Widget _buildStandingGroup(HankTeamRankGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet100),
      ),
      child: Column(
        children: [
          _buildStandingsHeader(),
          ...group.list.map((s) => _buildStandingRow(s)),
        ],
      ),
    );
  }

  /// 构建图例圆点
  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.slate400)),
      ],
    );
  }

  /// 构建空状态视图
  /// [message] - 提示文字
  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.slate400),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
        ],
      ),
    );
  }

  /// 构建积分表头
  Widget _buildStandingsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12), topRight: Radius.circular(12)),
      ),
      child: Row(
        children: [
          SizedBox(
              width: 32,
              child: Text('排名',
                  style: TextStyle(fontSize: 10, color: AppColors.slate400),
                  textAlign: TextAlign.center)),
          const Expanded(
              child: Text('球队',
                  style: TextStyle(fontSize: 10, color: AppColors.slate400))),
          SizedBox(
              width: 24,
              child: Text('赛',
                  style: TextStyle(fontSize: 10, color: AppColors.slate400),
                  textAlign: TextAlign.center)),
          SizedBox(
              width: 48,
              child: Text('胜/平/负',
                  style: TextStyle(fontSize: 10, color: AppColors.slate400),
                  textAlign: TextAlign.center)),
          SizedBox(
              width: 28,
              child: Text('净',
                  style: TextStyle(fontSize: 10, color: AppColors.slate400),
                  textAlign: TextAlign.center)),
          SizedBox(
              width: 36,
              child: Text('积分',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800),
                  textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  /// 构建积分行
  Widget _buildStandingRow(HankTeamRank s) {
    Color? zoneColor;
    if (s.promotionId > 0) {
      // 根据 promotionId 区分颜色，简单用三种
      if (s.promotionName.toLowerCase().contains('qualif') ||
          s.promotionName.toLowerCase().contains('ucl') ||
          s.promotionName.toLowerCase().contains('champion')) {
        zoneColor = AppColors.blue500;
      } else if (s.promotionName.toLowerCase().contains('europa') ||
          s.promotionName.toLowerCase().contains('uel')) {
        zoneColor = AppColors.amber500;
      } else if (s.promotionName.toLowerCase().contains('releg') ||
          s.promotionName.toLowerCase().contains('rel')) {
        zoneColor = AppColors.rose500;
      } else {
        zoneColor = AppColors.violet400;
      }
    }

    final gdText = s.diff > 0 ? '+${s.diff}' : '${s.diff}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HankTeamDetailPage(
              teamId: s.teamId,
              teamName: s.teamName,
              teamLogo: s.teamLogo,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.violet100.withOpacity(0.5)),
            left: zoneColor != null
                ? BorderSide(color: zoneColor, width: 3)
                : BorderSide.none,
          ),
          color: zoneColor != null ? zoneColor.withOpacity(0.03) : null,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text('${s.position}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                      color: AppColors.slate600),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: Row(
                children: [
                  if (s.teamLogo.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(s.teamLogo,
                          width: 16, height: 16, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox()),
                    )
                  else
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.violet100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(s.teamName,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppColors.slate800),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 24,
              child: Text('${s.played}',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400),
                  textAlign: TextAlign.center),
            ),
            SizedBox(
              width: 48,
              child: Text('${s.won}/${s.drawn}/${s.lost}',
                  style: TextStyle(fontSize: 11, color: AppColors.slate400),
                  textAlign: TextAlign.center),
            ),
            SizedBox(
              width: 28,
              child: Text(gdText,
                  style: TextStyle(fontSize: 11,
                      color: s.diff > 0 ? AppColors.emerald500
                          : s.diff < 0 ? AppColors.rose500 : AppColors.slate400),
                  textAlign: TextAlign.center),
            ),
            SizedBox(
              width: 36,
              child: Text('${s.pts}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: AppColors.violet600),
                  textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TAB 2: 球员排行 ====================

  /// 构建球员排行
  Widget _buildPlayers() {
    if (_isLoadingPlayers) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.violet600));
    }
    if (_playerRanks.isEmpty) {
      return _buildEmptyView('暂无球员排行数据');
    }

    final players = _playerRanks;
    final currentKeyName = _rankKeys.isNotEmpty
        ? _rankKeys[_currentRankKeyIndex].name
        : '';

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 分类筛选（动态来自接口）
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _rankKeys.length,
            itemBuilder: (ctx, i) {
              final isSelected = i == _currentRankKeyIndex;
              return GestureDetector(
                onTap: () => _switchRankKey(i),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.violet400, AppColors.violet600])
                        : null,
                    color: isSelected ? null : AppColors.violet100,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(_rankKeys[i].name,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : AppColors.slate500)),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Top3 领奖台
        if (players.length >= 3) _buildTop3Podium(players.sublist(0, 3)),
        const SizedBox(height: 10),
        // 完整排行列表（第4名起）
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.violet100),
          ),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('球员 / 球队',
                        style:
                            TextStyle(fontSize: 11, color: AppColors.slate400)),
                    Text(currentKeyName,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.slate400)),
                  ],
                ),
              ),
              ...players.skip(3).map((p) => _buildPlayerListRow(p)),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建Top3领奖台
  /// [top3] - 前三名球员数据
  Widget _buildTop3Podium(List<HankPlayerRank> top3) {
    // 排列顺序：第2名、第1名、第3名
    final order = [top3[1], top3[0], top3[2]];
    return Row(
      children: order.map((p) {
        final isFirst = p.position == 1;
        return Expanded(
          child: GestureDetector(
            onTap: () => _navigateToPlayerDetail(p),
            child: Container(
          margin: EdgeInsets.fromLTRB(4, isFirst ? 0 : 8, 4, 0),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFirst ? AppColors.amber400 : AppColors.violet200,
              width: isFirst ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                  color: (isFirst ? AppColors.amber400 : AppColors.violet400)
                      .withOpacity(0.15),
                  blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Text('#${p.position}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color:
                            isFirst ? AppColors.amber500 : AppColors.slate400)),
                const SizedBox(height: 6),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.violet100,
                    border: Border.all(
                        color:
                            isFirst ? AppColors.amber400 : AppColors.violet300,
                        width: 2),
                  ),
                  child: ClipOval(
                    child: p.playerLogo.isNotEmpty
                        ? Image.network(p.playerLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarPlaceholder())
                        : _buildAvatarPlaceholder(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.playerName,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(p.teamName,
                    style: TextStyle(fontSize: 9, color: AppColors.slate400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${p.total}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.violet600)),
              ],
            ),
          ),
        ),
      );
      }).toList(),
    );
  }

  /// 构建球员列表行
  /// [p] - 球员排行数据
  Widget _buildPlayerListRow(HankPlayerRank p) {
    return GestureDetector(
      onTap: () => _navigateToPlayerDetail(p),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: AppColors.violet100.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text('${p.position}',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate400),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet100,
                ),
                child: ClipOval(
                  child: p.playerLogo.isNotEmpty
                      ? Image.network(p.playerLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarPlaceholder())
                      : _buildAvatarPlaceholder(),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.playerName,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800)),
                  Text(p.teamName,
                      style: TextStyle(fontSize: 9, color: AppColors.slate400)),
                ],
              ),
            ],
          ),
          Text('${p.total}',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violet600)),
        ],
      ),
    ),
    );
  }

  /// 跳转到球员详情页
  /// [p] - 球员排行数据
  void _navigateToPlayerDetail(HankPlayerRank p) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HankPlayerDetailPage(
          playerId: p.playerId,
          playerName: p.playerName,
          playerLogo: p.playerLogo,
        ),
      ),
    );
  }

  /// 构建头像占位图
  Widget _buildAvatarPlaceholder() {
    return Container(
      color: AppColors.violet100,
      child: Icon(Icons.person, size: 14, color: AppColors.violet400),
    );
  }

  // ==================== TAB 3: 赛程结果 ====================

  /// 构建赛程结果
  Widget _buildFixtures() {
    if (_isLoadingFixtures) {
      return const Center(child: CircularProgressIndicator(color: AppColors.violet600));
    }
    if (_fixturesData.isEmpty) {
      return _buildEmptyView('暂无赛程数据');
    }

    final filters = HankLeagueFixtureFilter.values;
    final filterLabels = ['全部比赛', '进行中', '已完赛'];

    // 展平所有轮次的比赛，并根据筛选条件过滤
    final allMatches = _fixturesData.expand((round) => round).toList();
    List<HankMatchItem> filteredMatches;
    switch (_fixtureFilter) {
      case HankLeagueFixtureFilter.all:
        filteredMatches = allMatches;
        break;
      case HankLeagueFixtureFilter.live:
        filteredMatches = allMatches.where((m) {
          final s = m.statusId ?? 0;
          return s >= 2 && s <= 7;
        }).toList();
        break;
      case HankLeagueFixtureFilter.finished:
        filteredMatches = allMatches.where((m) => m.statusId == 8).toList();
        break;
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 筛选栏
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.violet100.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.violet100),
          ),
          child: Row(
            children: List.generate(filters.length, (i) {
              final isSelected = _fixtureFilter == filters[i];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _fixtureFilter = filters[i]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : null,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: isSelected
                          ? [BoxShadow(
                              color: AppColors.violet200.withOpacity(0.5),
                              blurRadius: 2)]
                          : null,
                    ),
                    child: Text(filterLabels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.violet600 : AppColors.slate400)),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 10),
        if (filteredMatches.isEmpty)
          _buildEmptyView('该筛选条件下无赛程安排')
        else
          ...filteredMatches.map((m) => GestureDetector(
                onTap: () {
                  final matchModel =
                      HankMatchApiService.convertToMatchModel(m);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchDetailPage(match: matchModel),
                    ),
                  );
                },
                child: _buildFixtureCard(m),
              )),
      ],
    );
  }

  /// 构建赛程卡片
  /// [m] - 比赛数据项
  Widget _buildFixtureCard(HankMatchItem m) {
    final statusId = m.statusId ?? 0;
    final isLive = statusId >= 2 && statusId <= 7;
    final isFinished = statusId == 8;

    // 比分文本
    final homeScore = m.homeNormalScore ?? 0;
    final awayScore = m.awayNormalScore ?? 0;
    final scoreText = isFinished || isLive ? '$homeScore - $awayScore' : 'VS';

    // 状态文本
    String statusText;
    if (isLive) {
      statusText = m.minutes?.isNotEmpty == true ? m.minutes! : '进行中';
    } else if (isFinished) {
      statusText = '完赛';
    } else {
      // 未开赛，显示开赛时间
      if (m.matchTime != null && m.matchTime! > 0) {
        final dt = DateTime.fromMillisecondsSinceEpoch(m.matchTime! * 1000);
        statusText = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } else {
        statusText = '未开赛';
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet100),
        boxShadow: const [
          BoxShadow(color: Color(0x0F8B5CF6), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        children: [
          if (isLive)
            Positioned(
              top: -12, left: -12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: const BoxDecoration(
                  color: AppColors.emerald500,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12)),
                ),
                child: Text('LIVE 实时',
                    style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                // 主队
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(m.homeTeamName ?? '',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                color: AppColors.slate800),
                            overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 8),
                      if (m.homeTeamLogo != null && m.homeTeamLogo!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(m.homeTeamLogo!.trim(),
                              width: 20, height: 20, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox()),
                        )
                      else
                        Container(width: 20, height: 20,
                          decoration: BoxDecoration(color: AppColors.violet100,
                            borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                ),
                // 比分/时间
                Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(scoreText,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                              color: isLive ? AppColors.emerald500 : AppColors.slate800)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: isLive
                              ? AppColors.emerald500.withOpacity(0.15)
                              : AppColors.violet100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(statusText,
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                                color: isLive ? AppColors.emerald500 : AppColors.slate400)),
                      ),
                    ],
                  ),
                ),
                // 客队
                Expanded(
                  child: Row(
                    children: [
                      if (m.awayTeamLogo != null && m.awayTeamLogo!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.network(m.awayTeamLogo!.trim(),
                              width: 20, height: 20, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox()),
                        )
                      else
                        Container(width: 20, height: 20,
                          decoration: BoxDecoration(color: AppColors.violet100,
                            borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(m.awayTeamName ?? '',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                                color: AppColors.slate800),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

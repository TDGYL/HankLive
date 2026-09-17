import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_network_manager.dart';

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

/// HankLeaguePlayerCategory: 球员排行分类枚举
/// goals: 射手榜 | assists: 助攻榜 | cards: 黄红牌
enum HankLeaguePlayerCategory {
  /// 射手榜
  goals,
  /// 助攻榜
  assists,
  /// 黄红牌
  cards,
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
  /// 联赛列表
  final List<_HankLeague> _leagues = [
    _HankLeague(id: 'EPL', name: '英超', icon: '🏆'),
    _HankLeague(id: 'LALIGA', name: '西甲', icon: '🇪🇸'),
    _HankLeague(id: 'SERIEA', name: '意甲', icon: '🇮🇹'),
    _HankLeague(id: 'BUNDES', name: '德甲', icon: '🇩🇪'),
    _HankLeague(id: 'UCL', name: '欧冠', icon: '⭐'),
    _HankLeague(id: 'CSL', name: '中超', icon: '🇨🇳'),
  ];

  /// 当前选中的联赛
  String _currentLeagueId = 'EPL';

  /// 当前赛季
  String _currentSeason = '2024-2025';

  /// 赛季列表
  final List<String> _seasons = ['2025-2026', '2024-2025', '2023-2024'];

  /// 当前Tab
  HankLeagueTab _currentTab = HankLeagueTab.standings;

  /// 球员排行分类
  HankLeaguePlayerCategory _playerCategory = HankLeaguePlayerCategory.goals;

  /// 赛程筛选
  HankLeagueFixtureFilter _fixtureFilter = HankLeagueFixtureFilter.all;

  /// 当前轮次
  int _currentRound = 28;

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
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.violet500, AppColors.indigo600],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text('H',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w900,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('HankLive',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800,
                              color: AppColors.slate800)),
                      Text('体育赛事数据',
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w600,
                              color: AppColors.violet600,
                              letterSpacing: 1)),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  _buildHeaderIcon(Icons.search),
                  const SizedBox(width: 12),
                  _buildHeaderIcon(Icons.notifications_none_outlined,
                      hasDot: true),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 联赛横滑选择器
          SizedBox(
            height: 32,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _leagues.length,
              itemBuilder: (ctx, index) {
                final league = _leagues[index];
                final isSelected = league.id == _currentLeagueId;
                return GestureDetector(
                  onTap: () => setState(() => _currentLeagueId = league.id),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppColors.violet400, AppColors.violet600],
                            )
                          : null,
                      color: isSelected ? null : AppColors.violet100,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isSelected
                          ? [BoxShadow(
                              color: AppColors.violet600.withOpacity(0.3),
                              blurRadius: 8, offset: const Offset(0, 2))]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Text(league.icon, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 4),
                        Text(league.name,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  /// 构建Header图标按钮
  Widget _buildHeaderIcon(IconData icon, {bool hasDot = false}) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: AppColors.violet100,
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, size: 14, color: AppColors.slate600)),
          if (hasDot)
            Positioned(top: 6, right: 6,
              child: Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.rose500, shape: BoxShape.circle),
              )),
        ],
      ),
    );
  }

  /// 构建子Header（赛季选择 + 轮次选择）
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
              Text('赛季:', style: TextStyle(fontSize: 11, color: AppColors.slate400)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.violet200),
                ),
                child: DropdownButton<String>(
                  value: _currentSeason,
                  underline: const SizedBox(),
                  isDense: true,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500,
                      color: AppColors.slate800),
                  items: _seasons.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text('$s 赛季'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _currentSeason = v);
                  },
                ),
              ),
            ],
          ),
          // 轮次选择（仅赛程Tab显示）
          if (_currentTab == HankLeagueTab.fixtures)
            Row(
              children: [
                _buildRoundBtn(Icons.chevron_left, () {
                  setState(() => _currentRound = (_currentRound - 1).clamp(1, 38));
                }),
                const SizedBox(width: 6),
                Text('第 $_currentRound 轮',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.slate700)),
                const SizedBox(width: 6),
                _buildRoundBtn(Icons.chevron_right, () {
                  setState(() => _currentRound = (_currentRound + 1).clamp(1, 38));
                }),
              ],
            ),
        ],
      ),
    );
  }

  /// 构建轮次切换按钮
  Widget _buildRoundBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: AppColors.violet100,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 12, color: AppColors.slate600),
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
                      color: isSelected ? AppColors.violet600 : Colors.transparent,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icons[i], size: 13,
                        color: isSelected ? AppColors.violet600 : AppColors.slate400),
                    const SizedBox(width: 5),
                    Text(labels[i],
                        style: TextStyle(
                            fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.violet600 : AppColors.slate400)),
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
    final standings = _getMockStandings();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 图例
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildLegendDot(AppColors.blue500, '欧冠区'),
                  const SizedBox(width: 12),
                  _buildLegendDot(AppColors.amber500, '欧联区'),
                  const SizedBox(width: 12),
                  _buildLegendDot(AppColors.rose500, '降级区'),
                ],
              ),
              Text('胜/平/负 | 净胜 | 积分',
                  style: TextStyle(fontSize: 9, color: AppColors.slate400)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 积分表
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.violet100),
          ),
          child: Column(
            children: [
              _buildStandingsHeader(),
              ...standings.map((s) => _buildStandingRow(s)),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建图例圆点
  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 7, height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.slate400)),
      ],
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
          SizedBox(width: 32, child: Text('排名',
              style: TextStyle(fontSize: 10, color: AppColors.slate400),
              textAlign: TextAlign.center)),
          const Expanded(child: Text('球队',
              style: TextStyle(fontSize: 10, color: AppColors.slate400))),
          SizedBox(width: 24, child: Text('赛',
              style: TextStyle(fontSize: 10, color: AppColors.slate400),
              textAlign: TextAlign.center)),
          SizedBox(width: 48, child: Text('胜/平/负',
              style: TextStyle(fontSize: 10, color: AppColors.slate400),
              textAlign: TextAlign.center)),
          SizedBox(width: 28, child: Text('净',
              style: TextStyle(fontSize: 10, color: AppColors.slate400),
              textAlign: TextAlign.center)),
          SizedBox(width: 36, child: Text('积分',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: AppColors.slate800),
              textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  /// 构建积分行
  Widget _buildStandingRow(_HankStanding s) {
    Color? zoneColor;
    if (s.zone == 'ucl') zoneColor = AppColors.blue500;
    else if (s.zone == 'uel') zoneColor = AppColors.amber500;
    else if (s.zone == 'rel') zoneColor = AppColors.rose500;

    final gdText = s.gd > 0 ? '+${s.gd}' : '${s.gd}';

    return Container(
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
            child: Text('${s.rank}',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: AppColors.slate600),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Row(
              children: [
                Text(s.logo, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(s.name,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
              ],
            ),
          ),
          SizedBox(
            width: 24,
            child: Text('${s.p}',
                style: TextStyle(fontSize: 11, color: AppColors.slate400),
                textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 48,
            child: Text('${s.w}/${s.d}/${s.l}',
                style: TextStyle(fontSize: 11, color: AppColors.slate400),
                textAlign: TextAlign.center),
          ),
          SizedBox(
            width: 28,
            child: Text(gdText,
                style: TextStyle(fontSize: 11,
                    color: s.gd > 0 ? AppColors.emerald500
                        : s.gd < 0 ? AppColors.rose500 : AppColors.slate400),
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
    );
  }

  // ==================== TAB 2: 球员排行 ====================

  /// 构建球员排行
  Widget _buildPlayers() {
    final players = _getMockPlayers();
    final cats = HankLeaguePlayerCategory.values;
    final catLabels = ['⚽ 射手榜', '🅰️ 助攻榜', '🟨 黄红牌'];

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // 分类筛选
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cats.length,
            itemBuilder: (ctx, i) {
              final isSelected = _playerCategory == cats[i];
              return GestureDetector(
                onTap: () => setState(() => _playerCategory = cats[i]),
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
                    child: Text(catLabels[i],
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : AppColors.slate500)),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: const BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('球员 / 球队',
                        style: TextStyle(fontSize: 11, color: AppColors.slate400)),
                    Text(_playerCategory == HankLeaguePlayerCategory.goals
                        ? '进球数 (点球)'
                        : _playerCategory == HankLeaguePlayerCategory.assists
                            ? '助攻数' : '牌数',
                        style: TextStyle(fontSize: 11, color: AppColors.slate400)),
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
  Widget _buildTop3Podium(List<_HankPlayer> top3) {
    // 排列顺序：第2名、第1名、第3名
    final order = [top3[1], top3[0], top3[2]];
    return Row(
      children: order.map((p) {
        final isFirst = p.rank == 1;
        return Expanded(
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
                  blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              children: [
                Text('#${p.rank}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900,
                        color: isFirst ? AppColors.amber500 : AppColors.slate400)),
                const SizedBox(height: 6),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.violet100,
                    border: Border.all(
                      color: isFirst ? AppColors.amber400 : AppColors.violet300,
                      width: 2),
                  ),
                  child: ClipOval(
                    child: p.avatar.isNotEmpty
                        ? Image.network(p.avatar, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildAvatarPlaceholder())
                        : _buildAvatarPlaceholder(),
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.name,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.slate800),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(p.team,
                    style: TextStyle(fontSize: 9, color: AppColors.slate400),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${p.val}',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                        color: AppColors.violet600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 构建球员列表行
  Widget _buildPlayerListRow(_HankPlayer p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.violet100.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
                child: Text('${p.rank}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.slate400),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 10),
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violet100,
                ),
                child: ClipOval(
                  child: p.avatar.isNotEmpty
                      ? Image.network(p.avatar, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildAvatarPlaceholder())
                      : _buildAvatarPlaceholder(),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                          color: AppColors.slate800)),
                  Text(p.team,
                      style: TextStyle(fontSize: 9, color: AppColors.slate400)),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${p.val}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: AppColors.violet600)),
              Text(p.sub,
                  style: TextStyle(fontSize: 9, color: AppColors.slate400)),
            ],
          ),
        ],
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
    final fixtures = _getMockFixtures();
    final filters = HankLeagueFixtureFilter.values;
    final filterLabels = ['全部比赛', '进行中', '已完赛'];

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
                          ? [BoxShadow(color: AppColors.violet200.withOpacity(0.5),
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
        // 赛程卡片列表
        ...fixtures.map((f) => _buildFixtureCard(f)),
      ],
    );
  }

  /// 构建赛程卡片
  Widget _buildFixtureCard(_HankFixture f) {
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
          if (f.live)
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
                      Text(f.home,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: AppColors.slate800),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(width: 8),
                      Text(f.homeLogo, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                // 比分/时间
                Container(
                  width: 90,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    children: [
                      Text(f.score,
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900,
                              color: f.live ? AppColors.emerald500 : AppColors.slate800)),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: f.live
                              ? AppColors.emerald500.withOpacity(0.15)
                              : AppColors.violet100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(f.status,
                            style: TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w700,
                                color: f.live ? AppColors.emerald500 : AppColors.slate400)),
                      ),
                    ],
                  ),
                ),
                // 客队
                Expanded(
                  child: Row(
                    children: [
                      Text(f.awayLogo, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(f.away,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: AppColors.slate800),
                          overflow: TextOverflow.ellipsis),
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

  // ==================== Mock 数据 ====================

  /// 获取积分榜Mock数据
  List<_HankStanding> _getMockStandings() {
    return [
      _HankStanding(rank: 1, name: '利物浦', logo: '🔴', p: 27, w: 20, d: 6, l: 1, gd: 42, pts: 66, zone: 'ucl'),
      _HankStanding(rank: 2, name: '阿森纳', logo: '🔴', p: 27, w: 17, d: 7, l: 3, gd: 31, pts: 58, zone: 'ucl'),
      _HankStanding(rank: 3, name: '诺丁汉森林', logo: '🌳', p: 27, w: 14, d: 6, l: 7, gd: 12, pts: 48, zone: 'ucl'),
      _HankStanding(rank: 4, name: '曼城', logo: '🩵', p: 27, w: 13, d: 8, l: 6, gd: 18, pts: 47, zone: 'ucl'),
      _HankStanding(rank: 5, name: '切尔西', logo: '🔵', p: 27, w: 12, d: 8, l: 7, gd: 15, pts: 44, zone: 'uel'),
      _HankStanding(rank: 6, name: '纽卡斯尔联', logo: '⚪', p: 27, w: 12, d: 8, l: 7, gd: 10, pts: 44, zone: 'uel'),
      _HankStanding(rank: 7, name: '阿斯顿维拉', logo: '🟣', p: 27, w: 12, d: 6, l: 9, gd: 4, pts: 42, zone: ''),
      _HankStanding(rank: 8, name: '富勒姆', logo: '⚪', p: 27, w: 11, d: 9, l: 7, gd: 6, pts: 42, zone: ''),
      _HankStanding(rank: 9, name: '布莱顿', logo: '🔵', p: 27, w: 10, d: 10, l: 7, gd: 5, pts: 40, zone: ''),
      _HankStanding(rank: 10, name: '托特纳姆热刺', logo: '⚪', p: 27, w: 10, d: 4, l: 13, gd: 14, pts: 34, zone: ''),
      _HankStanding(rank: 18, name: '伊普斯维奇', logo: '🔵', p: 27, w: 3, d: 8, l: 16, gd: -26, pts: 17, zone: 'rel'),
      _HankStanding(rank: 19, name: '莱斯特城', logo: '🦊', p: 27, w: 4, d: 5, l: 18, gd: -32, pts: 17, zone: 'rel'),
      _HankStanding(rank: 20, name: '南安普顿', logo: '🔴', p: 27, w: 2, d: 3, l: 22, gd: -45, pts: 9, zone: 'rel'),
    ];
  }

  /// 获取球员排行Mock数据
  List<_HankPlayer> _getMockPlayers() {
    switch (_playerCategory) {
      case HankLeaguePlayerCategory.goals:
        return [
          _HankPlayer(rank: 1, name: '萨拉赫', team: '利物浦', avatar: '', val: '24', sub: '5点球'),
          _HankPlayer(rank: 2, name: '哈兰德', team: '曼城', avatar: '', val: '20', sub: '2点球'),
          _HankPlayer(rank: 3, name: '帕尔默', team: '切尔西', avatar: '', val: '16', sub: '4点球'),
          _HankPlayer(rank: 4, name: '伊萨克', team: '纽卡斯尔联', avatar: '', val: '15', sub: '1点球'),
          _HankPlayer(rank: 5, name: '克里斯·伍德', team: '诺丁汉森林', avatar: '', val: '14', sub: '0点球'),
        ];
      case HankLeaguePlayerCategory.assists:
        return [
          _HankPlayer(rank: 1, name: '萨拉赫', team: '利物浦', avatar: '', val: '15', sub: '助攻数'),
          _HankPlayer(rank: 2, name: '萨卡', team: '阿森纳', avatar: '', val: '12', sub: '助攻数'),
          _HankPlayer(rank: 3, name: '帕尔默', team: '切尔西', avatar: '', val: '10', sub: '助攻数'),
        ];
      case HankLeaguePlayerCategory.cards:
        return [
          _HankPlayer(rank: 1, name: '库库雷利亚', team: '切尔西', avatar: '', val: '9🟨 0🟥', sub: '犯规 38'),
          _HankPlayer(rank: 2, name: '帕利尼亚', team: '拜仁/旧将', avatar: '', val: '8🟨 1🟥', sub: '犯规 42'),
        ];
    }
  }

  /// 获取赛程Mock数据
  List<_HankFixture> _getMockFixtures() {
    final all = [
      _HankFixture(home: '阿森纳', homeLogo: '🔴', away: '切尔西', awayLogo: '🔵',
          score: '2 - 1', status: 'FT', live: false),
      _HankFixture(home: '曼城', homeLogo: '🩵', away: '利物浦', awayLogo: '🔴',
          score: '1 - 2', status: "78'", live: true),
      _HankFixture(home: '托特纳姆热刺', homeLogo: '⚪', away: '纽卡斯尔联', awayLogo: '⚪',
          score: 'VS', status: '23:30', live: false),
      _HankFixture(home: '阿斯顿维拉', homeLogo: '🟣', away: '诺丁汉森林', awayLogo: '🌳',
          score: '3 - 0', status: 'FT', live: false),
    ];
    switch (_fixtureFilter) {
      case HankLeagueFixtureFilter.all:
        return all;
      case HankLeagueFixtureFilter.live:
        return all.where((f) => f.live).toList();
      case HankLeagueFixtureFilter.finished:
        return all.where((f) => f.status == 'FT').toList();
    }
  }
}

/// _HankLeague: 联赛实体（内部使用）
class _HankLeague {
  /// 联赛ID
  final String id;
  /// 联赛名称
  final String name;
  /// 联赛图标emoji
  final String icon;

  _HankLeague({required this.id, required this.name, required this.icon});
}

/// _HankStanding: 积分榜行数据（内部使用）
class _HankStanding {
  /// 排名
  final int rank;
  /// 球队名称
  final String name;
  /// 球队logo
  final String logo;
  /// 比赛场次
  final int p;
  /// 胜场
  final int w;
  /// 平场
  final int d;
  /// 负场
  final int l;
  /// 净胜球
  final int gd;
  /// 积分
  final int pts;
  /// 区域标识：ucl=欧冠区, uel=欧联区, rel=降级区
  final String zone;

  _HankStanding({
    required this.rank, required this.name, required this.logo,
    required this.p, required this.w, required this.d, required this.l,
    required this.gd, required this.pts, required this.zone,
  });
}

/// _HankPlayer: 球员排行数据（内部使用）
class _HankPlayer {
  /// 排名
  final int rank;
  /// 球员名称
  final String name;
  /// 所属球队
  final String team;
  /// 头像URL
  final String avatar;
  /// 数据值（进球数/助攻数/牌数）
  final String val;
  /// 附加说明
  final String sub;

  _HankPlayer({
    required this.rank, required this.name, required this.team,
    required this.avatar, required this.val, required this.sub,
  });
}

/// _HankFixture: 赛程数据（内部使用）
class _HankFixture {
  /// 主队名称
  final String home;
  /// 主队logo
  final String homeLogo;
  /// 客队名称
  final String away;
  /// 客队logo
  final String awayLogo;
  /// 比分
  final String score;
  /// 状态
  final String status;
  /// 是否直播中
  final bool live;

  _HankFixture({
    required this.home, required this.homeLogo,
    required this.away, required this.awayLogo,
    required this.score, required this.status, required this.live,
  });
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_h2h_model.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart';
import '../../pages/match/match_detail_page.dart';

/// MatchDetailH2HTab: 历史交锋Tab内容组件
/// 严格参照h2h.html布局（不含导航部分）
/// 1. WDL统计条：胜平负比例条 + 进球数据
/// 2. 筛选菜单：近10场/近6场/同主客/仅联赛
/// 3. 交锋战绩列表：每场比赛为一张卡片，点击跳转到比赛详情
/// 主题：浅紫色 + 白色
class MatchDetailH2HTab extends StatefulWidget {
  /// 全部历史交锋数据列表
  final List<HankH2HMatch> matches;

  /// 当前页面主队ID
  final int homeTeamId;

  /// 当前页面主队名称
  final String homeTeamName;

  /// 当前页面主队Logo
  final String homeTeamLogo;

  /// 当前页面客队ID
  final int awayTeamId;

  /// 当前页面客队名称
  final String awayTeamName;

  /// 当前页面客队Logo
  final String awayTeamLogo;

  /// 是否正在加载
  final bool isLoading;

  /// 构造函数
  const MatchDetailH2HTab({
    required this.matches,
    required this.homeTeamId,
    required this.homeTeamName,
    required this.homeTeamLogo,
    required this.awayTeamId,
    required this.awayTeamName,
    required this.awayTeamLogo,
    required this.isLoading,
    Key? key,
  }) : super(key: key);

  @override
  State<MatchDetailH2HTab> createState() => _MatchDetailH2HTabState();
}

class _MatchDetailH2HTabState extends State<MatchDetailH2HTab> {
  /// 选中的场次数（10或6）
  int _matchCountLimit = 10;

  /// 是否仅同主客
  bool _sameHomeAway = false;

  /// 是否仅联赛
  bool _leagueOnly = false;

  /// 过滤后的比赛列表
  List<HankH2HMatch> get _filteredMatches {
    var result = widget.matches.toList();

    if (_sameHomeAway) {
      result = result.where((m) => m.homeTeamId == widget.homeTeamId).toList();
    }

    if (_leagueOnly) {
      // 排除杯赛（名称含"杯"的赛事），仅保留联赛
      result = result.where((m) => !m.competitionName.contains('杯')).toList();
    }

    return result.take(_matchCountLimit).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.violet600),
      );
    }

    final displayMatches = _filteredMatches;

    if (displayMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 40, color: AppColors.slate400),
            const SizedBox(height: 8),
            Text(
              '暂无符合条件的历史交锋记录',
              style: TextStyle(fontSize: 13, color: AppColors.slate400),
            ),
          ],
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      children: [
        _buildWDLSummary(displayMatches),
        const SizedBox(height: 12),
        _buildFilterChips(),
        const SizedBox(height: 16),
        ...displayMatches.map((m) => _buildMatchCard(m)).toList(),
      ],
    );
  }

  /// 构建WDL统计条
  /// [displayMatches] 过滤后的比赛列表
  Widget _buildWDLSummary(List<HankH2HMatch> displayMatches) {
    int homeWin = 0;
    int draw = 0;
    int awayWin = 0;
    int homeGoals = 0;
    int awayGoals = 0;

    for (final m in displayMatches) {
      if (m.homeNormalScore != null && m.awayNormalScore != null) {
        if (m.homeTeamId == widget.homeTeamId) {
          homeGoals += m.homeNormalScore!;
          awayGoals += m.awayNormalScore!;
          if (m.homeNormalScore! > m.awayNormalScore!) {
            homeWin++;
          } else if (m.homeNormalScore! < m.awayNormalScore!) {
            awayWin++;
          } else {
            draw++;
          }
        } else {
          homeGoals += m.awayNormalScore!;
          awayGoals += m.homeNormalScore!;
          if (m.awayNormalScore! > m.homeNormalScore!) {
            homeWin++;
          } else if (m.awayNormalScore! < m.homeNormalScore!) {
            awayWin++;
          } else {
            draw++;
          }
        }
      }
    }

    final total = displayMatches.length;
    final homePct = total > 0 ? homeWin / total : 0.0;
    final drawPct = total > 0 ? draw / total : 0.0;
    final awayPct = total > 0 ? awayWin / total : 0.0;
    final avgGoals = total > 0
        ? ((homeGoals + awayGoals) / total).toStringAsFixed(1)
        : '0.0';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.violet100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$homeWin 胜',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violet600,
                ),
              ),
              Text(
                '$draw 平',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate500,
                ),
              ),
              Text(
                '$awayWin 负',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.indigo600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (homePct > 0)
                    Expanded(
                      flex: (homePct * 100).round(),
                      child: Container(color: AppColors.violet500),
                    ),
                  if (drawPct > 0)
                    Expanded(
                      flex: (drawPct * 100).round(),
                      child: Container(color: AppColors.slate400),
                    ),
                  if (awayPct > 0)
                    Expanded(
                      flex: (awayPct * 100).round(),
                      child: Container(color: AppColors.indigo600),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.violet100)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '进球: $homeGoals',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                ),
                Text(
                  '场均进球: $avgGoals',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                ),
                Text(
                  '进球: $awayGoals',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建筛选芯片菜单
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('近10场', _matchCountLimit == 10, () {
            setState(() => _matchCountLimit = 10);
          }),
          _buildChip('近6场', _matchCountLimit == 6, () {
            setState(() => _matchCountLimit = 6);
          }),
          _buildChip('同主客', _sameHomeAway, () {
            setState(() => _sameHomeAway = !_sameHomeAway);
          }),
          _buildChip('仅联赛', _leagueOnly, () {
            setState(() => _leagueOnly = !_leagueOnly);
          }),
        ],
      ),
    );
  }

  /// 构建单个筛选芯片
  /// [label] 标签文本
  /// [isSelected] 是否选中
  /// [onTap] 点击回调
  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet100 : AppColors.violet50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.violet300 : AppColors.violet200,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppColors.violet700 : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建单场历史交锋卡片
  /// [m] 历史交锋数据
  Widget _buildMatchCard(HankH2HMatch m) {
    final homeIsCurrentHome = m.homeTeamId == widget.homeTeamId;
    final awayIsCurrentHome = m.awayTeamId == widget.homeTeamId;

    Color indicatorColor;
    if (m.homeNormalScore != null && m.awayNormalScore != null) {
      if (m.homeNormalScore! > m.awayNormalScore!) {
        indicatorColor = AppColors.violet500;
      } else if (m.homeNormalScore! < m.awayNormalScore!) {
        indicatorColor = AppColors.indigo600;
      } else {
        indicatorColor = AppColors.amber400;
      }
    } else {
      indicatorColor = AppColors.slate400;
    }

    return GestureDetector(
      onTap: () => _navigateToMatchDetail(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.violet100),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // 左侧颜色条
            Container(width: 4, color: indicatorColor),
            // 右侧内容
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // 第一行：联赛 + 日期 + 半场比分
                    _buildMatchTopRow(m),
                    const SizedBox(height: 10),
                    // 第二行：主队 + 比分 + 客队
                    _buildMatchScoreRow(
                        m, homeIsCurrentHome, awayIsCurrentHome),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建比赛卡片顶部行（联赛 + 日期 + 半场比分）
  /// [m] 历史交锋数据
  Widget _buildMatchTopRow(HankH2HMatch m) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (m.competitionLogo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: Image.network(m.competitionLogo,
                    width: 14,
                    height: 14,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox()),
              )
            else
              const Icon(Icons.emoji_events,
                  size: 14, color: AppColors.violet400),
            const SizedBox(width: 6),
            Text(
              m.competitionName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.slate500,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              m.formattedDate,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.slate400,
              ),
            ),
          ],
        ),
        Text(
          '半场 ${m.halfScoreText}',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }

  /// 构建比赛卡片比分行（主队 + 比分 + 客队）
  /// [m] 历史交锋数据
  /// [homeIsCurrentHome] 主队是否为当前页主队
  /// [awayIsCurrentHome] 客队是否为当前页主队
  Widget _buildMatchScoreRow(
      HankH2HMatch m, bool homeIsCurrentHome, bool awayIsCurrentHome) {
    return Row(
      children: [
        // 主队
        Expanded(
          child: Row(
            children: [
              _buildTeamLogo(m.homeTeamLogo),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  m.homeTeamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: homeIsCurrentHome
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: homeIsCurrentHome
                        ? AppColors.violet700
                        : AppColors.slate700,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 比分
        _buildScoreBadge(m),
        // 客队
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  m.awayTeamName,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: awayIsCurrentHome
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: awayIsCurrentHome
                        ? AppColors.indigo600
                        : AppColors.slate700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTeamLogo(m.awayTeamLogo),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建球队Logo（24x24，空Logo时用占位容器）
  /// [logoUrl Logo URL
  Widget _buildTeamLogo(String logoUrl) {
    if (logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(logoUrl,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildLogoPlaceholder()),
      );
    }
    return _buildLogoPlaceholder();
  }

  /// 构建Logo占位容器
  Widget _buildLogoPlaceholder() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.violet100,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// 构建比分标签
  /// [m] 历史交锋数据
  Widget _buildScoreBadge(HankH2HMatch m) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '${m.homeNormalScore ?? 0}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: m.homeNormalScore != null &&
                      m.awayNormalScore != null &&
                      m.homeNormalScore! > m.awayNormalScore!
                  ? AppColors.violet600
                  : AppColors.slate700,
            ),
          ),
          const SizedBox(width: 4),
          const Text('-',
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
          const SizedBox(width: 4),
          Text(
            '${m.awayNormalScore ?? 0}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: m.homeNormalScore != null &&
                      m.awayNormalScore != null &&
                      m.awayNormalScore! > m.homeNormalScore!
                  ? AppColors.indigo600
                  : AppColors.slate700,
            ),
          ),
        ],
      ),
    );
  }

  /// 跳转到比赛详情页
  /// [m] 历史交锋比赛数据，转换为MatchModel后push
  void _navigateToMatchDetail(HankH2HMatch m) {
    final match = MatchModel(
      matchId: '${m.matchId}',
      leagueName: m.competitionName,
      leagueColor: 0xFF8B5CF6,
      homeTeam: TeamModel(
        teamId: '${m.homeTeamId}',
        teamName: m.homeTeamName,
        teamShort: '',
        logoUrl: m.homeTeamLogo.isNotEmpty ? m.homeTeamLogo : null,
      ),
      awayTeam: TeamModel(
        teamId: '${m.awayTeamId}',
        teamName: m.awayTeamName,
        teamShort: '',
        logoUrl: m.awayTeamLogo.isNotEmpty ? m.awayTeamLogo : null,
      ),
      homeScore: m.homeNormalScore,
      awayScore: m.awayNormalScore,
      matchTime: m.formattedDate,
      status: MatchStatus.finished,
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MatchDetailPage(match: match)),
    );
  }
}
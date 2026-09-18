import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_h2h_model.dart';
import '../../models/match_model.dart';
import '../../models/team_model.dart';
import '../../pages/match/match_detail_page.dart';

/// MatchDetailH2HTab: H2HTabcontentcomponent
/// strictreferenceh2h.htmllayoutmatch（without navigation section）
/// 1. WDLstatsitem：WDLratio bar + GoalsData
/// 2. filtermenu：Last 10/Last 6/Home/Away/League Only
/// 3. H2HStatslist：eachmatchmatchisacardcard，tapnavigate tomatchDetails
/// hometheme：lightpurple + whitecolor
class MatchDetailH2HTab extends StatefulWidget {
  /// AllH2HDatalist
  final List<HankH2HMatch> matches;

  /// whenbeforepageHomeID
  final int homeTeamId;

  /// whenbeforepageHomename
  final String homeTeamName;

  /// whenbeforepageHomeLogo
  final String homeTeamLogo;

  /// whenbeforepageAwayID
  final int awayTeamId;

  /// whenbeforepageAwayname
  final String awayTeamName;

  /// whenbeforepageAwayLogo
  final String awayTeamLogo;

  /// whetherLoading
  final bool isLoading;

  /// constructorfunctioncount
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
  /// selectedmatchtimecount（10or6）
  int _matchCountLimit = 10;

  /// whetheronlyHome/Away
  bool _sameHomeAway = false;

  /// whetherLeague Only
  bool _leagueOnly = false;

  /// filteraftermatchlist
  List<HankH2HMatch> get _filteredMatches {
    var result = widget.matches.toList();

    if (_sameHomeAway) {
      result = result.where((m) => m.homeTeamId == widget.homeTeamId).toList();
    }

    if (_leagueOnly) {
      // rankremoveCup（namecontains"cup"match），onlykeepLeague
      result = result.where((m) => !m.competitionName.contains('cup')).toList();
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
              'NomatchingitemitemH2Hrecordin',
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

  /// buildWDLstatsitem
  /// [displayMatches] filteraftermatchlist
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
                '$homeWin W',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.violet600,
                ),
              ),
              Text(
                '$draw D',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate500,
                ),
              ),
              Text(
                '$awayWin L',
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
                  'Goals: $homeGoals',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                ),
                Text(
                  'avg per matchGoals: $avgGoals',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                ),
                Text(
                  'Goals: $awayGoals',
                  style: const TextStyle(fontSize: 10, color: AppColors.slate500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// buildfilterchipmenu
  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildChip('Last 10', _matchCountLimit == 10, () {
            setState(() => _matchCountLimit = 10);
          }),
          _buildChip('Last 6', _matchCountLimit == 6, () {
            setState(() => _matchCountLimit = 6);
          }),
          _buildChip('Home/Away', _sameHomeAway, () {
            setState(() => _sameHomeAway = !_sameHomeAway);
          }),
          _buildChip('League Only', _leagueOnly, () {
            setState(() => _leagueOnly = !_leagueOnly);
          }),
        ],
      ),
    );
  }

  /// buildsingleeachfilterchip
  /// [label] tagtext
  /// [isSelected] whetherselected
  /// [onTap] tapcallback
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

  /// buildsinglematchH2Hcard
  /// [m] H2HData
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
            // leftcoloritem
            Container(width: 4, color: indicatorColor),
            // right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // arow：League + Date + HTscore
                    _buildMatchTopRow(m),
                    const SizedBox(height: 10),
                    // secondrow：Home + score + Away
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

  /// buildmatchcardtoprow（League + Date + HTscore）
  /// [m] H2HData
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
          'HT ${m.halfScoreText}',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.slate400,
          ),
        ),
      ],
    );
  }

  /// buildmatchcardscorerow（Home + score + Away）
  /// [m] H2HData
  /// [homeIsCurrentHome] Homeis currentpageHome
  /// [awayIsCurrentHome] Awayis currentpageHome
  Widget _buildMatchScoreRow(
      HankH2HMatch m, bool homeIsCurrentHome, bool awayIsCurrentHome) {
    return Row(
      children: [
        // Home
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
        // score
        _buildScoreBadge(m),
        // Away
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

  /// buildTeamLogo（24x24，emptyLogowhenuseplaceholdercontainer）
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

  /// buildLogoplaceholdercontainer
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

  /// buildscoretag
  /// [m] H2HData
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

  /// navigate tomatchDetailspage
  /// [m] H2HmatchData，convert toMatchModelafterpush
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
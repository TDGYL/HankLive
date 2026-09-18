import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../pages/match/team_detail_page.dart';

/// MatchDetailScoreboard: matchDetailstopstatscategoryboardcomponent
/// displaymatchstatus、two sides、score、Goalsevent summary
/// lightpurplegradientbackgroundstyle，withindex.htmlkeepamatch
class MatchDetailScoreboard extends StatelessWidget {
  /// matchData
  final MatchModel match;

  /// matchRoundinfo（e.g.: Premier League 28round）
  final String roundInfo;

  /// matchmatchvenueinfo（e.g.: LondonSportsmatch · homeReferee: Michael·Oliver）
  final String venueInfo;

  /// HomeGoalseventlist
  final List<String> homeGoalEvents;

  /// AwayGoalseventlist
  final List<String> awayGoalEvents;

  /// HTscore（e.g.: 1-0）
  final String? halfTimeScore;

  /// matchenterrowmincount（e.g.: 67）
  final int? liveMinute;

  MatchDetailScoreboard({
    required this.match,
    required this.roundInfo,
    required this.venueInfo,
    this.homeGoalEvents = const [],
    this.awayGoalEvents = const [],
    this.halfTimeScore,
    this.liveMinute,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.profileHeaderGradient,
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.violet200, width: 0.5),
        ),
      ),
      child: Column(
        children: [
          _buildStatusRow(),
          const SizedBox(height: 12),
          _buildTeamsAndScore(context),
          const SizedBox(height: 12),
          _buildGoalEvents(),
        ],
      ),
    );
  }

  /// topstatusrow：matchstatus + animationLive/extractremind
  /// useuseFlexibleavoidrightoverflowout
  Widget _buildStatusRow() {
    final isLive = match.status == MatchStatus.live;
    return Row(
      children: [
        // matchstatustag
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isLive
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isLive
                    ? Colors.white.withOpacity(0.4)
                    : Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isLive ? Colors.white : Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isLive
                        ? "In Progress ${liveMinute ?? match.liveMinute ?? ''}'"
                        : match.status == MatchStatus.finished
                            ? 'alreadyfinishedmatch'
                            : 'not started',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Home vs Away + score
  Widget _buildTeamsAndScore(BuildContext context) {
    return Row(
      children: [
        // Home
        Expanded(
          flex: 3,
          child: _buildTeamColumn(
            context,
            match.homeTeam.teamName,
            match.homeTeam.logoUrl,
            isHome: true,
          ),
        ),
        // score
        Expanded(
          flex: 1,
          child: _buildScoreColumn(),
        ),
        // Away
        Expanded(
          flex: 3,
          child: _buildTeamColumn(
            context,
            match.awayTeam.teamName,
            match.awayTeam.logoUrl,
            isHome: false,
          ),
        ),
      ],
    );
  }

  /// Teamcolumn：Logo + name
  /// tapLogonavTeamDetailspage
  /// preferloadnetworkLogoimage，Failed to loadwhendisplayinitialplaceholder
  Widget _buildTeamColumn(BuildContext context, String name, String? logoUrl, {required bool isHome}) {
    return Column(
      children: [
        // Logo（cantapnavTeamDetails）
        GestureDetector(
          onTap: () => _navigateToTeamDetail(context, name, logoUrl),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: logoUrl != null && logoUrl.isNotEmpty
                  ? Image.network(
                      logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildLogoPlaceholder(name);
                      },
                    )
                  : _buildLogoPlaceholder(name),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// Logoplaceholder（initial）
  Widget _buildLogoPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  /// navigate toTeamDetailspage
  /// [teamName] Teamname
  /// [logoUrl] TeamLogo URL
  void _navigateToTeamDetail(BuildContext context, String teamName, String? logoUrl) {
    int teamId = 0;
    if (teamName == match.homeTeam.teamName) {
      teamId = int.tryParse(match.homeTeam.teamId) ?? 0;
    } else if (teamName == match.awayTeam.teamName) {
      teamId = int.tryParse(match.awayTeam.teamId) ?? 0;
    }
    if (teamId == 0) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HankTeamDetailPage(
          teamId: teamId,
          teamName: teamName,
          teamLogo: logoUrl,
        ),
      ),
    );
  }

  /// scorecolumn
  Widget _buildScoreColumn() {
    final homeScore = match.homeScore ?? 0;
    final awayScore = match.awayScore ?? 0;
    return Column(
      children: [
        // score（useFittedBoxpreventoverflowout）
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$homeScore',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                ':',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$awayScore',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // HTscore
        if (halfTimeScore != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              'HT: $halfTimeScore',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }

  /// Goalsevent summary
  Widget _buildGoalEvents() {
    if (homeGoalEvents.isEmpty && awayGoalEvents.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.only(top: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white24, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HomeGoals
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: homeGoalEvents.map((e) => _buildGoalChip(e, true)).toList(),
            ),
          ),
          // AwayGoals
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: awayGoalEvents.map((e) => _buildGoalChip(e, false)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Goalsevent item
  Widget _buildGoalChip(String text, bool isHome) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isHome) ...[
            Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
            const SizedBox(width: 6),
          ],
          const Icon(Icons.sports_soccer, size: 10, color: AppColors.emerald500),
          if (isHome) ...[
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../common/team_logo_widget.dart';

/// StandardMatchCard: standardpassmatchcard
/// displayLeague、two sides、score/Time、AIWrate（not started）orDatalink（alreadyfinishedmatch）
class StandardMatchCard extends StatelessWidget {
  /// matchData
  final MatchModel match;

  /// tapcardcallback
  final VoidCallback? onTap;

  /// tapDataviewcallback
  final VoidCallback? onDataTap;

  StandardMatchCard({
    Key? key,
    required this.match,
    this.onTap,
    this.onDataTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.violet100, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A7C3AED),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLeagueHeader(),
            const SizedBox(height: 8),
            _buildTeamsRow(),
            if (match.status == MatchStatus.upcoming &&
                (match.homeWinRate + match.drawRate + match.awayWinRate) > 0) ...[
              const SizedBox(height: 10),
              _buildAiWinRateBar(),
            ],
            if (match.status == MatchStatus.finished) ...[
              const SizedBox(height: 8),
              _buildFinishedFooter(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeagueHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                Icons.emoji_events,
                size: 12,
                color: Color(match.leagueColor),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  match.leagueName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.violet900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusBadge(),
            const SizedBox(width: 8),
            Text(
              match.matchTime,
              style: const TextStyle(
                fontSize: 11,
                fontFamily: 'monospace',
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    switch (match.status) {
      case MatchStatus.finished:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'alreadyfinishedmatch',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
        );
      case MatchStatus.live:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              match.liveMinute ?? 'LIVE',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: Color(0xFF10B981),
              ),
            ),
          ],
        );
      default:
        return const Text(
          'not started',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
          ),
        );
    }
  }

  Widget _buildTeamsRow() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              TeamLogoWidget(team: match.homeTeam, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  match.homeTeam.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
              ),
            ],
          ),
        ),
        _buildMiddleScoreOrVs(),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  match.awayTeam.teamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TeamLogoWidget(team: match.awayTeam, size: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiddleScoreOrVs() {
    if (match.status == MatchStatus.upcoming) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.violet50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.violet200),
        ),
        child: const Text(
          'VS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.violet600,
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          fontFamily: 'monospace',
          color: AppColors.slate900,
        ),
      ),
    );
  }

  /// AIWratepredictionitem
  Widget _buildAiWinRateBar() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xCCEDE9FE), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'AIpredictionWrate',
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Row(
                children: [
                  Expanded(
                    flex: match.homeWinRate,
                    child: Container(
                      height: 6,
                      color: AppColors.violet600,
                    ),
                  ),
                  Expanded(
                    flex: match.drawRate,
                    child: Container(
                      height: 6,
                      color: AppColors.amber400,
                    ),
                  ),
                  Expanded(
                    flex: match.awayWinRate,
                    child: Container(
                      height: 6,
                      color: AppColors.blue500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'homeW ${match.homeWinRate}%',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.violet700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishedFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          ' / tactical replayalreadyupline',
          style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
        ),
        GestureDetector(
          onTap: onDataTap,
          child: const Text(
            'viewData >',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.violet600,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../common/team_logo_widget.dart';

/// FeaturedMatchCard: 精选头部深色大卡片（Banner样式）
/// 用于首页推荐顶部的LIVE或焦点比赛
class FeaturedMatchCard extends StatelessWidget {
  /// 比赛数据
  final MatchModel match;

  /// 点击事件
  final VoidCallback? onTap;

  FeaturedMatchCard({
    Key? key,
    required this.match,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.featuredMatchGradient,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x304C1D95),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -20,
              child: Opacity(
                opacity: 0.1,
                child: Text(
                  'UCL',
                  style: TextStyle(
                    fontSize: 90,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 8),
                _buildTeamsRow(),
                if (match.goalEvents.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildGoalEvents(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 头部：联赛名 + LIVE标识
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.violet700.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFA78BFA).withOpacity(0.3),
              ),
            ),
            child: Text(
              match.leagueName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFDDD6FE),
              ),
            ),
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
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: Color(0xFFC4B5FD),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 比赛状态标识（位于时间左侧）
  Widget _buildStatusBadge() {
    if (match.status == MatchStatus.live) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF34D399),
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
              color: Color(0xFF34D399),
            ),
          ),
        ],
      );
    }
    if (match.status == MatchStatus.finished) {
      return const Text(
        'FT',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          color: Color(0xFFC4B5FD),
        ),
      );
    }
    return const Text(
      'NS',
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        fontFamily: 'monospace',
        color: Color(0xFFC4B5FD),
      ),
    );
  }

  /// 对阵双方行
  Widget _buildTeamsRow() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              TeamLogoWidget(
                team: match.homeTeam,
                size: 40,
                showRing: true,
                ringColor: const Color(0xFFA78BFA),
              ),
              const SizedBox(height: 4),
              Text(
                match.homeTeam.teamName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Text(
              '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFBBF24),
                letterSpacing: 2,
                fontFamily: 'monospace',
              ),
            ),
            if (match.halfTimeScore != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  match.halfTimeScore!,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFC4B5FD),
                  ),
                ),
              ),
          ],
        ),
        Expanded(
          child: Column(
            children: [
              TeamLogoWidget(
                team: match.awayTeam,
                size: 40,
                showRing: true,
                ringColor: const Color(0xFFA78BFA),
              ),
              const SizedBox(height: 4),
              Text(
                match.awayTeam.teamName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 进球事件行
  Widget _buildGoalEvents() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.violet700.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: match.goalEvents
            .map(
              (e) => Text(
                e,
                style: TextStyle(
                  fontSize: 10,
                  color: e.contains('(P)')
                      ? const Color(0xFFFB7185)
                      : const Color(0xFFC4B5FD),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

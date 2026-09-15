import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../common/team_logo_widget.dart';

/// EmbeddedMatchCard: 社区帖子内嵌关联赛事卡片
/// 实现讨论与实时比赛数据串联的核心机制
class EmbeddedMatchCard extends StatelessWidget {
  /// 关联赛事数据
  final MatchModel match;

  /// 点击查看直播/详情回调
  final VoidCallback? onViewLiveTap;

  EmbeddedMatchCard({
    Key? key,
    required this.match,
    this.onViewLiveTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isLive = match.status == MatchStatus.live;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isLive
              ? const [Color(0xFF4C1D95), Color(0xFF312E81)]
              : [
                  const Color(0xFF4C1D95).withOpacity(0.9),
                  const Color(0xFF312E81).withOpacity(0.9),
                ],
        ),
        border: Border.all(
          color: AppColors.violet500.withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet900.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isLive) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF34D399),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        '关联赛事: ${match.leagueName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC4B5FD),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // 主队（左对齐）
                    Expanded(
                      child: Row(
                        children: [
                          TeamLogoWidget(team: match.homeTeam, size: 20),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              match.homeTeam.teamName,
                              maxLines: 1,
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
                    // 比分居中
                    if (match.status != MatchStatus.upcoming) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: isLive
                              ? const Color(0xFF7C3AED).withOpacity(0.8)
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isLive
                              ? 'LIVE'
                              : '${match.homeScore ?? 0}-${match.awayScore ?? 0}',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                            color: isLive
                                ? const Color(0xFFFBBF24)
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: const Text(
                          'VS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                    // 客队（右对齐）
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              match.awayTeam.teamName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          TeamLogoWidget(team: match.awayTeam, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (isLive)
            GestureDetector(
              onTap: onViewLiveTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.violet600,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '看直播 >',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            Text(
              match.matchTime,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFFC4B5FD),
              ),
            ),
        ],
      ),
    );
  }
}

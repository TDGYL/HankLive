import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_process_model.dart';

/// MatchDetailStatsTab: technicalstatsTabcomponent
/// displayTeamtechnicalstatsmatchmatchitem（Possession、Shots、Cornersetc）
/// useAPI /api/livespeed/football/match/process  stats Data
/// alreadyDeletematchhomenavratebarstatusimageUI
/// lightpurple+whitecolorhomethemestyle，referenceZogoLive_buildStatsTab
class MatchDetailStatsTab extends StatelessWidget {
  /// technicalstatslist（fromAPIstats）
  final List<HankStatItem> stats;

  MatchDetailStatsTab({
    required this.stats,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            'NostatsData',
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F8B5CF6),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: stats.map((stat) => _buildStatRow(stat)).toList(),
        ),
      ),
    );
  }

  /// single rowstatsmatchmatch
  /// useusewithZogoLivesame layoutmatch：Homecountvalue | stat itemname | Awaycountvalue + d u a ldirectionprogressitem
  Widget _buildStatRow(HankStatItem stat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // countvaluerow
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                stat.homePercentText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.rose500,
                ),
              ),
              Text(
                stat.typeName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
              Text(
                stat.awayPercentText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // d u a ldirectionprogressitem
          Row(
            children: [
              // Homeprogressitem（fromrightdirectionleft）
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomLeft: Radius.circular(3),
                  ),
                  child: LinearProgressIndicator(
                    value: stat.homeProgress,
                    backgroundColor: AppColors.violet100,
                    color: AppColors.rose500,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Awayprogressitem（fromleft to right）
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(3),
                    bottomRight: Radius.circular(3),
                  ),
                  child: LinearProgressIndicator(
                    value: stat.awayProgress,
                    backgroundColor: AppColors.violet100,
                    color: AppColors.blue500,
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

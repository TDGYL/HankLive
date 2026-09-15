import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_process_model.dart';

/// MatchDetailStatsTab: 技术统计Tab组件
/// 展示球队技术统计对比条（控球率、射门、角球等）
/// 使用接口 /api/livespeed/football/match/process 的 stats 数据
/// 已删除比赛主导率柱状图UI
/// 浅紫色+白色主题风格，参考ZogoLive的_buildStatsTab
class MatchDetailStatsTab extends StatelessWidget {
  /// 技术统计列表（来自接口stats）
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
            '暂无统计数据',
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

  /// 单行统计对比
  /// 采用与ZogoLive相同的布局：主队数值 | 统计项名称 | 客队数值 + 双向进度条
  Widget _buildStatRow(HankStatItem stat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // 数值行
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
          // 双向进度条
          Row(
            children: [
              // 主队进度条（从右向左）
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
              // 客队进度条（从左向右）
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

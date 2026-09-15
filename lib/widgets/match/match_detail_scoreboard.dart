import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../pages/match/team_detail_page.dart';

/// MatchDetailScoreboard: 比赛详情顶部计分板组件
/// 展示比赛状态、对阵双方、比分、进球事件摘要
/// 浅紫色渐变背景风格，与index.html保持一致
class MatchDetailScoreboard extends StatelessWidget {
  /// 比赛数据
  final MatchModel match;

  /// 比赛轮次信息（如: 英超 第28轮）
  final String roundInfo;

  /// 比赛场地信息（如: 伦敦体育场 · 主裁判: 迈克尔·奥利弗）
  final String venueInfo;

  /// 主队进球事件列表
  final List<String> homeGoalEvents;

  /// 客队进球事件列表
  final List<String> awayGoalEvents;

  /// 半场比分（如: 1-0）
  final String? halfTimeScore;

  /// 比赛进行分钟数（如: 67）
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

  /// 顶部状态行：比赛状态 + 动画直播/提醒
  /// 使用Flexible避免右侧溢出
  Widget _buildStatusRow() {
    final isLive = match.status == MatchStatus.live;
    return Row(
      children: [
        // 比赛状态标签
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
                        ? "进行中 ${liveMinute ?? match.liveMinute ?? ''}'"
                        : match.status == MatchStatus.finished
                            ? '已完赛'
                            : '未开赛',
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

  /// 主队 vs 客队 + 比分
  Widget _buildTeamsAndScore(BuildContext context) {
    return Row(
      children: [
        // 主队
        Expanded(
          flex: 3,
          child: _buildTeamColumn(
            context,
            match.homeTeam.teamName,
            match.homeTeam.logoUrl,
            isHome: true,
          ),
        ),
        // 比分
        Expanded(
          flex: 1,
          child: _buildScoreColumn(),
        ),
        // 客队
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

  /// 球队列：Logo + 名称
  /// 点击Logo跳转球队详情页面
  /// 优先加载网络Logo图片，加载失败时显示首字母占位
  Widget _buildTeamColumn(BuildContext context, String name, String? logoUrl, {required bool isHome}) {
    return Column(
      children: [
        // Logo（可点击跳转球队详情）
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

  /// Logo占位（首字母）
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

  /// 跳转到球队详情页面
  /// [teamName] 球队名称
  /// [logoUrl] 球队Logo URL
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

  /// 比分列
  Widget _buildScoreColumn() {
    final homeScore = match.homeScore ?? 0;
    final awayScore = match.awayScore ?? 0;
    return Column(
      children: [
        // 比分
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: 4),
        // 半场比分
        if (halfTimeScore != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              '半场: $halfTimeScore',
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

  /// 进球事件摘要
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
          // 主队进球
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: homeGoalEvents.map((e) => _buildGoalChip(e, true)).toList(),
            ),
          ),
          // 客队进球
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

  /// 进球事件条目
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

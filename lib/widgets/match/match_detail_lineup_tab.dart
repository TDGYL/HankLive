import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_match_detail_model.dart';

/// MatchDetailLineupTab: 首发阵容Tab组件
/// 展示2.5D战术球场、双方首发球员、替补席
/// 浅紫色+白色主题风格
class MatchDetailLineupTab extends StatelessWidget {
  /// 主队阵型数据
  final HankMatchLineupFormation homeFormation;

  /// 客队阵型数据
  final HankMatchLineupFormation awayFormation;

  /// 替补席球员列表
  final List<HankMatchBenchPlayer> benchPlayers;

  MatchDetailLineupTab({
    required this.homeFormation,
    required this.awayFormation,
    required this.benchPlayers,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineupHeader(),
          const SizedBox(height: 16),
          _buildPitch(),
          const SizedBox(height: 16),
          _buildBenchSection(),
        ],
      ),
    );
  }

  /// 阵型信息头
  Widget _buildLineupHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.rose500, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(
              '${homeFormation.teamName} (${homeFormation.formation})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
          ],
        ),
        const Text(
          'VS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.slate500,
          ),
        ),
        Row(
          children: [
            Text(
              '${awayFormation.teamName} (${awayFormation.formation})',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(width: 8),
            Container(width: 12, height: 12, decoration: const BoxDecoration(color: AppColors.blue500, shape: BoxShape.circle)),
          ],
        ),
      ],
    );
  }

  /// 2.5D 战术球场
  Widget _buildPitch() {
    return Container(
      height: 420,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF103820), Color(0xFF0D2E1A)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4D10B981)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 球场标线
          _buildPitchMarkings(),
          // 客队（上半场）
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: _buildTeamRows(awayFormation, isHome: false),
          ),
          // 主队（下半场）
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: _buildTeamRows(homeFormation, isHome: true),
          ),
        ],
      ),
    );
  }

  /// 球场标线（中线、中圈、禁区）
  Widget _buildPitchMarkings() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _PitchLinePainter(),
      ),
    );
  }

  /// 球队阵型行
  Widget _buildTeamRows(HankMatchLineupFormation formation, {required bool isHome}) {
    return Column(
      children: formation.playerRows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((player) => _buildPlayerNode(player, formation.teamColor, isHome)).toList(),
          ),
        );
      }).toList(),
    );
  }

  /// 球员节点
  Widget _buildPlayerNode(HankMatchPlayer player, int teamColor, bool isHome) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 球衣号码圆圈
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Color(teamColor),
            shape: BoxShape.circle,
            border: Border.all(
              color: player.isStar
                  ? AppColors.violet300
                  : Colors.white,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              player.number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        // 球员姓名标签
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.85),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            _buildPlayerLabel(player),
            style: TextStyle(
              fontSize: 9,
              color: player.isStar
                  ? AppColors.violet700
                  : player.hasGoal
                      ? AppColors.emerald500
                      : AppColors.slate700,
              fontWeight: player.isStar || player.hasGoal ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  /// 球员标签文字（含标记符号）
  String _buildPlayerLabel(HankMatchPlayer player) {
    String label = player.name;
    if (player.hasGoal) label += ' ⚽';
    if (player.isStar) label = '$label ★';
    if (player.hasYellowCard) label += ' 🟨';
    return label;
  }

  /// 替补席区域
  Widget _buildBenchSection() {
    return Container(
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.chair, size: 14, color: AppColors.violet600),
              SizedBox(width: 8),
              Text(
                '替补席球员',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            children: benchPlayers.map((p) => _buildBenchItem(p)).toList(),
          ),
        ],
      ),
    );
  }

  /// 替补球员条目
  Widget _buildBenchItem(HankMatchBenchPlayer player) {
    final isHome = player.teamName == '阿森纳';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            player.isPlayed
                ? '${player.name} (已登场 ${player.playedMinute ?? ''})'
                : player.name,
            style: TextStyle(
              fontSize: 11,
              color: player.isPlayed
                  ? AppColors.emerald500
                  : AppColors.slate500,
            ),
          ),
          Text(
            player.teamName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isHome
                  ? AppColors.rose500
                  : AppColors.blue500,
            ),
          ),
        ],
      ),
    );
  }
}

/// _PitchLinePainter: 球场标线画笔
/// 绘制中线、中圈、禁区线
class _PitchLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 中线
    canvas.drawLine(
      Offset(16, size.height / 2),
      Offset(size.width - 16, size.height / 2),
      paint,
    );

    // 中圈
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      paint,
    );

    // 上方禁区
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(size.width / 2, 0),
          width: 120,
          height: 48,
        ),
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      ),
      paint,
    );

    // 下方禁区
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height),
          width: 120,
          height: 48,
        ),
        topLeft: const Radius.circular(8),
        topRight: const Radius.circular(8),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

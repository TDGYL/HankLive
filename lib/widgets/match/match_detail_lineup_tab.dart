import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_lineup_model.dart';
import '../../pages/league/hank_player_detail_page.dart';

/// MatchDetailLineupTab: 首发阵容Tab组件
/// 使用接口数据 /api/livespeed/football/match/lineup
/// 球员坐标定位规则：
///   主队: centerX = x/100 * totalWidth, centerY = y/100 * itemHeight
///   客队: centerX = (100-x)/100 * totalWidth, centerY = (100-y)/100 * itemHeight + 55 + 220
/// 浅紫色+白色主题风格
class MatchDetailLineupTab extends StatefulWidget {
  /// 阵容数据
  final HankLineupData? lineupData;

  /// 是否正在加载
  final bool isLoading;

  /// 主队名称
  final String homeTeamName;

  /// 客队名称
  final String awayTeamName;

  /// 主队Logo
  final String? homeTeamLogo;

  /// 客队Logo
  final String? awayTeamLogo;

  MatchDetailLineupTab({
    required this.lineupData,
    required this.isLoading,
    required this.homeTeamName,
    required this.awayTeamName,
    this.homeTeamLogo,
    this.awayTeamLogo,
    Key? key,
  }) : super(key: key);

  @override
  State<MatchDetailLineupTab> createState() => _MatchDetailLineupTabState();
}

class _MatchDetailLineupTabState extends State<MatchDetailLineupTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    final data = widget.lineupData;
    if (data == null ||
        (data.homeFirst.isEmpty && data.awayFirst.isEmpty)) {
      return _buildEmptyView();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLineupHeader(data),
          const SizedBox(height: 16),
          _buildPitch(data),
          const SizedBox(height: 16),
          _buildSubSection(data),
          const SizedBox(height: 16),
          _buildInjurySection(data),
        ],
      ),
    );
  }

  /// 阵型信息头（主队Logo+阵型 vs 客队Logo+阵型，不展示队名）
  Widget _buildLineupHeader(HankLineupData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 主队（Logo + 阵型）
          Row(
            children: [
              _buildTeamLogo(widget.homeTeamLogo),
              const SizedBox(width: 6),
              Text(
                data.homeFormation ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
            ],
          ),
          // VS
          const Text(
            'VS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.slate500,
            ),
          ),
          // 客队（阵型 + Logo）
          Row(
            children: [
              Text(
                data.awayFormation ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(width: 6),
              _buildTeamLogo(widget.awayTeamLogo),
            ],
          ),
        ],
      ),
    );
  }

  /// 球队小Logo
  Widget _buildTeamLogo(String? logoUrl) {
    if (logoUrl == null || logoUrl.isEmpty) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          color: AppColors.violet100,
          shape: BoxShape.circle,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        logoUrl,
        width: 18,
        height: 18,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: 18,
          height: 18,
          color: AppColors.violet100,
        ),
      ),
    );
  }

  /// 2.5D 战术球场（使用坐标定位球员）
  Widget _buildPitch(HankLineupData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 球场总宽度和总高度
        final totalWidth = constraints.maxWidth;
        final itemHeight = 420.0; // 球场高度
        // 球员节点尺寸
        const itemWidth = 36.0;

        return Container(
          height: itemHeight,
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
            clipBehavior: Clip.none,
            children: [
              // 球场标线
              Positioned.fill(
                child: CustomPaint(
                  painter: _PitchLinePainter(),
                ),
              ),
              // 客队球员（上半场，坐标翻转）
              ...data.awayFirst.map((player) {
                final centerX = (100 - player.x) / 100.0 * totalWidth;
                final centerY =
                    (100 - player.y) / 100.0 * itemHeight / 2 + itemHeight / 2;
                // 限制在球场范围内
                final clampedY = centerY.clamp(12.0, itemHeight - 50);
                return Positioned(
                  left: centerX - itemWidth / 2,
                  top: clampedY,
                  child: _buildPlayerNode(player, isHome: false),
                );
              }).toList(),
              // 主队球员（下半场）
              ...data.homeFirst.map((player) {
                final centerX = player.x / 100.0 * totalWidth;
                final centerY = player.y / 100.0 * itemHeight / 2;
                // 限制在球场范围内
                final clampedY = centerY.clamp(12.0, itemHeight - 50);
                return Positioned(
                  left: centerX - itemWidth / 2,
                  top: clampedY,
                  child: _buildPlayerNode(player, isHome: true),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  /// 球员节点（头像 + 号码 + 姓名 + 事件标记）
  /// 点击球员跳转到球员详情页
  Widget _buildPlayerNode(HankLineupPlayer player, {required bool isHome}) {
    final teamColor = isHome ? const Color(0xFFE11D48) : const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: () => _navigateToPlayerDetail(player),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 球员头像 + 号码
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: teamColor, width: 2),
                ),
                child: ClipOval(
                  child: player.playerLogo.isNotEmpty
                      ? Image.network(
                          player.playerLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: teamColor.withOpacity(0.3),
                            child: Center(
                              child: Text(
                                '${player.shirtNumber}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: teamColor.withOpacity(0.3),
                          child: Center(
                            child: Text(
                              '${player.shirtNumber}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              // 事件标记（进球/黄牌/红牌）
              if (player.incidents.isNotEmpty)
                Positioned(
                  right: -2,
                  top: -2,
                  child: _buildIncidentBadge(player.incidents),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // 球员姓名
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              player.playerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.slate700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 事件标记图标
  Widget _buildIncidentBadge(List<HankLineupIncident> incidents) {
    // 取第一个事件类型来显示
    final type = incidents.first.type;
    Color badgeColor;
    String label;

    switch (type) {
      case 1: // 进球
        badgeColor = const Color(0xFF10B981);
        label = '⚽';
        break;
      case 2: // 黄牌
        badgeColor = const Color(0xFFFBBF24);
        label = '🟨';
        break;
      case 3: // 红牌
        badgeColor = const Color(0xFFEF4444);
        label = '🟥';
        break;
      default:
        badgeColor = AppColors.violet600;
        label = '';
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontSize: 8),
        ),
      ),
    );
  }

  /// 替补席区域（主队 + 客队）
  Widget _buildSubSection(HankLineupData data) {
    if (data.homeSub.isEmpty && data.awaySub.isEmpty) {
      return const SizedBox.shrink();
    }

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
                '替补席',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 主队替补
          if (data.homeSub.isNotEmpty) ...[
            _buildSubTeamTitle(widget.homeTeamName, isHome: true),
            const SizedBox(height: 4),
            ...data.homeSub.map((p) => _buildSubPlayerChip(p)).toList(),
            const SizedBox(height: 12),
          ],
          // 客队替补
          if (data.awaySub.isNotEmpty) ...[
            _buildSubTeamTitle(widget.awayTeamName, isHome: false),
            const SizedBox(height: 4),
            ...data.awaySub.map((p) => _buildSubPlayerChip(p)).toList(),
          ],
        ],
      ),
    );
  }

  /// 替补球队标题
  Widget _buildSubTeamTitle(String name, {required bool isHome}) {
    final color = isHome ? const Color(0xFFE11D48) : const Color(0xFF3B82F6);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.slate500,
          ),
        ),
      ],
    );
  }

  /// 替补球员行（球衣号码 + Logo + 姓名，单行排列）
  /// 点击球员跳转到球员详情页
  Widget _buildSubPlayerChip(HankLineupPlayer player) {
    return GestureDetector(
      onTap: () => _navigateToPlayerDetail(player),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.violet50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.violet200.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            // 球衣号码
            Text(
              '${player.shirtNumber}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.violet600,
              ),
            ),
            const SizedBox(width: 6),
            // 球员Logo
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.violet100,
                shape: BoxShape.circle,
              ),
              child: player.playerLogo != null && player.playerLogo!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        player.playerLogo!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.person,
                          size: 12,
                          color: AppColors.violet300,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 12,
                      color: AppColors.violet300,
                    ),
            ),
            const SizedBox(width: 6),
            // 球员姓名
            Expanded(
              child: Text(
                player.playerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 跳转到球员详情页
  /// [player] 阵容球员数据
  void _navigateToPlayerDetail(HankLineupPlayer player) {
    if (player.playerId == 0) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HankPlayerDetailPage(
          playerId: player.playerId,
          playerName: player.playerName,
          playerLogo: player.playerLogo,
        ),
      ),
    );
  }

  /// 伤停区域（主队 + 客队）
  Widget _buildInjurySection(HankLineupData data) {
    if (data.homeInjury.isEmpty && data.awayInjury.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA).withOpacity(0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0FEF4444),
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
              Icon(Icons.local_hospital, size: 14, color: AppColors.rose500),
              SizedBox(width: 8),
              Text(
                '伤停名单',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 主队伤停
          if (data.homeInjury.isNotEmpty) ...[
            _buildInjuryTeamTitle(widget.homeTeamName),
            const SizedBox(height: 4),
            ...data.homeInjury.map((p) => _buildInjuryPlayerChip(p)).toList(),
            const SizedBox(height: 12),
          ],
          // 客队伤停
          if (data.awayInjury.isNotEmpty) ...[
            _buildInjuryTeamTitle(widget.awayTeamName),
            const SizedBox(height: 4),
            ...data.awayInjury.map((p) => _buildInjuryPlayerChip(p)).toList(),
          ],
        ],
      ),
    );
  }

  /// 伤停球队标题
  Widget _buildInjuryTeamTitle(String name) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
              color: AppColors.rose500, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.slate500,
          ),
        ),
      ],
    );
  }

  /// 伤停球员条目
  Widget _buildInjuryPlayerChip(HankLineupInjuryPlayer player) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (player.playerLogo.isNotEmpty)
            ClipOval(
              child: Image.network(
                player.playerLogo,
                width: 24,
                height: 24,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  width: 24,
                  height: 24,
                  color: const Color(0xFFFECDD3),
                ),
              ),
            )
            else
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFFECDD3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, size: 14, color: AppColors.rose500),
              ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800,
                  ),
                ),
                if (player.reason.isNotEmpty)
                  Text(
                    player.reason,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.rose500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 空数据视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.violet300),
          SizedBox(height: 12),
          Text(
            '暂无阵容数据',
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
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

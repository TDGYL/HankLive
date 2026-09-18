import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_lineup_model.dart';
import '../../pages/league/hank_player_detail_page.dart';

/// MatchDetailLineupTab: starterLineupTabcomponent
/// useAPIData /api/livespeed/football/match/lineup
/// Playercoordinatespositionrulethen：
///   Home: centerX = x/100 * totalWidth, centerY = y/100 * itemHeight
///   Away: centerX = (100-x)/100 * totalWidth, centerY = (100-y)/100 * itemHeight + 55 + 220
/// lightpurple+whitecolorhomethemestyle
class MatchDetailLineupTab extends StatefulWidget {
  /// LineupData
  final HankLineupData? lineupData;

  /// whetherLoading
  final bool isLoading;

  /// Homename
  final String homeTeamName;

  /// Awayname
  final String awayTeamName;

  /// HomeLogo
  final String? homeTeamLogo;

  /// AwayLogo
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

  /// formationinfoheader（HomeLogo+formation vs AwayLogo+formation，notdisplayteamname）
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
          // Home（Logo + formation）
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
          // Away（formation + Logo）
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

  /// TeamunderLogo
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

  /// 2.5D tacticalStadium（useusecoordinatespositionPlayer）
  Widget _buildPitch(HankLineupData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Stadiumtotalwidthdepthandtotalheight
        final totalWidth = constraints.maxWidth;
        final itemHeight = 420.0; // Stadiumheight
        // Playernodesize
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
              // Stadiummarkline
              Positioned.fill(
                child: CustomPaint(
                  painter: _PitchLinePainter(),
                ),
              ),
              // AwayPlayer（upHT，coordinatesflip）
              ...data.awayFirst.map((player) {
                final centerX = (100 - player.x) / 100.0 * totalWidth;
                final centerY =
                    (100 - player.y) / 100.0 * itemHeight / 2 + itemHeight / 2;
                // limitinStadiumrangeinner
                final clampedY = centerY.clamp(12.0, itemHeight - 50);
                return Positioned(
                  left: centerX - itemWidth / 2,
                  top: clampedY,
                  child: _buildPlayerNode(player, isHome: false),
                );
              }).toList(),
              // HomePlayer（downHT）
              ...data.homeFirst.map((player) {
                final centerX = player.x / 100.0 * totalWidth;
                final centerY = player.y / 100.0 * itemHeight / 2;
                // limitinStadiumrangeinner
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

  /// Playernode（avatar + Number + name + eventmarkrecord）
  /// tapPlayernavigate toPlayerDetailspage
  Widget _buildPlayerNode(HankLineupPlayer player, {required bool isHome}) {
    final teamColor = isHome ? const Color(0xFFE11D48) : const Color(0xFF3B82F6);

    return GestureDetector(
      onTap: () => _navigateToPlayerDetail(player),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Playeravatar + Number
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
              // eventmarkrecord（Goals/Yellow Cards/Red Cards）
              if (player.incidents.isNotEmpty)
                Positioned(
                  right: -2,
                  top: -2,
                  child: _buildIncidentBadge(player.incidents),
                ),
            ],
          ),
          const SizedBox(height: 2),
          // Playername
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

  /// eventmarkrecordicon
  Widget _buildIncidentBadge(List<HankLineupIncident> incidents) {
    // getaeacheventtypetodisplay
    final type = incidents.first.type;
    Color badgeColor;
    String label;

    switch (type) {
      case 1: // Goals
        badgeColor = const Color(0xFF10B981);
        label = '⚽';
        break;
      case 2: // Yellow Cards
        badgeColor = const Color(0xFFFBBF24);
        label = '🟨';
        break;
      case 3: // Red Cards
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

  /// bencharea（Home + Away）
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
                'bench',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Homesubstitute
          if (data.homeSub.isNotEmpty) ...[
            _buildSubTeamTitle(widget.homeTeamName, isHome: true),
            const SizedBox(height: 4),
            ...data.homeSub.map((p) => _buildSubPlayerChip(p)).toList(),
            const SizedBox(height: 12),
          ],
          // Awaysubstitute
          if (data.awaySub.isNotEmpty) ...[
            _buildSubTeamTitle(widget.awayTeamName, isHome: false),
            const SizedBox(height: 4),
            ...data.awaySub.map((p) => _buildSubPlayerChip(p)).toList(),
          ],
        ],
      ),
    );
  }

  /// substituteTeamtitle
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

  /// substitutePlayerrow（jerseyNumber + Logo + name，single rowarrange）
  /// tapPlayernavigate toPlayerDetailspage
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
            // jerseyNumber
            Text(
              '${player.shirtNumber}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.violet600,
              ),
            ),
            const SizedBox(width: 6),
            // PlayerLogo
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
            // Playername
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

  /// navigate toPlayerDetailspage
  /// [player] LineupPlayerData
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

  /// injuredarea（Home + Away）
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
                'injurednamesingle',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Homeinjured
          if (data.homeInjury.isNotEmpty) ...[
            _buildInjuryTeamTitle(widget.homeTeamName),
            const SizedBox(height: 4),
            ...data.homeInjury.map((p) => _buildInjuryPlayerChip(p)).toList(),
            const SizedBox(height: 12),
          ],
          // Awayinjured
          if (data.awayInjury.isNotEmpty) ...[
            _buildInjuryTeamTitle(widget.awayTeamName),
            const SizedBox(height: 4),
            ...data.awayInjury.map((p) => _buildInjuryPlayerChip(p)).toList(),
          ],
        ],
      ),
    );
  }

  /// injuredTeamtitle
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

  /// injuredPlayeritemitem
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

  /// emptyDatavisualimage
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.violet300),
          SizedBox(height: 12),
          Text(
            'NoLineupData',
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}

/// _PitchLinePainter: Stadiummarklinepaint
/// drawinline、incircle、penalty area line
class _PitchLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // inline
    canvas.drawLine(
      Offset(16, size.height / 2),
      Offset(size.width - 16, size.height / 2),
      paint,
    );

    // incircle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      paint,
    );

    // upsidebannedarea
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

    // downsidebannedarea
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

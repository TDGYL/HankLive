import 'package:flutter/material.dart';
import '../../models/team_model.dart';

/// TeamLogoWidget: TeamLogodisplaycomponent
/// preferdisplaynetworkimage，imageFailed to loadornoneURLwhendisplayinitialplaceholder
class TeamLogoWidget extends StatelessWidget {
  /// TeamData
  final TeamModel team;

  /// Logosize（size）
  final double size;

  /// whetherdisplayborderfield
  final bool showRing;

  /// borderfieldcolor
  final Color? ringColor;

  TeamLogoWidget({
    Key? key,
    required this.team,
    this.size = 32,
    this.showRing = false,
    this.ringColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(team.primaryColor),
        border: Border.all(
          color: Color(team.primaryColor).withOpacity(0.8),
          width: 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildLogoContent(),
    );

    if (showRing) {
      return Container(
        padding: EdgeInsets.all(size * 0.06),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: ringColor ?? const Color(0xFFA78BFA),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: (ringColor ?? const Color(0xFFA78BFA)).withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: content,
      );
    }
    return content;
  }

  Widget _buildLogoContent() {
    if (team.logoUrl != null && team.logoUrl!.isNotEmpty) {
      return Image.network(
        team.logoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        team.teamShort,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: Color(team.textColor),
        ),
      ),
    );
  }
}

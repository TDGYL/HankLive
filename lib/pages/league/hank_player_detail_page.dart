import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_network_manager.dart';
import '../../models/hank_player_info_model.dart';

/// HankPlayerDetailTab: PlayerDetailsTabenum
/// info: Info | transfer: Transfers | honor: Honors
enum HankPlayerDetailTab {
  /// Info
  info,

  /// Transfers
  transfer,

  /// Honors
  honor,
}

/// HankPlayerDetailPage: PlayerDetailspage
/// displayPlayerInfo、Transfers、Honorslist
/// API：GET /api/livespeed/football/info（paramcount：id）
/// hometheme：lightpurple + whitecolor
class HankPlayerDetailPage extends StatefulWidget {
  /// PlayerID
  final int playerId;

  /// Playername（usenavbartitle）
  final String playerName;

  /// PlayeravatarURL（usenavbarquickdisplay）
  final String playerLogo;

  /// constructorfunctioncount
  const HankPlayerDetailPage({
    Key? key,
    required this.playerId,
    required this.playerName,
    required this.playerLogo,
  }) : super(key: key);

  @override
  State<HankPlayerDetailPage> createState() => _HankPlayerDetailPageState();
}

class _HankPlayerDetailPageState extends State<HankPlayerDetailPage> {
  /// PlayerDetailsData（fromAPI）
  HankPlayerInfo? _playerInfo;

  /// whetherLoading
  bool _isLoading = true;

  /// whenbeforeTab
  HankPlayerDetailTab _currentTab = HankPlayerDetailTab.info;

  @override
  void initState() {
    super.initState();
    _fetchPlayerInfo();
  }

  /// requestPlayerDetails
  /// API：GET /api/livespeed/football/info
  /// paramcount：id（PlayerID）
  Future<void> _fetchPlayerInfo() async {
    final response = await HankNetworkManager().getRequest(
      '/api/livespeed/football/info',
      queryParameters: {'id': widget.playerId},
    );

    try {
      if (response.isSuccess && response.data != null) {
        setState(() {
          _playerInfo = HankPlayerInfo.fromJson(
              response.data as Map<String, dynamic>);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('PlayerDetailsparseerror: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      body: SafeArea(
        child: Column(
          children: [
            _buildNavBar(),
            if (_isLoading)
              const Expanded(
                child: Center(
                  child:
                      CircularProgressIndicator(color: AppColors.violet600),
                ),
              )
            else if (_playerInfo != null) ...[
              _buildHeader(),
              _buildTabBar(),
              Expanded(child: _buildContent()),
            ] else
              Expanded(
                child: _buildEmptyView('NoPlayerData'),
              ),
          ],
        ),
      ),
    );
  }

  /// buildnavbar
  Widget _buildNavBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.violet100)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.violet100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left,
                size: 18, color: AppColors.slate600),
          ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.playerName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.slate800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// buildPlayerinfoheader（avatar + name + basicproperty）
  Widget _buildHeader() {
    final p = _playerInfo!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet500, AppColors.indigo600],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Playeravatar
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: ClipOval(
                  child: p.logo.isNotEmpty
                      ? Image.network(p.logo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildAvatarPlaceholder(64))
                      : _buildAvatarPlaceholder(64),
                ),
              ),
              const SizedBox(width: 16),
              // name + Nationality
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nameZh,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.nameEn,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (p.countryLogo.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(p.countryLogo,
                                width: 14,
                                height: 10,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox()),
                          ),
                        const SizedBox(width: 4),
                        Text(
                          '${p.nationality} · ${p.positionText}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // basicpropertygrid
          Row(
            children: [
              _buildAttrCell('age', '${p.age}years old'),
              _buildAttrCell('Height', '${p.height}cm'),
              _buildAttrCell('Weight', '${p.weight}kg'),
              _buildAttrCell('Value', p.formattedMarketValue),
            ],
          ),
        ],
      ),
    );
  }

  /// buildheaderpropertycell
  /// [label] - propertytag
  /// [value] - propertyvalue
  Widget _buildAttrCell(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// buildTabnavbar
  Widget _buildTabBar() {
    final tabs = HankPlayerDetailTab.values;
    final labels = ['Info', 'Transfers', 'Honors'];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.violet100)),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = _currentTab == tabs[i];
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentTab = tabs[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 2,
                      color: isSelected
                          ? AppColors.violet600
                          : Colors.transparent,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.violet600
                        : AppColors.slate400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// buildcontentarea
  Widget _buildContent() {
    switch (_currentTab) {
      case HankPlayerDetailTab.info:
        return _buildInfoTab();
      case HankPlayerDetailTab.transfer:
        return _buildTransferTab();
      case HankPlayerDetailTab.honor:
        return _buildHonorTab();
    }
  }

  // ==================== Tab 1: Info ====================

  /// buildInfoTab
  Widget _buildInfoTab() {
    final p = _playerInfo!;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.violet100),
          ),
          child: Column(
            children: [
              _buildInfoRow('Chinesename', p.nameZh),
              _buildInfoRow('English name', p.nameEn),
              _buildInfoRow('Chinese short name', p.shortNameZh),
              _buildInfoRow('Englishshort name', p.shortNameEn),
              _buildInfoRow('Nationality', p.nationality),
              _buildInfoRow('birthday', p.formattedBirthday),
              _buildInfoRow('age', '${p.age}years old'),
              _buildInfoRow('Height', '${p.height}cm'),
              _buildInfoRow('Weight', '${p.weight}kg'),
              _buildInfoRow('Position', p.positionText),
              _buildInfoRow('Preferred Foot', p.preferredFootText),
              _buildInfoRow('Value', p.formattedMarketValue),
              _buildInfoRow('contracttoexpiry', p.formattedContractUntil, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  /// buildinforow
  /// [label] - tag
  /// [value] - value
  /// [isLast] - whetherlastarow（no divider）
  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom:
                    BorderSide(color: AppColors.violet100.withOpacity(0.5)),
              ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate400,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.slate800,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Tab 2: Transfers ====================

  /// buildTransfersTab
  Widget _buildTransferTab() {
    final transfers = _playerInfo!.transferList;
    if (transfers.isEmpty) {
      return _buildEmptyView('NoTransfers');
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: transfers.map((t) => _buildTransferCard(t)).toList(),
    );
  }

  /// buildTransferscard
  /// [t] - TransfersData
  Widget _buildTransferCard(HankPlayerTransfer t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet100),
      ),
      child: Column(
        children: [
          // type + Time
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  t.transferTypeText,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet600,
                  ),
                ),
              ),
              Text(
                t.formattedTime,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // transfer outTeam → transfer inTeam
          Row(
            children: [
              // transfer outTeam
              Expanded(
                child: Column(
              children: [
                if (t.fromTeamLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(t.fromTeamLogo,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox()),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.violet100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                      t.fromTeamName.isNotEmpty ? t.fromTeamName : '-',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
              ),
              // arrow
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.violet400),
              // transfer inTeam
              Expanded(
                child: Column(
              children: [
                if (t.toTeamLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(t.toTeamLogo,
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox()),
                  )
                else
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.violet100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                      t.toTeamName.isNotEmpty ? t.toTeamName : '-',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                  ),
                ),
              ],
            ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // transferfee
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.violet50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'transferfee: ${t.transferDesc}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Tab 3: Honors ====================

  /// buildHonorsTab
  Widget _buildHonorTab() {
    final honors = _playerInfo!.honorList;
    if (honors.isEmpty) {
      return _buildEmptyView('NoHonorsData');
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: honors.map((g) => _buildHonorGroup(g)).toList(),
    );
  }

  /// buildHonorsgroupingcard
  /// [group] - HonorsgroupingData
  Widget _buildHonorGroup(HankPlayerHonorGroup group) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet100),
      ),
      child: Column(
        children: [
          // groupingtitle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.violet50,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                if (group.list.isNotEmpty && group.list.first.honorLogo.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(group.list.first.honorLogo,
                        width: 16,
                        height: 16,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox()),
                  ),
                const SizedBox(width: 6),
                Text(
                  group.honorTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${group.list.length}time',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          // Seasonlist
          ...group.list.map((item) => _buildHonorItemRow(item)),
        ],
      ),
    );
  }

  /// buildHonorsitemitemrow
  /// [item] - HonorsitemitemData
  Widget _buildHonorItemRow(HankPlayerHonorItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.violet100.withOpacity(0.5)),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              item.season,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.violet600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.teamName.isNotEmpty ? item.teamName : '-',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.slate600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== publiccomponent ====================

  /// buildavatarplaceholderimage
  /// [size] - placeholderimagesize
  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.violet100,
      child: Icon(Icons.person,
          size: size * 0.4, color: AppColors.violet400),
    );
  }

  /// buildemptystatusvisualimage
  /// [message] - hinttext
  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: AppColors.slate400),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
        ],
      ),
    );
  }
}
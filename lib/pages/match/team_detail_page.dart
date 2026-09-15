import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_team_data_model.dart';
import '../../models/hank_team_lineup_model.dart';
import '../../services/hank_team_api_service.dart';

/// HankTeamDetailPage: 球队详情页面
/// 布局与ZogoLive差异化：白色卡片头部 + 阵容列表
/// 主题：浅紫色 + 白色
/// 接口：
///   1. GET /api/livespeed/football/team/data → 球队详情
///   2. GET /api/livespeed/football/team/lineup → 球队阵容
class HankTeamDetailPage extends StatefulWidget {
  /// 球队ID
  final int teamId;

  /// 球队名称（传入用于标题展示，接口返回前使用）
  final String teamName;

  /// 球队Logo URL（传入用于头像展示，接口返回前使用）
  final String? teamLogo;

  /// 联赛ID（可选，预留）
  final int? competitionId;

  HankTeamDetailPage({
    required this.teamId,
    required this.teamName,
    this.teamLogo,
    this.competitionId,
    Key? key,
  }) : super(key: key);

  @override
  State<HankTeamDetailPage> createState() => _HankTeamDetailPageState();
}

class _HankTeamDetailPageState extends State<HankTeamDetailPage> {
  /// 球队接口服务
  final HankTeamApiService _apiService = HankTeamApiService();

  /// 球队详情数据
  HankTeamData? _teamData;

  /// 是否正在加载球队详情
  bool _isLoadingTeam = true;

  /// 球队阵容数据
  List<HankTeamLineupGroup> _lineupList = [];

  /// 是否正在加载阵容
  bool _isLoadingLineup = false;

  @override
  void initState() {
    super.initState();
    _fetchTeamData();
    _fetchTeamLineup();
  }

  /// 请求球队详情数据
  /// 接口：GET /api/livespeed/football/team/data
  Future<void> _fetchTeamData() async {
    final data = await _apiService.fetchTeamData(teamId: widget.teamId);

    if (mounted) {
      setState(() {
        _teamData = data;
        _isLoadingTeam = false;
      });
    }
  }

  /// 请求球队阵容
  /// 接口：GET /api/livespeed/football/team/lineup
  Future<void> _fetchTeamLineup() async {
    setState(() => _isLoadingLineup = true);

    final list = await _apiService.fetchTeamLineup(teamId: widget.teamId);

    if (mounted) {
      setState(() {
        _lineupList = list;
        _isLoadingLineup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      body: Column(
        children: [
          _buildAppBar(),
          _buildHeaderCard(),
          Expanded(child: _buildLineupList()),
        ],
      ),
    );
  }

  /// 顶部导航栏（返回按钮 + 球队名称）
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200, width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: AppColors.violet700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _teamData?.name ?? widget.teamName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 球队信息头部卡片（差异化布局：居中Logo + 水平信息芯片）
  Widget _buildHeaderCard() {
    if (_isLoadingTeam) {
      return Container(
        height: 180,
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.violet600,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final team = _teamData;
    final logoUrl = team?.logo ?? widget.teamLogo;
    final teamName = team?.name ?? widget.teamName;

    // 身价格式化
    String marketValueStr = '-';
    if (team?.marketValue != null) {
      final mv = team!.marketValue!;
      if (mv >= 100000000) {
        marketValueStr = '€${(mv / 100000000).toStringAsFixed(1)}亿';
      } else if (mv >= 10000) {
        marketValueStr = '€${(mv / 10000).toStringAsFixed(0)}万';
      } else {
        marketValueStr = '€$mv';
      }
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        children: [
          // 球队Logo + 名称 + 联赛标签
          Row(
            children: [
              // Logo
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.violet200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: logoUrl != null && logoUrl.isNotEmpty
                      ? Image.network(
                          logoUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) =>
                              _buildLogoPlaceholder(teamName),
                        )
                      : _buildLogoPlaceholder(teamName),
                ),
              ),
              const SizedBox(width: 16),
              // 名称 + 联赛
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teamName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.slate800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (team?.competitionName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.violet100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          team!.competitionName!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.violet700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    if (team?.countryName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        team!.countryName!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 水平信息芯片行
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInfoChip(
                  Icons.calendar_today_outlined,
                  '成立',
                  team?.foundationTime?.toString() ?? '-',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.stadium_outlined,
                  '主场',
                  team?.venueName ?? '-',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.person_outline,
                  '教练',
                  team?.managerName ?? '-',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.people_outline,
                  '容量',
                  team?.venueCapacity?.toString() ?? '-',
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.monetization_on_outlined,
                  '身价',
                  marketValueStr,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 信息芯片（图标 + 标签 + 值）
  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.violet600),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 1),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 80),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Logo占位（首字母）
  Widget _buildLogoPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name.substring(0, 1) : '?',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.violet600,
        ),
      ),
    );
  }

  /// 阵容列表（直接展示，无Tab）
  Widget _buildLineupList() {
    if (_isLoadingLineup) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    final validGroups = _lineupList
        .where((g) => g.personList != null && g.personList!.isNotEmpty)
        .toList();

    if (validGroups.isEmpty) {
      return _buildEmptyView('暂无阵容数据');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: validGroups.length,
      itemBuilder: (context, index) {
        final group = validGroups[index];
        return _buildLineupGroupCard(group);
      },
    );
  }

  /// 阵容分组卡片（位置标题 + 球员逐行排列）
  Widget _buildLineupGroupCard(HankTeamLineupGroup group) {
    final players = group.personList ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F8B5CF6),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 位置标题
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.violet100,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.positionName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet700,
                  ),
                ),
                Text(
                  '进球/出场',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          // 球员列表（全宽逐行排列）
          ...players.map((player) => _buildPlayerChip(player)).toList(),
        ],
      ),
    );
  }

  /// 球员信息行（全宽，头像 + 姓名 + 号码 + 数据右对齐）
  Widget _buildPlayerChip(HankTeamPlayer player) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.violet50,
        border: Border(
          bottom: BorderSide(color: AppColors.violet100),
        ),
      ),
      child: Row(
        children: [
          // 球衣号码
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.violet600,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              player.shirtNumber != null ? '${player.shirtNumber}' : '-',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // 头像
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violet100,
            ),
            child: player.logo != null && player.logo!.isNotEmpty
                ? ClipOval(
                    child: Image.network(
                      player.logo!,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.violet300,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 16,
                    color: AppColors.violet300,
                  ),
          ),
          const SizedBox(width: 10),
          // 姓名
          Expanded(
            child: Text(
              player.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate800,
              ),
            ),
          ),
          // 进球/出场（右对齐，与标题"进球/出场"垂直对齐）
          Text(
            '${player.goals ?? 0}球 / ${player.matches ?? 0}场',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }

  /// 空数据视图
  Widget _buildEmptyView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: AppColors.violet300,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }
}

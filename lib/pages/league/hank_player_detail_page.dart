import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../utils/hank_network_manager.dart';
import '../../models/hank_player_info_model.dart';

/// HankPlayerDetailTab: 球员详情Tab枚举
/// info: 基本信息 | transfer: 转会记录 | honor: 荣誉
enum HankPlayerDetailTab {
  /// 基本信息
  info,

  /// 转会记录
  transfer,

  /// 荣誉
  honor,
}

/// HankPlayerDetailPage: 球员详情页面
/// 展示球员基本信息、转会记录、荣誉列表
/// 接口：GET /api/livespeed/football/info（参数：id）
/// 主题：浅紫色 + 白色
class HankPlayerDetailPage extends StatefulWidget {
  /// 球员ID
  final int playerId;

  /// 球员名称（用于导航栏标题）
  final String playerName;

  /// 球员头像URL（用于导航栏快速展示）
  final String playerLogo;

  /// 构造函数
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
  /// 球员详情数据（来自接口）
  HankPlayerInfo? _playerInfo;

  /// 是否正在加载
  bool _isLoading = true;

  /// 当前Tab
  HankPlayerDetailTab _currentTab = HankPlayerDetailTab.info;

  @override
  void initState() {
    super.initState();
    _fetchPlayerInfo();
  }

  /// 请求球员详情
  /// 接口：GET /api/livespeed/football/info
  /// 参数：id（球员ID）
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
      debugPrint('球员详情解析异常: $e');
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
                child: _buildEmptyView('暂无球员数据'),
              ),
          ],
        ),
      ),
    );
  }

  /// 构建导航栏
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

  /// 构建球员信息头部（头像 + 名称 + 基本属性）
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
              // 球员头像
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
              // 名称 + 国籍
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
          // 基本属性网格
          Row(
            children: [
              _buildAttrCell('年龄', '${p.age}岁'),
              _buildAttrCell('身高', '${p.height}cm'),
              _buildAttrCell('体重', '${p.weight}kg'),
              _buildAttrCell('身价', p.formattedMarketValue),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建头部属性单元格
  /// [label] - 属性标签
  /// [value] - 属性值
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

  /// 构建Tab导航栏
  Widget _buildTabBar() {
    final tabs = HankPlayerDetailTab.values;
    final labels = ['基本信息', '转会记录', '荣誉'];

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

  /// 构建内容区域
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

  // ==================== Tab 1: 基本信息 ====================

  /// 构建基本信息Tab
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
              _buildInfoRow('中文名', p.nameZh),
              _buildInfoRow('英文名', p.nameEn),
              _buildInfoRow('中文简称', p.shortNameZh),
              _buildInfoRow('英文简称', p.shortNameEn),
              _buildInfoRow('国籍', p.nationality),
              _buildInfoRow('生日', p.formattedBirthday),
              _buildInfoRow('年龄', '${p.age}岁'),
              _buildInfoRow('身高', '${p.height}cm'),
              _buildInfoRow('体重', '${p.weight}kg'),
              _buildInfoRow('位置', p.positionText),
              _buildInfoRow('惯用脚', p.preferredFootText),
              _buildInfoRow('身价', p.formattedMarketValue),
              _buildInfoRow('合同到期', p.formattedContractUntil, isLast: true),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建信息行
  /// [label] - 标签
  /// [value] - 值
  /// [isLast] - 是否最后一行（不显示分割线）
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

  // ==================== Tab 2: 转会记录 ====================

  /// 构建转会记录Tab
  Widget _buildTransferTab() {
    final transfers = _playerInfo!.transferList;
    if (transfers.isEmpty) {
      return _buildEmptyView('暂无转会记录');
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: transfers.map((t) => _buildTransferCard(t)).toList(),
    );
  }

  /// 构建转会记录卡片
  /// [t] - 转会记录数据
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
          // 类型 + 时间
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
          // 转出球队 → 转入球队
          Row(
            children: [
              // 转出球队
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
              // 箭头
              const Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.violet400),
              // 转入球队
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
          // 转会费
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.violet50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '转会费: ${t.transferDesc}',
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

  // ==================== Tab 3: 荣誉 ====================

  /// 构建荣誉Tab
  Widget _buildHonorTab() {
    final honors = _playerInfo!.honorList;
    if (honors.isEmpty) {
      return _buildEmptyView('暂无荣誉数据');
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: honors.map((g) => _buildHonorGroup(g)).toList(),
    );
  }

  /// 构建荣誉分组卡片
  /// [group] - 荣誉分组数据
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
          // 分组标题
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
                  '${group.list.length}次',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate400,
                  ),
                ),
              ],
            ),
          ),
          // 赛季列表
          ...group.list.map((item) => _buildHonorItemRow(item)),
        ],
      ),
    );
  }

  /// 构建荣誉条目行
  /// [item] - 荣誉条目数据
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

  // ==================== 公共组件 ====================

  /// 构建头像占位图
  /// [size] - 占位图尺寸
  Widget _buildAvatarPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      color: AppColors.violet100,
      child: Icon(Icons.person,
          size: size * 0.4, color: AppColors.violet400),
    );
  }

  /// 构建空状态视图
  /// [message] - 提示文字
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
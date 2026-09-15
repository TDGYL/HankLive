import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_process_model.dart';

/// MatchDetailLiveTab: 图文赛况Tab组件
/// 展示比赛事件时间线，使用接口 /api/livespeed/football/match/process 的 incidents 数据
/// UI还原 football_match_details.html 的图文赛况布局：
///   左侧事件图标圆点 + 右侧白色卡片容器（标题行 + 描述文本 + 附加信息）
///   每个事件用白色背景圆角卡片圈起来
/// 筛选标签根据事件类型动态生成，选中时过滤展示对应事件
class MatchDetailLiveTab extends StatefulWidget {
  /// 赛况事件列表（来自接口incidents）
  final List<HankIncidentItem> incidents;

  MatchDetailLiveTab({
    required this.incidents,
    Key? key,
  }) : super(key: key);

  @override
  State<MatchDetailLiveTab> createState() => _MatchDetailLiveTabState();
}

class _MatchDetailLiveTabState extends State<MatchDetailLiveTab> {
  /// 随机生成的温度（10-30度）
  late final int _temperature;

  /// 当前选中的筛选类型（null = 全部）
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // 随机生成10-30度的温度
    _temperature = 10 + Random().nextInt(21);
  }

  /// 获取筛选标签列表（根据incidents中实际存在的事件类型动态生成）
  /// 返回顺序：全部、进球、红黄牌、换人（仅包含有数据的类型）
  List<String> _buildFilterLabels() {
    final labels = <String>['全部'];

    // 统计事件类型
    bool hasGoal = false;
    bool hasCard = false;
    bool hasSub = false;

    for (final incident in widget.incidents) {
      final type = incident.type ?? 0;
      // 进球类：1=进球, 8=点球进球, 17=乌龙球, 29=点球进球
      if (type == 1 || type == 8 || type == 17 || type == 29) {
        hasGoal = true;
      }
      // 红黄牌类：3=黄牌, 4=红牌, 15=两黄变红
      if (type == 3 || type == 4 || type == 15) {
        hasCard = true;
      }
      // 换人类：9=换人
      if (type == 9) {
        hasSub = true;
      }
    }

    if (hasGoal) labels.add('进球');
    if (hasCard) labels.add('红黄牌');
    if (hasSub) labels.add('换人');

    return labels;
  }

  /// 根据当前筛选条件过滤事件列表
  List<HankIncidentItem> _getFilteredIncidents() {
    if (_selectedFilter == null || _selectedFilter == '全部') {
      return widget.incidents;
    }

    return widget.incidents.where((incident) {
      final type = incident.type ?? 0;
      switch (_selectedFilter) {
        case '进球':
          return type == 1 || type == 8 || type == 17 || type == 29;
        case '红黄牌':
          return type == 3 || type == 4 || type == 15;
        case '换人':
          return type == 9;
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.incidents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            '暂无赛况数据',
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ),
      );
    }

    final filterLabels = _buildFilterLabels();
    final filteredIncidents = _getFilteredIncidents();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterPills(filterLabels),
          const SizedBox(height: 16),
          _buildTimeline(filteredIncidents),
        ],
      ),
    );
  }

  /// 比赛状态横幅（天气 + 动画直播）
  /// 温度随机生成（10-30度）
  Widget _buildStatusBanner() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.thermostat, size: 14, color: AppColors.amber500),
              const SizedBox(width: 8),
              Text(
                '天气: $_temperature°C 晴朗 · 场地优秀',
                style: const TextStyle(fontSize: 12, color: AppColors.slate700),
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  /// 事件筛选标签（动态生成，根据事件统计）
  Widget _buildFilterPills(List<String> labels) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text('筛选:', style: TextStyle(fontSize: 11, color: AppColors.slate500)),
        ...labels.map((label) {
          final isActive = (_selectedFilter ?? '全部') == label;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = label == '全部' ? null : label;
              });
            },
            child: _buildPill(label, isActive),
          );
        }),
      ],
    );
  }

  /// 筛选标签
  Widget _buildPill(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.violet100
            : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? AppColors.violet300
              : AppColors.violet200.withOpacity(0.5),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: isActive ? AppColors.violet700 : AppColors.slate500,
        ),
      ),
    );
  }

  /// 时间线事件流
  /// 左侧竖线 + 每个事件：左侧圆点图标 + 右侧白色卡片
  Widget _buildTimeline(List<HankIncidentItem> incidents) {
    if (incidents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            '该类型暂无事件',
            style: TextStyle(fontSize: 13, color: AppColors.slate500),
          ),
        ),
      );
    }

    return Stack(
      children: [
        // 左侧竖线
        Positioned(
          left: 10,
          top: 8,
          bottom: 8,
          child: Container(
            width: 2,
            color: AppColors.violet200,
          ),
        ),
        // 事件列表
        Column(
          children: incidents.map((incident) {
            return _buildEventItem(incident);
          }).toList(),
        ),
      ],
    );
  }

  /// 单个事件项
  /// 左侧：事件图标圆点（在竖线上）
  /// 右侧：白色圆角卡片，包含标题行（时间 + 队名/比分）+ 描述
  Widget _buildEventItem(HankIncidentItem incident) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧：事件图标圆点
          _buildEventIcon(incident),
          const SizedBox(width: 12),
          // 右侧：白色事件卡片
          Expanded(
            child: _buildEventCard(incident),
          ),
        ],
      ),
    );
  }

  /// 事件图标圆点（左侧）
  Widget _buildEventIcon(HankIncidentItem incident) {
    final iconColor = incident.iconColor;
    final isGoal = incident.type == 1 || incident.type == 8 || incident.type == 17;

    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isGoal ? iconColor : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor,
          width: 2,
        ),
        boxShadow: isGoal
            ? [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(
        incident.iconData,
        size: 10,
        color: isGoal ? Colors.white : iconColor,
      ),
    );
  }

  /// 事件卡片（右侧白色容器）
  Widget _buildEventCard(HankIncidentItem incident) {
    final iconColor = incident.iconColor;
    final isGoal = incident.type == 1 || incident.type == 8 || incident.type == 17;

    // 构建标题：时间 + 事件类型名
    final titleText = "${incident.time ?? 0}' - ${incident.custTypeName}";

    // 构建右侧信息：球队名 或 比分
    String rightText;
    if (incident.homeScore != null && incident.awayScore != null) {
      rightText = '${incident.homeScore} - ${incident.awayScore}';
    } else {
      rightText = incident.position == 1 ? '主队' : '客队';
    }

    // 构建描述文本
    final playerName = incident.custPlayerName;
    final typeName = incident.custTypeName;
    String description;
    if (incident.type == 9) {
      // 换人：出场球员 → 进场球员
      description = '换人调整：${incident.outPlayerName ?? ''} 替换 ${incident.inPlayerName ?? ''} 登场。';
    } else if (playerName.isNotEmpty) {
      description = '$playerName - $typeName';
    } else {
      description = typeName;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGoal
              ? iconColor.withOpacity(0.4)
              : AppColors.violet200.withOpacity(0.5),
        ),
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
          // 标题行：左 时间+类型名 | 右 球队/比分
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  titleText,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rightText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: incident.position == 1
                      ? AppColors.rose500
                      : AppColors.blue500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 描述文本
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppColors.slate700,
            ),
          ),
          // 比分变化行（如有）
          if (incident.homeScore != null && incident.awayScore != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.violet100),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.sports_soccer, size: 10, color: iconColor),
                  const SizedBox(width: 4),
                  Text(
                    '比分: ${incident.homeScore} - ${incident.awayScore}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_odds_model.dart';
import '../../models/hank_odds_history_model.dart';
import '../../services/hank_match_detail_api_service.dart';
import '../../widgets/match/match_detail_odds_tab.dart';

/// HankOddsHistoryPage: 指数历史页面
/// 展示某场比赛某博彩公司的历史赔率变化
/// 布局与ZogoLive不同：顶部盘口类型Tab + 水平公司芯片选择器 + 垂直时间轴卡片列表
/// 主题：浅紫色 + 白色
/// 接口：GET /api/livespeed/football/match/odd-histories
class HankOddsHistoryPage extends StatefulWidget {
  /// 比赛ID
  final int matchId;

  /// 初始选中的博彩公司
  final HankOddsCompany initialCompany;

  /// 所有博彩公司列表
  final List<HankOddsCompany> allCompanies;

  /// 初始盘口类型
  final HankOddsMenuType initialOddsType;

  HankOddsHistoryPage({
    required this.matchId,
    required this.initialCompany,
    required this.allCompanies,
    required this.initialOddsType,
    Key? key,
  }) : super(key: key);

  @override
  State<HankOddsHistoryPage> createState() => _HankOddsHistoryPageState();
}

class _HankOddsHistoryPageState extends State<HankOddsHistoryPage> {
  /// 详情接口服务
  final HankMatchDetailApiService _apiService = HankMatchDetailApiService();

  /// 当前选中的博彩公司ID
  late String _selectedCompanyId;

  /// 当前选中的盘口类型
  late HankOddsMenuType _currentOddsType;

  /// 是否正在加载
  bool _isLoading = true;

  /// 历史赔率数据
  HankOddsHistoryData? _historyData;

  /// 盘口类型菜单配置（标题 + 枚举）
  static const _menuConfigs = <HankOddsMenuType, String>{
    HankOddsMenuType.asia: '胜负',
    HankOddsMenuType.eu: '胜平负',
    HankOddsMenuType.bs: '总进球',
    HankOddsMenuType.cr: '角球',
  };

  /// 表头配置（根据盘口类型返回不同的列标题）
  List<String> _getHeaders() {
    switch (_currentOddsType) {
      case HankOddsMenuType.asia:
        return ['主胜', '盘口', '客胜'];
      case HankOddsMenuType.eu:
        return ['主胜', '平局', '客胜'];
      case HankOddsMenuType.bs:
        return ['大球', '盘口', '小球'];
      case HankOddsMenuType.cr:
        return ['大角', '盘口', '小角'];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCompanyId = widget.initialCompany.companyId ?? '';
    _currentOddsType = widget.initialOddsType;
    _fetchHistoryData();
  }

  /// 请求指数历史数据
  /// 接口：GET /api/livespeed/football/match/odd-histories
  /// 参数：match_id, company_id
  Future<void> _fetchHistoryData() async {
    setState(() => _isLoading = true);

    final data = await _apiService.fetchOddsHistory(
      matchId: widget.matchId,
      companyId: _selectedCompanyId,
    );

    if (mounted) {
      setState(() {
        _historyData = data;
        _isLoading = false;
      });
    }
  }

  /// 获取当前盘口类型对应的历史列表
  List<HankOddsHistoryItem>? _getCurrentList() {
    final data = _historyData;
    if (data == null) return null;

    switch (_currentOddsType) {
      case HankOddsMenuType.asia:
        return data.asia;
      case HankOddsMenuType.eu:
        return data.eu;
      case HankOddsMenuType.bs:
        return data.bs;
      case HankOddsMenuType.cr:
        return data.cr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      body: Column(
        children: [
          _buildAppBar(),
          _buildOddsTypeTabs(),
          _buildCompanyChips(),
          _buildTableHeader(),
          Expanded(child: _buildTimelineList()),
        ],
      ),
    );
  }

  /// 顶部导航栏（返回按钮 + 标题）
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
            // 返回按钮
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
            // 标题
            const Text(
              '指数历史',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const Spacer(),
            // 刷新按钮
            GestureDetector(
              onTap: _fetchHistoryData,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.violet100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.refresh,
                  size: 16,
                  color: AppColors.violet700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 盘口类型Tab（胜负 / 胜平负 / 总进球 / 角球）
  Widget _buildOddsTypeTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: HankOddsMenuType.values.map((type) {
          final isSelected = _currentOddsType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentOddsType = type),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.violet600 : AppColors.violet50,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  _menuConfigs[type]!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppColors.slate500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 博彩公司水平芯片选择器
  Widget _buildCompanyChips() {
    return Container(
      height: 47,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        itemCount: widget.allCompanies.length,
        itemBuilder: (context, index) {
          final comp = widget.allCompanies[index];
          final isSelected = comp.companyId == _selectedCompanyId;

          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() {
                  _selectedCompanyId = comp.companyId ?? '';
                });
                _fetchHistoryData();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.violet100 : AppColors.violet50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.violet300
                      : AppColors.violet200.withOpacity(0.5),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    comp.name ?? '--',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color:
                          isSelected ? AppColors.violet700 : AppColors.slate500,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    comp.spot?.draw ?? comp.pre?.draw ?? comp.ini?.draw ?? '-',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.rose500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 表头行（时间/比分 + 三列赔率标题）
  Widget _buildTableHeader() {
    final headers = _getHeaders();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.violet100,
        border: Border(
          bottom: BorderSide(color: AppColors.violet200),
        ),
      ),
      child: Row(
        children: [
          // 时间/比分
          const SizedBox(
            width: 72,
            child: Text(
              '时间/比分',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ),
          // 三列赔率标题
          ...headers.map((h) => Expanded(
                child: Text(
                  h,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate500,
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// 时间轴列表（垂直卡片式时间轴，左侧带连接线）
  Widget _buildTimelineList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    final list = _getCurrentList();

    if (list == null || list.isEmpty) {
      return const Center(
        child: Text(
          '暂无历史数据',
          style: TextStyle(fontSize: 14, color: AppColors.slate500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return _buildTimelineCard(item, index, list);
      },
    );
  }

  /// 单条时间轴卡片
  /// [item] 历史赔率数据
  /// [index] 列表索引
  /// [list] 完整列表（用于计算涨跌）
  Widget _buildTimelineCard(
      HankOddsHistoryItem item, int index, List<HankOddsHistoryItem> list) {
    // 与上一条对比计算涨跌
    final bool isLatest = index == 0;
    final bool hasNext = index < list.length - 1;

    // 涨跌判断：与下一条（时间更早的）对比
    HankOddsHistoryItem? prevItem;
    if (hasNext) {
      prevItem = list[index + 1];
    }

    final homeChange = _compareValue(item.home, prevItem?.home);
    final awayChange = _compareValue(item.away, prevItem?.away);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 左侧时间轴轨道
          _buildTimelineTrack(item, isLatest, hasNext),
          const SizedBox(width: 8),
          // 右侧赔率卡片
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isLatest
                      ? AppColors.violet300
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
              child: Row(
                children: [
                  // 主胜/大球
                  Expanded(
                    child: _buildValueWithTrend(
                      item.home,
                      homeChange,
                      true,
                    ),
                  ),
                  // 盘口/平局
                  Container(
                    width: 56,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.violet50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.draw ?? '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                    ),
                  ),
                  // 客胜/小球
                  Expanded(
                    child: _buildValueWithTrend(
                      item.away,
                      awayChange,
                      false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 左侧时间轴轨道（圆点 + 连接线 + 时间标签）
  /// [item] 当前历史数据
  /// [isLatest] 是否最新一条
  /// [hasNext] 是否有更早的数据
  Widget _buildTimelineTrack(
      HankOddsHistoryItem item, bool isLatest, bool hasNext) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          // 上方连接线（指向更晚的数据）
          Container(
            width: 2,
            height: 12,
            color: isLatest ? Colors.transparent : AppColors.violet200,
          ),
          // 圆点
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isLatest ? AppColors.violet600 : AppColors.violet300,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 时间标签
          Text(
            item.matchOffset ?? '开盘',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isLatest ? FontWeight.w700 : FontWeight.w500,
              color: isLatest ? AppColors.violet700 : AppColors.slate500,
            ),
          ),
          const SizedBox(height: 2),
          // 比分
          Text(
            item.score ?? '0-0',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.slate500,
            ),
          ),
          // 下方连接线（指向更早的数据）
          if (hasNext)
            Expanded(
              child: Container(
                width: 2,
                color: AppColors.violet200,
              ),
            ),
        ],
      ),
    );
  }

  /// 赔率值 + 涨跌趋势
  /// [value] 赔率值
  /// [change] 涨跌类型（1=涨, -1=跌, 0=不变）
  /// [isHome] 是否主队方向
  Widget _buildValueWithTrend(String? value, int change, bool isHome) {
    Color valueColor = AppColors.slate800;
    Widget? trendIcon;

    if (change > 0) {
      valueColor = AppColors.rose500;
      trendIcon = const Icon(
        Icons.arrow_drop_up,
        size: 16,
        color: AppColors.rose500,
      );
    } else if (change < 0) {
      valueColor = AppColors.emerald500;
      trendIcon = const Icon(
        Icons.arrow_drop_down,
        size: 16,
        color: AppColors.emerald500,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value ?? '-',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        if (trendIcon != null) trendIcon,
      ],
    );
  }

  /// 比较两个赔率值的大小
  /// [current] 当前值
  /// [previous] 上一个值
  /// 返回：1=涨, -1=跌, 0=不变或无法比较
  int _compareValue(String? current, String? previous) {
    if (current == null || previous == null) return 0;
    final cur = double.tryParse(current);
    final prev = double.tryParse(previous);
    if (cur == null || prev == null) return 0;
    if (cur > prev) return 1;
    if (cur < prev) return -1;
    return 0;
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_odds_model.dart';
import '../../pages/match/odds_history_page.dart';

/// HankOddsMenuType: 指数分析菜单枚举
/// asia: 胜负（亚盘让球）| eu: 胜平负（欧赔）| bs: 总进球（大小球）| cr: 角球
enum HankOddsMenuType {
  /// 胜负（亚盘让球）
  asia,
  /// 胜平负（欧赔）
  eu,
  /// 总进球（大小球）
  bs,
  /// 角球
  cr,
}

/// MatchDetailOddsTab: 指数分析Tab组件
/// 展示博彩公司赔率数据，菜单切换胜负/胜平负/总进球/角球
/// 使用接口 /api/livespeed/football/match/odds 返回数据
/// 浅紫色+白色主题风格，保留现有卡片UI风格
class MatchDetailOddsTab extends StatefulWidget {
  /// 指数数据（包含 asia/eu/bs/cr 四种盘口）
  final HankOddsData? oddsData;

  /// 是否正在加载
  final bool isLoading;

  /// 比赛ID（用于跳转指数历史页面）
  final int matchId;

  MatchDetailOddsTab({
    required this.oddsData,
    required this.isLoading,
    required this.matchId,
    Key? key,
  }) : super(key: key);

  @override
  State<MatchDetailOddsTab> createState() => _MatchDetailOddsTabState();
}

class _MatchDetailOddsTabState extends State<MatchDetailOddsTab> {
  /// 当前选中的菜单
  HankOddsMenuType _currentMenu = HankOddsMenuType.asia;

  /// 菜单配置（标题 + 对应字段）
  static const _menuConfigs = <HankOddsMenuType, String>{
    HankOddsMenuType.asia: '胜负',
    HankOddsMenuType.eu: '胜平负',
    HankOddsMenuType.bs: '总进球',
    HankOddsMenuType.cr: '角球',
  };

  /// 表头配置（根据菜单类型返回不同的列标题）
  List<String> _getHeaders() {
    switch (_currentMenu) {
      case HankOddsMenuType.asia:
        return ['博彩公司', '主胜', '盘口', '客胜'];
      case HankOddsMenuType.eu:
        return ['博彩公司', '主胜', '平局', '客胜'];
      case HankOddsMenuType.bs:
        return ['博彩公司', '大球', '盘口', '小球'];
      case HankOddsMenuType.cr:
        return ['博彩公司', '大角', '盘口', '小角'];
    }
  }

  /// 获取当前菜单对应的赔率公司列表
  List<HankOddsCompany>? _getCurrentCompanies() {
    final data = widget.oddsData;
    if (data == null) return null;

    switch (_currentMenu) {
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

  /// 获取菜单标题
  String _getMenuTitle() {
    switch (_currentMenu) {
      case HankOddsMenuType.asia:
        return '让球指数 (亚盘)';
      case HankOddsMenuType.eu:
        return '欧赔指数 (胜平负)';
      case HankOddsMenuType.bs:
        return '大小球 (总进球)';
      case HankOddsMenuType.cr:
        return '角球指数';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.violet600,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuSelector(),
          const SizedBox(height: 16),
          _buildOddsCard(),
        ],
      ),
    );
  }

  /// 菜单选择器（胜负 / 胜平负 / 总进球 / 角球）
  Widget _buildMenuSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
        children: HankOddsMenuType.values.map((type) {
          final isSelected = _currentMenu == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentMenu = type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.violet100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _menuConfigs[type]!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppColors.violet700 : AppColors.slate500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 赔率数据卡片
  Widget _buildOddsCard() {
    final companies = _getCurrentCompanies();

    if (companies == null || companies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.violet200.withOpacity(0.6)),
        ),
        child: const Center(
          child: Text(
            '暂无指数数据',
            style: TextStyle(fontSize: 14, color: AppColors.slate500),
          ),
        ),
      );
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
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getMenuTitle(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
              const Text(
                '即时盘',
                style: TextStyle(fontSize: 10, color: AppColors.emerald500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 表头
          _buildTableHeader(_getHeaders()),
          // 数据行
          ...companies.map((company) => _buildCompanyRow(company)),
        ],
      ),
    );
  }

  /// 博彩公司数据行
  /// 展示公司名 + Open/Pre/Live 三阶段赔率
  /// 点击跳转指数历史页面
  Widget _buildCompanyRow(HankOddsCompany company) {
    final hasPre = company.pre != null;
    final hasSpot = company.spot != null;

    return GestureDetector(
      onTap: () => _navigateToOddsHistory(company),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.violet100),
          ),
        ),
        child: Row(
          children: [
            // 公司名
            SizedBox(
              width: 70,
              child: Text(
                company.name ?? '--',
                style: const TextStyle(
                  color: AppColors.slate800,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // 赔率区
            Expanded(
              child: Column(
                children: [
                  // 初盘赔率
                  _buildOddsRow(company.ini, AppColors.slate500, '初盘'),
                  // 临场赔率
                  if (hasPre) ...[
                    const SizedBox(height: 8),
                    _buildOddsRow(company.pre, AppColors.blue500, '临场'),
                  ],
                  // 即时赔率
                  if (hasSpot) ...[
                    const SizedBox(height: 8),
                    _buildOddsRow(company.spot, AppColors.emerald500, '即时'),
                  ],
                ],
              ),
            ),
            // 箭头
            const Icon(
              Icons.chevron_right,
              size: 16,
              color: AppColors.violet300,
            ),
          ],
        ),
      ),
    );
  }

  /// 跳转到指数历史页面
  /// [company] 当前点击的博彩公司
  void _navigateToOddsHistory(HankOddsCompany company) {
    final allCompanies = _getCurrentCompanies() ?? [];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HankOddsHistoryPage(
          matchId: widget.matchId,
          initialCompany: company,
          allCompanies: allCompanies,
          initialOddsType: _currentMenu,
        ),
      ),
    );
  }

  /// 单行赔率（三列：home / draw / away）
  Widget _buildOddsRow(HankOddsDetail? detail, Color color, String stageLabel) {
    return Row(
      children: [
        // 阶段标签
        SizedBox(
          width: 36,
          child: Text(
            stageLabel,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // 主胜/大球
        Expanded(
          child: Text(
            detail?.home ?? '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
        // 平局/盘口
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.violet50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              detail?.draw ?? '-',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.slate700,
              ),
            ),
          ),
        ),
        // 客胜/小球
        Expanded(
          child: Text(
            detail?.away ?? '-',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  /// 表头行
  Widget _buildTableHeader(List<String> headers) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // 公司名列表头
          const SizedBox(
            width: 70,
            child: Text(
              '公司',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ),
          // 阶段标签占位
          const SizedBox(
            width: 36,
            child: Text(
              '',
              style: TextStyle(fontSize: 11),
            ),
          ),
          // 三列表头
          ...headers.skip(1).map((h) => Expanded(
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
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_competition_filter_model.dart';
import '../../utils/hank_network_manager.dart';

/// HankLeagueFilterPage: 联赛筛选页面
/// 功能：左侧分类菜单 + 右侧联赛列表（带勾选），支持全选/反选/重置
/// 接口：GET /api/livespeed/football/competition-filter，参数 tab=0
/// 主题：浅紫色 + 白色
/// 参照 leagueList.html 布局，去除五大联赛按钮
class HankLeagueFilterPage extends StatefulWidget {
  /// 构造函数
  const HankLeagueFilterPage({Key? key}) : super(key: key);

  @override
  State<HankLeagueFilterPage> createState() => _HankLeagueFilterPageState();
}

class _HankLeagueFilterPageState extends State<HankLeagueFilterPage> {
  /// 分类列表（菜单数据）
  List<HankFilterCategory> _categories = [];

  /// 当前选中的分类索引
  int _selectedCategoryIndex = 0;

  /// 已选中的联赛ID集合
  final Set<int> _selectedIds = {};

  /// 是否正在加载
  bool _isLoading = true;

  /// 总比赛场次（已选联赛的比赛数总和）
  int _totalMatches = 0;

  @override
  void initState() {
    super.initState();
    _fetchFilterData();
  }

  /// 请求联赛筛选数据
  /// 接口：GET /api/livespeed/football/competition-filter
  /// 参数：tab=0
  Future<void> _fetchFilterData() async {
    final response = await HankNetworkManager()
        .getRequest('/api/livespeed/football/competition-filter', queryParameters: {
      'tab': 0,
    });

    if (response.isSuccess && response.data != null) {
      final filterData = HankCompetitionFilterData.fromJson(
          response.data as Map<String, dynamic>);
      setState(() {
        _categories = filterData.categories;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 获取当前分类下的联赛列表
  List<HankCompetition> get _currentCompetitions {
    if (_categories.isEmpty) return [];
    return _categories[_selectedCategoryIndex].competitions;
  }

  /// 切换分类
  /// [index] - 目标分类索引
  void _switchCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  /// 切换联赛选中状态
  /// [competition] - 联赛实体
  void _toggleCompetition(HankCompetition competition) {
    setState(() {
      if (_selectedIds.contains(competition.id)) {
        _selectedIds.remove(competition.id);
      } else {
        _selectedIds.add(competition.id);
      }
      _updateTotalMatches();
    });
  }

  /// 全选当前分类下的所有联赛
  void _selectAll() {
    setState(() {
      for (final c in _currentCompetitions) {
        _selectedIds.add(c.id);
      }
      _updateTotalMatches();
    });
  }

  /// 反选当前分类下的所有联赛
  void _invertSelection() {
    setState(() {
      for (final c in _currentCompetitions) {
        if (_selectedIds.contains(c.id)) {
          _selectedIds.remove(c.id);
        } else {
          _selectedIds.add(c.id);
        }
      }
      _updateTotalMatches();
    });
  }

  /// 重置所有选择
  void _resetSelection() {
    setState(() {
      _selectedIds.clear();
      _totalMatches = 0;
    });
  }

  /// 更新已选联赛的总比赛场次
  void _updateTotalMatches() {
    int count = 0;
    for (final category in _categories) {
      for (final c in category.competitions) {
        if (_selectedIds.contains(c.id)) {
          count += c.matches;
        }
      }
    }
    _totalMatches = count;
  }

  /// 获取当前分类下已选中的数量
  int get _currentSelectedCount {
    int count = 0;
    for (final c in _currentCompetitions) {
      if (_selectedIds.contains(c.id)) count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.violet50,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.violet600))
          : _categories.isEmpty
              ? _buildEmptyView()
              : Column(
                  children: [
                    _buildActionBar(),
                    Expanded(child: _buildContentBody()),
                    _buildBottomBar(),
                  ],
                ),
    );
  }

  /// 构建顶部导航栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text('联赛筛选',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w700,
              color: AppColors.slate800)),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18,
            color: AppColors.slate600),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: _resetSelection,
          child: const Text('重置',
              style: TextStyle(fontSize: 13, color: AppColors.violet600)),
        ),
      ],
    );
  }

  /// 构建操作栏（全选、反选、已选数量）
  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _buildQuickButton('全选', _selectAll),
          const SizedBox(width: 8),
          _buildQuickButton('反选', _invertSelection),
          const Spacer(),
          Text(
            '已选 $_currentSelectedCount/${_currentCompetitions.length} 项',
            style: const TextStyle(fontSize: 11, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  /// 构建快捷按钮（全选/反选）
  Widget _buildQuickButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.violet50,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.violet200),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.slate600)),
      ),
    );
  }

  /// 构建主体内容（左侧菜单 + 右侧联赛列表）
  Widget _buildContentBody() {
    return Row(
      children: [
        _buildCategoryMenu(),
        Expanded(child: _buildCompetitionList()),
      ],
    );
  }

  /// 构建左侧分类菜单
  Widget _buildCategoryMenu() {
    return Container(
      width: 90,
      color: AppColors.violet50,
      child: ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (ctx, index) {
          final category = _categories[index];
          final isSelected = index == _selectedCategoryIndex;
          return GestureDetector(
            onTap: () => _switchCategory(index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected ? AppColors.violet600 : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? AppColors.violet700 : AppColors.slate500,
                    ),
                  ),
                  if (category.competitions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '${category.competitions.length}',
                        style: TextStyle(
                          fontSize: 9,
                          color: isSelected
                              ? AppColors.violet400
                              : AppColors.slate400,
                        ),
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

  /// 构建右侧联赛列表
  Widget _buildCompetitionList() {
    final competitions = _currentCompetitions;
    if (competitions.isEmpty) {
      return _buildEmptyView();
    }
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: competitions.length,
        itemBuilder: (ctx, index) {
          return _buildCompetitionCard(competitions[index]);
        },
      ),
    );
  }

  /// 构建单条联赛卡片
  Widget _buildCompetitionCard(HankCompetition competition) {
    final isChecked = _selectedIds.contains(competition.id);
    return GestureDetector(
      onTap: () => _toggleCompetition(competition),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isChecked ? AppColors.violet50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isChecked ? AppColors.violet300 : AppColors.violet100,
          ),
        ),
        child: Row(
          children: [
            // 联赛logo
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: competition.logo.isNotEmpty
                  ? Image.network(
                      competition.logo,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildLogoPlaceholder(),
                    )
                  : _buildLogoPlaceholder(),
            ),
            const SizedBox(width: 10),
            // 联赛名称
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${competition.matches} 场比赛',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            // 勾选框
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? AppColors.violet600 : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppColors.violet600 : AppColors.slate400,
                  width: 1.5,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建logo占位图
  Widget _buildLogoPlaceholder() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.violet100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.sports_soccer, size: 16, color: AppColors.violet400),
    );
  }

  /// 构建空状态视图
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 48, color: AppColors.slate400),
          const SizedBox(height: 8),
          const Text('暂无联赛数据',
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
        ],
      ),
    );
  }

  /// 构建底部确认栏
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.violet200.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '已选 ',
                        style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                    TextSpan(text: '${_selectedIds.length}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                    const TextSpan(text: ' 个联赛',
                        style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '涵盖 ',
                        style: TextStyle(fontSize: 10, color: AppColors.slate400)),
                    TextSpan(text: '$_totalMatches',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppColors.violet600)),
                    const TextSpan(text: ' 场比赛',
                        style: TextStyle(fontSize: 10, color: AppColors.slate400)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.pop(context, _selectedIds.toList()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.violet400, AppColors.violet600],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet600.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text('确 定',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../services/hank_match_api_service.dart';
import '../../widgets/match/featured_match_card.dart';
import '../../widgets/match/standard_match_card.dart';
import '../../widgets/common/calendar_bottom_sheet.dart';
import 'match_detail_page.dart';
import '../search/search_page.dart';

/// MatchSubTab: 比赛列表二级Tab枚举
/// 对应接口 tab 参数：关注=4，推荐=5，赛程=2，赛果=3
enum MatchSubTab {
  /// 关注 tab=4
  follow,
  /// 推荐 tab=5
  recommend,
  /// 赛程 tab=2
  schedule,
  /// 赛果 tab=3
  results,
}

/// MatchPage: 比赛列表页
/// 含4个二级Tab：关注/推荐/赛程/赛果
/// 赛程和赛果Tab含日历选择按钮 + 7天日期横滑条
/// 数据通过 HankMatchApiService 请求接口获取
/// 支持下拉刷新 + 上拉加载更多
class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  /// 当前选中的子Tab
  MatchSubTab _currentSubTab = MatchSubTab.recommend;

  /// 日历当前选中的日期
  DateTime _selectedDate = DateTime.now();

  /// 日期横滑条锚点日期（仅在日历选项卡确认时更新，点击横滑条不更新）
  /// 赛程：锚点为横滑条第一个日期；赛果：锚点为横滑条最后一个日期
  DateTime _anchorDate = DateTime.now();

  /// 赛程模式下缓存的选中日期
  DateTime? _scheduleSelectedDate;

  /// 赛程模式下缓存的锚点日期
  DateTime? _scheduleAnchorDate;

  /// 赛果模式下缓存的选中日期
  DateTime? _resultsSelectedDate;

  /// 赛果模式下缓存的锚点日期
  DateTime? _resultsResultsAnchorDate;

  /// 比赛数据列表
  List<MatchModel> _matches = [];

  /// 是否正在加载（首次加载 / 上拉加载）
  bool _isLoading = false;

  /// 是否正在下拉刷新
  bool _isRefreshing = false;

  /// 是否没有更多数据
  bool _hasNoMore = false;

  /// 分页页码
  int _page = 1;

  /// 每页条数
  final int _size = 10;

  /// API服务实例
  final HankMatchApiService _apiService = HankMatchApiService();

  /// 滚动控制器（用于上拉加载监听）
  final ScrollController _scrollController = ScrollController();

  /// 日期横滑条滚动控制器（用于日历选择后自动滚动）
  final ScrollController _dateStripController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchMatches(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _dateStripController.dispose();
    super.dispose();
  }

  /// 滚动监听：到达底部触发加载更多
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && !_isRefreshing && !_hasNoMore) {
        _fetchMatches(isRefresh: false);
      }
    }
  }

  /// 将 MatchSubTab 转换为接口对应的 HankMatchTab
  HankMatchTab _getApiTab(MatchSubTab tab) {
    switch (tab) {
      case MatchSubTab.follow:
        return HankMatchTab.follow;
      case MatchSubTab.recommend:
        return HankMatchTab.recommend;
      case MatchSubTab.schedule:
        return HankMatchTab.schedule;
      case MatchSubTab.results:
        return HankMatchTab.results;
    }
  }

  /// 获取当前选中日期的时间戳（秒）
  int _getSelectedTimestamp() {
    return _selectedDate.millisecondsSinceEpoch ~/ 1000;
  }

  /// 请求比赛列表数据
  /// [isRefresh] - true=刷新（重置page=1），false=加载更多
  Future<void> _fetchMatches({required bool isRefresh}) async {
    if (_isLoading || _isRefreshing) return;

    if (isRefresh) {
      setState(() {
        _isRefreshing = true;
        _page = 1;
        _hasNoMore = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    final timestamp = _getSelectedTimestamp();
    final requestPage = isRefresh ? 1 : _page + 1;

    final result = await _apiService.fetchMatchModels(
      tab: _getApiTab(_currentSubTab),
      page: requestPage,
      size: _size,
      timestamp: timestamp,
    );

    if (mounted) {
      setState(() {
        if (isRefresh) {
          _matches = result;
          _page = 1;
          _isRefreshing = false;
        } else {
          _matches.addAll(result);
          _page = requestPage;
          _isLoading = false;
        }
        // 返回数据不足一页，标记没有更多
        if (result.length < _size) {
          _hasNoMore = true;
        }
      });
    }
  }

  /// 是否显示日历按钮
  bool get _showCalendar =>
      _currentSubTab == MatchSubTab.schedule ||
      _currentSubTab == MatchSubTab.results;

  /// 日历标题
  String get _calendarTitle {
    if (_currentSubTab == MatchSubTab.schedule) return '赛程日期选择';
    if (_currentSubTab == MatchSubTab.results) return '赛果日期选择';
    return '日期选择';
  }

  void _switchSubTab(MatchSubTab tab) {
    // 保存离开Tab的日期缓存
    if (_currentSubTab == MatchSubTab.schedule) {
      _scheduleSelectedDate = _selectedDate;
      _scheduleAnchorDate = _anchorDate;
    } else if (_currentSubTab == MatchSubTab.results) {
      _resultsSelectedDate = _selectedDate;
      _resultsResultsAnchorDate = _anchorDate;
    }

    // 恢复目标Tab的缓存日期
    DateTime newSelectedDate;
    DateTime newAnchorDate;
    if (tab == MatchSubTab.schedule && _scheduleSelectedDate != null) {
      newSelectedDate = _scheduleSelectedDate!;
      newAnchorDate = _scheduleAnchorDate!;
    } else if (tab == MatchSubTab.results && _resultsSelectedDate != null) {
      newSelectedDate = _resultsSelectedDate!;
      newAnchorDate = _resultsResultsAnchorDate!;
    } else {
      newSelectedDate = DateTime.now();
      newAnchorDate = DateTime.now();
    }

    // 在setState之前预设滚动偏移量，避免重建后出现滚动动画
    const itemWidth = 64.0;
    if (tab == MatchSubTab.schedule) {
      if (_dateStripController.hasClients) {
        _dateStripController.jumpTo(0);
      }
    } else if (tab == MatchSubTab.results) {
      if (_dateStripController.hasClients) {
        _dateStripController.jumpTo(6 * itemWidth);
      }
    }

    setState(() {
      _currentSubTab = tab;
      _selectedDate = newSelectedDate;
      _anchorDate = newAnchorDate;
      _matches = [];
      _hasNoMore = false;
    });

    // 确保重建后偏移量正确（无动画）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dateStripController.hasClients) return;
      if (tab == MatchSubTab.schedule) {
        _dateStripController.jumpTo(0);
      } else if (tab == MatchSubTab.results) {
        _dateStripController.jumpTo(6 * itemWidth);
      }
    });

    _fetchMatches(isRefresh: true);
  }

  /// 跳转到比赛详情页
  void _navigateToDetail(MatchModel match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchDetailPage(match: match),
      ),
    );
  }

  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HankSearchPage()),
    );
  }

  /// 打开日历底部弹窗
  void _openCalendar() {
    final now = DateTime.now();
    DateTime firstDate;
    DateTime lastDate;

    if (_currentSubTab == MatchSubTab.schedule) {
      // 赛程：仅可选当天及以后（当天 ~ 一年后）
      firstDate = now;
      lastDate = now.add(const Duration(days: 365));
    } else {
      // 赛果：仅可选当天及之前（一年前 ~ 当天）
      firstDate = now.subtract(const Duration(days: 365));
      lastDate = now;
    }

    CalendarBottomSheet.show(
      context,
      title: _calendarTitle,
      initialDate: _selectedDate.isAfter(lastDate)
          ? lastDate
          : (_selectedDate.isBefore(firstDate) ? firstDate : _selectedDate),
      firstDate: firstDate,
      lastDate: lastDate,
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _selectedDate = selected;
          _anchorDate = selected;
        });
        // 仅在日历选项卡确认日期时刷新横滑条数据
        _scrollDateStripToSelected();
        _fetchMatches(isRefresh: true);
      }
    });
  }

  /// 日历选择后，滚动日期横滑条到选中日期位置（无动画）
  /// 赛程：选中日期在第一个，滚动到最左
  /// 赛果：选中日期在最后一个，滚动到最右
  void _scrollDateStripToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dateStripController.hasClients) return;

      // 每个日期项宽度56 + 间距8 = 64
      const itemWidth = 64.0;
      if (_currentSubTab == MatchSubTab.schedule) {
        // 赛程：选中日期是第一个，滚动到最左
        _dateStripController.jumpTo(0);
      } else {
        // 赛果：选中日期是最后一个，滚动到最右
        _dateStripController.jumpTo(6 * itemWidth);
      }
    });
  }

  /// 格式化选中日期显示
  String get _selectedDateText {
    return '${_selectedDate.month}/${_selectedDate.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMatchList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 比赛列表区域（含下拉刷新 + 上拉加载 + 加载态 + 空态）
  /// 底部 padding 留出底部导航栏空间，防止Tab遮挡列表
  Widget _buildMatchList() {
    // 首次加载中
    if (_isRefreshing && _matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    // 空数据
    if (_matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.sports_soccer_outlined,
              size: 48,
              color: AppColors.violet300,
            ),
            SizedBox(height: 12),
            Text(
              '暂无比赛数据',
              style: TextStyle(color: AppColors.slate500, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.violet600,
      onRefresh: () => _fetchMatches(isRefresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
        itemCount: _matches.length + 1, // +1 for footer
        itemBuilder: (ctx, index) {
          // 底部加载/没有更多指示器
          if (index == _matches.length) {
            return _buildFooter();
          }

          final match = _matches[index];
          if (match.isFeatured) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FeaturedMatchCard(
                match: match,
                onTap: () => _navigateToDetail(match),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StandardMatchCard(
              match: match,
              onTap: () => _navigateToDetail(match),
            ),
          );
        },
      ),
    );
  }

  /// 列表底部指示器（加载中 / 没有更多）
  Widget _buildFooter() {
    if (_hasNoMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 1,
                color: AppColors.violet200,
              ),
              const SizedBox(width: 8),
              const Text(
                '没有更多了',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 1,
                color: AppColors.violet200,
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: AppColors.violet600,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.violet600,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '紫极球坛',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openSearch,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.violet200),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A0F172A),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 12,
                            color: AppColors.violet500,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              '搜索球队/联赛',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xB37C3AED),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.violet100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '⌘K',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.violet600,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('无未读通知'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.violet200),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 14,
                            color: AppColors.violet700,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.rose500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSubTabs(),
            if (_showCalendar) ...[
              const SizedBox(height: 8),
              _buildCalendarButton(),
              const SizedBox(height: 6),
              _buildDateStrip(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabs() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0x99DDD6FE),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSubTabButton(MatchSubTab.follow, '关注'),
          _buildSubTabButton(MatchSubTab.recommend, '推荐'),
          _buildSubTabButton(MatchSubTab.schedule, '赛程'),
          _buildSubTabButton(MatchSubTab.results, '赛果'),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(MatchSubTab tab, String label) {
    final isSelected = _currentSubTab == tab;
    return GestureDetector(
      onTap: () => _switchSubTab(tab),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 14 : 10,
                vertical: isSelected ? 4 : 6,
              ),
              decoration: isSelected
                  ? BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.violet200.withOpacity(0.5),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0A0F172A),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    )
                  : null,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.violet700 : AppColors.slate500,
                ),
              ),
            ),
            if (isSelected)
              Positioned(
                left: 0,
                right: 0,
                bottom: -8,
                child: Center(
                  child: Container(
                    width: 16,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.violet600,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 日历按钮：点击后底部弹出日历选项卡
  Widget _buildCalendarButton() {
    return Container(
      padding: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x66DDD6FE), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month,
            size: 12,
            color: AppColors.violet600,
          ),
          const SizedBox(width: 4),
          Text(
            _selectedDateText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              color: AppColors.violet900,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _openCalendar,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.violet600,
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x307C3AED),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '选择日期',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  /// 生成7天日期列表
  /// 赛程：以锚点日期为起点，往后追加6天（锚点日期+6天）
  /// 赛果：以锚点日期为终点，往前追加6天（前6天+锚点日期）
  /// 锚点日期仅在日历选项卡确认时更新，点击横滑条不影响列表
  List<DateTime> _getDateList() {
    final List<DateTime> list = [];
    if (_currentSubTab == MatchSubTab.schedule) {
      // 赛程：锚点日期为第一个，往后追加6天
      for (int i = 0; i < 7; i++) {
        list.add(_anchorDate.add(Duration(days: i)));
      }
    } else {
      // 赛果：锚点日期为最后一个，往前追加6天
      for (int i = 6; i >= 0; i--) {
        list.add(_anchorDate.subtract(Duration(days: i)));
      }
    }
    return list;
  }

  /// 判断两个日期是否同一天
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 日期横滑条：展示7天，高亮与日历选择联动
  Widget _buildDateStrip() {
    final dates = _getDateList();
    final weekDays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return SizedBox(
      height: 52,
      child: ListView.separated(
        controller: _dateStripController,
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, idx) {
          final d = dates[idx];
          final selected = _isSameDay(d, _selectedDate);
          final isToday = _isSameDay(d, DateTime.now());
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = d;
              });
              _fetchMatches(isRefresh: true);
            },
            child: Container(
              width: 56,
              padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.violet600
                    : Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                boxShadow: selected
                    ? const [
                        BoxShadow(
                          color: Color(0x407C3AED),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
                border: selected
                    ? Border.all(color: AppColors.violet300, width: 2)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? '今天' : weekDays[d.weekday % 7],
                    style: TextStyle(
                      fontSize: 9,
                      color: selected
                          ? Colors.white.withOpacity(0.8)
                          : AppColors.slate700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.month}/${d.day}',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.slate700,
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
}

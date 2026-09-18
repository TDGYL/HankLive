import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../services/hank_match_api_service.dart';
import '../../widgets/match/featured_match_card.dart';
import '../../widgets/match/standard_match_card.dart';
import '../../widgets/common/calendar_bottom_sheet.dart';
import 'match_detail_page.dart';
import 'hank_league_filter_page.dart';
import '../search/search_page.dart';

/// MatchSubTab: matchlistsecondlevelTabenum
/// maps to API tab paramcount：Follow=4，All=0，In Progress=1，Featured=5，Fixtures=2，result=3
enum MatchSubTab {
  /// Follow tab=4
  follow,

  /// All tab=0
  all,

  /// In Progress tab=1
  live,

  /// Featured tab=5
  recommend,

  /// Fixtures tab=2
  schedule,

  /// result tab=3
  results,
}

/// MatchPage: matchlistpage
/// contains6eachsecondlevelTab：Follow/All/In Progress/Featured/Fixtures/result
/// FixturesandresultTabcontainscalendarselectbutton + 6dayDatescrollitem
/// Datapasspass HankMatchApiService requestAPIget
/// supportPull to refresh + uppullloadMore
class MatchPage extends StatefulWidget {
  const MatchPage({Key? key}) : super(key: key);

  @override
  _MatchPageState createState() => _MatchPageState();
}

class _MatchPageState extends State<MatchPage> {
  /// whenbeforeselectedchildTab
  MatchSubTab _currentSubTab = MatchSubTab.recommend;

  /// calendarwhenbeforeselectedDate
  DateTime _selectedDate = DateTime.now();

  /// DatescrollitemanchorDate（onlyincalendarselectitemcardConfirmwhenupdate，tapscrollitemnotupdate）
  /// Fixtures：anchorisscrollitemaeachDate；result：anchorisscrollitemlastaeachDate
  DateTime _anchorDate = DateTime.now();

  /// FixturesmodestyledowncacheselectedDate
  DateTime? _scheduleSelectedDate;

  /// FixturesmodestyledowncacheanchorDate
  DateTime? _scheduleAnchorDate;

  /// resultmodestyledowncacheselectedDate
  DateTime? _resultsSelectedDate;

  /// resultmodestyledowncacheanchorDate
  DateTime? _resultsResultsAnchorDate;

  /// matchDatalist
  List<MatchModel> _matches = [];

  /// whetherLoading（firsttimeload / uppullload）
  bool _isLoading = false;

  /// whetheractiveinPull to refresh
  bool _isRefreshing = false;

  /// whethernohasMoreData
  bool _hasNoMore = false;

  /// categorypagepagecode
  int _page = 1;

  /// eachpageitemcount
  final int _size = 10;

  /// APIservice instance
  final HankMatchApiService _apiService = HankMatchApiService();

  /// scrollcontroller（useuppullloadlisten）
  final ScrollController _scrollController = ScrollController();

  /// Datescrollitemscrollcontroller（usecalendarselectafterautoscroll）
  ScrollController _dateStripController = ScrollController();

  /// filterselectedLeagueIDlist
  List<int> _selectedCompetitionIds = [];

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

  /// scroll listener：toreachedbottomtriggerloadMore
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_isLoading && !_isRefreshing && !_hasNoMore) {
        _fetchMatches(isRefresh: false);
      }
    }
  }

  /// will MatchSubTab convert toAPImaps to HankMatchTab
  HankMatchTab _getApiTab(MatchSubTab tab) {
    switch (tab) {
      case MatchSubTab.follow:
        return HankMatchTab.follow;
      case MatchSubTab.all:
        return HankMatchTab.all;
      case MatchSubTab.live:
        return HankMatchTab.live;
      case MatchSubTab.recommend:
        return HankMatchTab.recommend;
      case MatchSubTab.schedule:
        return HankMatchTab.schedule;
      case MatchSubTab.results:
        return HankMatchTab.results;
    }
  }

  /// getwhenbeforeselectedDateTimetimestamp（seconds）
  int _getSelectedTimestamp() {
    return _selectedDate.millisecondsSinceEpoch ~/ 1000;
  }

  /// requestmatchlistData
  /// [isRefresh] - true=refresh（resetpage=1），false=loadMore
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
      competitionIds: _selectedCompetitionIds,
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
        // BackDatanotfootballapage，markrecordnohasMore
        if (result.length < _size) {
          _hasNoMore = true;
        }
      });
    }
  }

  /// whetherdisplaycalendarbutton
  bool get _showCalendar =>
      _currentSubTab == MatchSubTab.schedule ||
      _currentSubTab == MatchSubTab.results;

  /// calendartitle
  String get _calendarTitle {
    if (_currentSubTab == MatchSubTab.schedule) return 'FixturesDateselect';
    if (_currentSubTab == MatchSubTab.results) return 'resultDateselect';
    return 'Dateselect';
  }

  void _switchSubTab(MatchSubTab tab) {
    // SaveleaveTabDatecache
    if (_currentSubTab == MatchSubTab.schedule) {
      _scheduleSelectedDate = _selectedDate;
      _scheduleAnchorDate = _anchorDate;
    } else if (_currentSubTab == MatchSubTab.results) {
      _resultsSelectedDate = _selectedDate;
      _resultsResultsAnchorDate = _anchorDate;
    }

    // restore targetTabcacheDate
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

    // createdwithactiveOKinitialoffsetnewcontroller，avoid scroll effect after rebuild
    const itemWidth = 64.0;
    _dateStripController.dispose();
    _dateStripController = ScrollController(
      initialScrollOffset: tab == MatchSubTab.results ? 5 * itemWidth : 0,
    );

    setState(() {
      _currentSubTab = tab;
      _selectedDate = newSelectedDate;
      _anchorDate = newAnchorDate;
      _matches = [];
      _hasNoMore = false;
    });

    _fetchMatches(isRefresh: true);
  }

  /// navigate tomatchDetailspage
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

  /// opencalendarbottompopup
  void _openCalendar() {
    final now = DateTime.now();
    DateTime firstDate;
    DateTime lastDate;

    if (_currentSubTab == MatchSubTab.schedule) {
      // Fixtures：onlyoptionalwhendayandwithafter（whenday ~ ayearafter）
      firstDate = now;
      lastDate = now.add(const Duration(days: 365));
    } else {
      // result：onlyoptionalwhendayand beforebefore（ayearbefore ~ whenday）
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
        // onlyincalendarselectitemcardConfirmDatewhenrefresh scrollitemData
        _scrollDateStripToSelected();
        _fetchMatches(isRefresh: true);
      }
    });
  }

  /// calendarselectafter，scrollDatescrollitemtoselectedDatePosition（noneanimation）
  /// Fixtures：selectedDateinaeach，scrolltomostleft
  /// result：selectedDateinlastaeach，scrolltomostright
  void _scrollDateStripToSelected() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_dateStripController.hasClients) return;

      // eacheachDateitemwidthdepth56 + betweendistance8 = 64
      const itemWidth = 64.0;
      if (_currentSubTab == MatchSubTab.schedule) {
        // Fixtures：selectedDateisaeach，scrolltomostleft
        _dateStripController.jumpTo(0);
      } else {
        // result：selectedDateislastaeach，scrolltomostright
        _dateStripController.jumpTo(5 * itemWidth);
      }
    });
  }

  /// formatselectedDatedisplay
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

  /// matchlistarea（containsPull to refresh + uppullload + loadstate + emptystate）
  /// bottom padding leavebottomnavbaremptybetween，preventTabblocklist
  Widget _buildMatchList() {
    // firsttimeLoading
    if (_isRefreshing && _matches.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.violet600,
          strokeWidth: 2,
        ),
      );
    }

    // emptyData
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
              'No matchesData',
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
          // bottomload/nohasMoreindicator
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

  /// listbottomindicator（Loading / nohasMore）
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
                'nohasMore',
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
                  'HankLive',
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
                              'SearchTeam/League',
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
                        content: Text('noneunreadnotifications'),
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
            _buildSubTabsRow(),
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

  /// whetherdisplayfilterbutton
  bool get _showFilterButton =>
      _currentSubTab == MatchSubTab.all ||
      _currentSubTab == MatchSubTab.live ||
      _currentSubTab == MatchSubTab.schedule ||
      _currentSubTab == MatchSubTab.results;

  /// menu+filterbuttonrow（filterbuttonwithmenuvertical align，menucloseleft）
  Widget _buildSubTabsRow() {
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
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSubTabButton(MatchSubTab.follow, 'Follow'),
                  _buildSubTabButton(MatchSubTab.recommend, 'Featured'),
                  _buildSubTabButton(MatchSubTab.all, 'All'),
                  _buildSubTabButton(MatchSubTab.live, 'In Progress'),
                  _buildSubTabButton(MatchSubTab.schedule, 'Fixtures'),
                  _buildSubTabButton(MatchSubTab.results, 'result'),
                ],
              ),
            ),
          ),
          if (_showFilterButton)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HankLeagueFilterPage()),
                ).then((selectedIds) {
                  if (selectedIds is List<int>) {
                    setState(() {
                      _selectedCompetitionIds = selectedIds;
                    });
                    _fetchMatches(isRefresh: true);
                  }
                });
              },
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.violet200),
                ),
                child: const Icon(
                  Icons.filter_list,
                  size: 14,
                  color: AppColors.violet700,
                ),
              ),
            ),
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

  /// calendarbutton：tapafterbottompopupcalendarselectitemcard
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                    'selectDate',
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

  /// generatecomplete6dayDatelist
  /// Fixtures：anchorDateisstartpoint，toafterappend5day（anchorDate+5day）
  /// result：anchorDateisend point，tobeforeappend5day（before5day+anchorDate）
  /// anchorDateonlyincalendarselectitemcardConfirmwhenupdate，tapscrollitemno effectlist
  List<DateTime> _getDateList() {
    final List<DateTime> list = [];
    if (_currentSubTab == MatchSubTab.schedule) {
      // Fixtures：anchorDateisaeach，toafterappend5day
      for (int i = 0; i < 6; i++) {
        list.add(_anchorDate.add(Duration(days: i)));
      }
    } else {
      // result：anchorDateislastaeach，tobeforeappend5day
      for (int i = 5; i >= 0; i--) {
        list.add(_anchorDate.subtract(Duration(days: i)));
      }
    }
    return list;
  }

  /// checktwoeachDatewhethersameaday
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Datescrollitem：display6day，highlightwithcalendarselectlinkedanimation
  Widget _buildDateStrip() {
    final dates = _getDateList();
    final weekDays = ['Sun', 'a', 'second', 'three', 'Thu', 'Friday', 'Sat'];
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
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
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
                    isToday ? 'Today' : weekDays[d.weekday % 7],
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

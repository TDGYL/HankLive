import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_odds_model.dart';
import '../../models/hank_odds_history_model.dart';
import '../../services/hank_match_detail_api_service.dart';
import '../../widgets/match/match_detail_odds_tab.dart';

/// HankOddsHistoryPage: oddscounthistorypage
/// displaysomematchmatchsomebookmakerBookmakerhistoryOddschange
/// layoutmatchwithZogoLivedifferent：topHandicaptypeTab + oddsDBookmakerchipselectindicator + verticalTimeaxis card list
/// hometheme：lightpurple + whitecolor
/// API：GET /api/livespeed/football/match/odd-histories
class HankOddsHistoryPage extends StatefulWidget {
  /// matchID
  final int matchId;

  /// initial selectedbookmakerBookmaker
  final HankOddsCompany initialCompany;

  /// thehasbookmakerBookmakerlist
  final List<HankOddsCompany> allCompanies;

  /// initialHandicaptype
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
  /// DetailsAPI service
  final HankMatchDetailApiService _apiService = HankMatchDetailApiService();

  /// whenbeforeselectedbookmakerBookmakerID
  late String _selectedCompanyId;

  /// whenbeforeselectedHandicaptype
  late HankOddsMenuType _currentOddsType;

  /// whetherLoading
  bool _isLoading = true;

  /// historyOddsData
  HankOddsHistoryData? _historyData;

  /// Handicaptypemenuconfig（title + enum）
  static const _menuConfigs = <HankOddsMenuType, String>{
    HankOddsMenuType.asia: 'WL',
    HankOddsMenuType.eu: 'WDL',
    HankOddsMenuType.bs: 'totalGoals',
    HankOddsMenuType.cr: 'Corners',
  };

  /// header config（rootbased onHandicaptypeBackdifferent columntitle）
  List<String> _getHeaders() {
    switch (_currentOddsType) {
      case HankOddsMenuType.asia:
        return ['homeW', 'Handicap', 'awayW'];
      case HankOddsMenuType.eu:
        return ['homeW', 'Dmatch', 'awayW'];
      case HankOddsMenuType.bs:
        return ['over', 'Handicap', 'undergoal'];
      case HankOddsMenuType.cr:
        return ['over corner', 'Handicap', 'undercorner'];
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedCompanyId = widget.initialCompany.companyId ?? '';
    _currentOddsType = widget.initialOddsType;
    _fetchHistoryData();
  }

  /// requestoddscounthistoryData
  /// API：GET /api/livespeed/football/match/odd-histories
  /// paramcount：match_id, company_id
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

  /// getwhenbeforeHandicaptypemaps tohistorylist
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

  /// topnavbar（Backbutton + title）
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
            // Backbutton
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
            // title
            const Text(
              'oddscounthistory',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
            const Spacer(),
            // refreshbutton
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

  /// HandicaptypeTab（WL / WDL / totalGoals / Corners）
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

  /// bookmakerBookmakeroddsDchipselectindicator
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

  /// tableheaderrow（Time/score + three columnsOddstitle）
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
          // Time/score
          const SizedBox(
            width: 72,
            child: Text(
              'Time/score',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ),
          // three columnsOddstitle
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

  /// Timeaxislist（verticalcardstyleTimeaxis，leftwithconnectline）
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
          'NohistoryData',
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

  /// singleTimeaxiscard
  /// [item] historyOddsData
  /// [index] listindex
  /// [list] fulllist（usecalculaterisefall）
  Widget _buildTimelineCard(
      HankOddsHistoryItem item, int index, List<HankOddsHistoryItem> list) {
    // withupaitemmatchmatchcalculaterisefall
    final bool isLatest = index == 0;
    final bool hasNext = index < list.length - 1;

    // risefallcheck：withdownaitem（Timemoreearlier）matchmatch
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
          // leftTimeaxis track
          _buildTimelineTrack(item, isLatest, hasNext),
          const SizedBox(width: 8),
          // rightOddscard
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
                  // homeW/over
                  Expanded(
                    child: _buildValueWithTrend(
                      item.home,
                      homeChange,
                      true,
                    ),
                  ),
                  // Handicap/Dmatch
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
                  // awayW/undergoal
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

  /// leftTimeaxis track（dot + connectline + Timetag）
  /// [item] whenbeforehistoryData
  /// [isLatest] whetherLatestaitem
  /// [hasNext] whetherhasmoreearlierData
  Widget _buildTimelineTrack(
      HankOddsHistoryItem item, bool isLatest, bool hasNext) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          // upside connectionline（oddsdirectionmorelaterData）
          Container(
            width: 2,
            height: 12,
            color: isLatest ? Colors.transparent : AppColors.violet200,
          ),
          // dot
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
          // Timetag
          Text(
            item.matchOffset ?? 'open',
            style: TextStyle(
              fontSize: 11,
              fontWeight: isLatest ? FontWeight.w700 : FontWeight.w500,
              color: isLatest ? AppColors.violet700 : AppColors.slate500,
            ),
          ),
          const SizedBox(height: 2),
          // score
          Text(
            item.score ?? '0-0',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.slate500,
            ),
          ),
          // downside connectionline（pointing to earlierData）
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

  /// Oddsvalue + risefalltrend
  /// [value] Oddsvalue
  /// [change] risefalltype（1=rise, -1=fall, 0=unchanged）
  /// [isHome] whetherHomedirection
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

  /// matchcomparetwoeachOddsvalueO/U
  /// [current] whenbeforevalue
  /// [previous] upaeachvalue
  /// Back：1=rise, -1=fall, 0=unchangedornonemethodmatchcompare
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

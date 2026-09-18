import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_odds_model.dart';
import '../../pages/match/odds_history_page.dart';

/// HankOddsMenuType: Oddsmenuenum
/// asia: WL（AHhandicapgoal）| eu: WDL（1X2）| bs: totalGoals（O/Ugoal）| cr: Corners
enum HankOddsMenuType {
  /// WL（AHhandicapgoal）
  asia,
  /// WDL（1X2）
  eu,
  /// totalGoals（O/Ugoal）
  bs,
  /// Corners
  cr,
}

/// MatchDetailOddsTab: OddsTabcomponent
/// displaybookmakerBookmakerOddsData，menutoggleWL/WDL/totalGoals/Corners
/// useAPI /api/livespeed/football/match/odds BackData
/// lightpurple+whitecolorhomethemestyle，keepcurrenthascardUIstyle
class MatchDetailOddsTab extends StatefulWidget {
  /// oddscountData（contains asia/eu/bs/cr four typesHandicap）
  final HankOddsData? oddsData;

  /// whetherLoading
  final bool isLoading;

  /// matchID（usenavoddscounthistorypage）
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
  /// whenbeforeselectedmenu
  HankOddsMenuType _currentMenu = HankOddsMenuType.asia;

  /// menuconfig（title + maps tofield）
  static const _menuConfigs = <HankOddsMenuType, String>{
    HankOddsMenuType.asia: 'WL',
    HankOddsMenuType.eu: 'WDL',
    HankOddsMenuType.bs: 'totalGoals',
    HankOddsMenuType.cr: 'Corners',
  };

  /// header config（rootbased onmenutypeBackdifferent columntitle）
  List<String> _getHeaders() {
    switch (_currentMenu) {
      case HankOddsMenuType.asia:
        return ['bookmakerBookmaker', 'homeW', 'Handicap', 'awayW'];
      case HankOddsMenuType.eu:
        return ['bookmakerBookmaker', 'homeW', 'Dmatch', 'awayW'];
      case HankOddsMenuType.bs:
        return ['bookmakerBookmaker', 'over', 'Handicap', 'undergoal'];
      case HankOddsMenuType.cr:
        return ['bookmakerBookmaker', 'over corner', 'Handicap', 'undercorner'];
    }
  }

  /// getwhenbeforemenumaps toOddsBookmakerlist
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

  /// getmenutitle
  String _getMenuTitle() {
    switch (_currentMenu) {
      case HankOddsMenuType.asia:
        return 'handicapgoaloddscount (AH)';
      case HankOddsMenuType.eu:
        return '1X2oddscount (WDL)';
      case HankOddsMenuType.bs:
        return 'O/Ugoal (totalGoals)';
      case HankOddsMenuType.cr:
        return 'Cornersoddscount';
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

  /// menuselectindicator（WL / WDL / totalGoals / Corners）
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

  /// OddsDatacard
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
            'NooddscountData',
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
          // title
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
                'Livehandicap',
                style: TextStyle(fontSize: 10, color: AppColors.emerald500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // tableheader
          _buildTableHeader(_getHeaders()),
          // Datarow
          ...companies.map((company) => _buildCompanyRow(company)),
        ],
      ),
    );
  }

  /// bookmakerBookmakerDatarow
  /// displayBookmakername + Open/Pre/Live threephaseOdds
  /// tapnavoddscounthistorypage
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
            // Bookmakername
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
            // Oddsarea
            Expanded(
              child: Column(
                children: [
                  // OpeningOdds
                  _buildOddsRow(company.ini, AppColors.slate500, 'Opening'),
                  // livematchOdds
                  if (hasPre) ...[
                    const SizedBox(height: 8),
                    _buildOddsRow(company.pre, AppColors.blue500, 'livematch'),
                  ],
                  // LiveOdds
                  if (hasSpot) ...[
                    const SizedBox(height: 8),
                    _buildOddsRow(company.spot, AppColors.emerald500, 'Live'),
                  ],
                ],
              ),
            ),
            // arrow
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

  /// navigate tooddscounthistorypage
  /// [company] whenbeforetapbookmakerBookmaker
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

  /// single rowOdds（three columns：home / draw / away）
  Widget _buildOddsRow(HankOddsDetail? detail, Color color, String stageLabel) {
    return Row(
      children: [
        // phasetag
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
        // homeW/over
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
        // Dmatch/Handicap
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
        // awayW/undergoal
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

  /// tableheaderrow
  Widget _buildTableHeader(List<String> headers) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.violet50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Bookmakername list header
          const SizedBox(
            width: 70,
            child: Text(
              'Bookmaker',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ),
          // phasetagplaceholder
          const SizedBox(
            width: 36,
            child: Text(
              '',
              style: TextStyle(fontSize: 11),
            ),
          ),
          // threelistheader
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

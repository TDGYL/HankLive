import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_competition_filter_model.dart';
import '../../utils/hank_network_manager.dart';

/// HankLeagueFilterPage: Leaguefilterpage
/// feature：leftcategorytypemenu + rightLeaguelist（withcheckselect），supportallselect/invert/reset
/// API：GET /api/livespeed/football/competition-filter，paramcount tab=0
/// hometheme：lightpurple + whitecolor
/// reference leagueList.html layoutmatch，exclude top 5Leaguebutton
class HankLeagueFilterPage extends StatefulWidget {
  /// constructorfunctioncount
  const HankLeagueFilterPage({Key? key}) : super(key: key);

  @override
  State<HankLeagueFilterPage> createState() => _HankLeagueFilterPageState();
}

class _HankLeagueFilterPageState extends State<HankLeagueFilterPage> {
  /// categorytypelist（menuData）
  List<HankFilterCategory> _categories = [];

  /// whenbeforeselectedcategorytypeindex
  int _selectedCategoryIndex = 0;

  /// selectedinLeagueIDcollection
  final Set<int> _selectedIds = {};

  /// whetherLoading
  bool _isLoading = true;

  /// totalmatchmatchtime（selectedLeaguematchcounttotaland）
  int _totalMatches = 0;

  @override
  void initState() {
    super.initState();
    _fetchFilterData();
  }

  /// requestLeaguefilterData
  /// API：GET /api/livespeed/football/competition-filter
  /// paramcount：tab=0
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

  /// getwhenbeforecategorytypedownLeaguelist
  List<HankCompetition> get _currentCompetitions {
    if (_categories.isEmpty) return [];
    return _categories[_selectedCategoryIndex].competitions;
  }

  /// togglecategorytype
  /// [index] - itemmarkcategorytypeindex
  void _switchCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  /// toggleLeagueselectedstatus
  /// [competition] - Leagueentitybody
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

  /// allselectwhenbeforecategorytypedownthehasLeague
  void _selectAll() {
    setState(() {
      for (final c in _currentCompetitions) {
        _selectedIds.add(c.id);
      }
      _updateTotalMatches();
    });
  }

  /// invertwhenbeforecategorytypedownthehasLeague
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

  /// resetthehasselect
  void _resetSelection() {
    setState(() {
      _selectedIds.clear();
      _totalMatches = 0;
    });
  }

  /// updateselectedLeaguetotalmatchmatchtime
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

  /// getwhenbeforecategorytypedownselectedincountcount
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

  /// buildtopnavbar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: const Text('Leaguefilter',
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
          child: const Text('reset',
              style: TextStyle(fontSize: 13, color: AppColors.violet600)),
        ),
      ],
    );
  }

  /// buildactionbar（allselect、invert、selectedcountcount）
  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          _buildQuickButton('allselect', _selectAll),
          const SizedBox(width: 8),
          _buildQuickButton('invert', _invertSelection),
          const Spacer(),
          Text(
            'selected $_currentSelectedCount/${_currentCompetitions.length} item',
            style: const TextStyle(fontSize: 11, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  /// buildquickbutton（allselect/invert）
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

  /// buildhomebodycontent（leftmenu + rightLeaguelist）
  Widget _buildContentBody() {
    return Row(
      children: [
        _buildCategoryMenu(),
        Expanded(child: _buildCompetitionList()),
      ],
    );
  }

  /// buildleftcategorytypemenu
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

  /// buildrightLeaguelist
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

  /// buildsingleLeaguecard
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
            // Leaguelogo
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
            // Leaguename
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
                    '${competition.matches} matchmatch',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ),
            // checkselectfield
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

  /// buildlogoplaceholderimage
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

  /// buildemptystatusvisualimage
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 48, color: AppColors.slate400),
          const SizedBox(height: 8),
          const Text('NoLeagueData',
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
        ],
      ),
    );
  }

  /// buildbottomConfirmbar
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
                    const TextSpan(text: 'selected ',
                        style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                    TextSpan(text: '${_selectedIds.length}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                    const TextSpan(text: ' eachLeague',
                        style: TextStyle(fontSize: 11, color: AppColors.slate500)),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'covers ',
                        style: TextStyle(fontSize: 10, color: AppColors.slate400)),
                    TextSpan(text: '$_totalMatches',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: AppColors.violet600)),
                    const TextSpan(text: ' matchmatch',
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
              child: const Text('OK set',
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

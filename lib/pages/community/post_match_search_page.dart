import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_search_model.dart';
import '../../services/hank_search_api_service.dart';

/// HankPostMatchSearchPage: New PostlinkedmatchSearchpage
/// differentiatedlayoutmatch：lightpurple+whitecolorhometheme，cardstylematchlist，gradientSearchbar
/// feature：Searchmatch + Trendingmatchlist，tapBackselectedmatch
/// API：GET /api/livespeed/index/search，GET /api/livespeed/index/search/match/hot
class HankPostMatchSearchPage extends StatefulWidget {
  const HankPostMatchSearchPage({Key? key}) : super(key: key);

  @override
  _HankPostMatchSearchPageState createState() =>
      _HankPostMatchSearchPageState();
}

class _HankPostMatchSearchPageState extends State<HankPostMatchSearchPage> {
  /// SearchAPI service
  final HankSearchApiService _apiService = HankSearchApiService();

  /// Searchkeyword
  String _searchKeyword = '';

  /// Searchresult list
  List<HankSearchMatch> _searchMatches = [];

  /// Trendingmatchlist
  List<HankSearchMatch> _hotMatches = [];

  /// whetheractiveinSearch
  bool _isSearchLoading = false;

  /// whetherLoadingTrending
  bool _isHotLoading = true;

  /// Searchfieldcontroller
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHotMatches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// requestTrendingmatch
  /// API：GET /api/livespeed/index/search/match/hot
  Future<void> _fetchHotMatches() async {
    setState(() {
      _isHotLoading = true;
    });

    final result = await _apiService.fetchHotMatches();

    if (mounted) {
      setState(() {
        // filteronly keepFootballmatch（category=1）
        _hotMatches = result.where((m) => m.categoryId == 1).toList();
        _isHotLoading = false;
      });
    }
  }

  /// requestSearchresults
  /// API：GET /api/livespeed/index/search
  /// [keyword] - Searchkeyword
  Future<void> _fetchSearchData(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        _searchMatches = [];
      });
      return;
    }

    setState(() {
      _isSearchLoading = true;
    });

    final result = await _apiService.fetchSearchResults(text: keyword.trim());

    if (mounted) {
      setState(() {
        if (result != null) {
          // filteronly keepFootballmatch
          _searchMatches = result.matches
              .where((m) => m.categoryId == 1)
              .toList();
        } else {
          _searchMatches = [];
        }
        _isSearchLoading = false;
      });
    }
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
            _buildAppBar(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  /// topnavbar + Searchfield
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // navigate row
            SizedBox(
              height: 44,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.violet800,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'selectmatch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.violet900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Searchfield
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(19),
                border: Border.all(color: AppColors.violet200.withOpacity(0.5)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.slate700,
                ),
                textAlignVertical: TextAlignVertical.center,
                textInputAction: TextInputAction.search,
                onSubmitted: (val) {
                  _searchKeyword = val.trim();
                  _fetchSearchData(_searchKeyword);
                },
                decoration: const InputDecoration(
                  isCollapsed: true,
                  hintText: 'SearchTeamname...',
                  hintStyle: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.violet400,
                    size: 18,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  _searchKeyword = val;
                  if (val.isEmpty) {
                    setState(() {
                      _searchMatches = [];
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// homebodycontent
  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // Searchresultsarea
        if (_searchKeyword.trim().isNotEmpty) ...[
          _buildSectionHeader('Searchresults'),
          if (_isSearchLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
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
              ),
            )
          else if (_searchMatches.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'NoSearchresults',
                    style: TextStyle(color: AppColors.slate400, fontSize: 12),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, index) =>
                    _buildMatchCard(_searchMatches[index]),
                childCount: _searchMatches.length,
              ),
            ),
        ],

        // Trendingmatcharea
        _buildSectionHeader('Trendingmatch'),
        if (_isHotLoading)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
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
            ),
          )
        else if (_hotMatches.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'NoTrendingmatch',
                  style: TextStyle(color: AppColors.slate400, fontSize: 12),
                ),
              ),
            ),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, index) => _buildMatchCard(_hotMatches[index]),
              childCount: _hotMatches.length,
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  /// areatitle（sticky）
  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.violet600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// singlematchcard（differentiated：whitebottomroundedcard + purpleVStag）
  Widget _buildMatchCard(HankSearchMatch match) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, match),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.violet100, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A7C3AED),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Leaguename
            if (match.competitionName != null &&
                match.competitionName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 12, color: AppColors.violet400),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        match.competitionName!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.violet600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            // two sides
            Row(
              children: [
                // Home
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          match.homeTeamName ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildTeamLogo(match.homeTeamLogo, 28),
                    ],
                  ),
                ),
                // VS tag
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.violet500, AppColors.violet600],
                    ),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Away
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildTeamLogo(match.awayTeamLogo, 28),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          match.awayTeamName ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// TeamLogo
  Widget _buildTeamLogo(String? url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.violet50,
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.shield,
                  size: size * 0.5,
                  color: AppColors.violet300,
                ),
              )
            : Icon(
                Icons.shield,
                size: size * 0.5,
                color: AppColors.violet300,
              ),
      ),
    );
  }
}
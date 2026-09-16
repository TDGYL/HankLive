import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/hank_search_model.dart';
import '../../services/hank_search_api_service.dart';

/// HankPostMatchSearchPage: 发帖关联比赛搜索页面
/// 差异化布局：浅紫色+白色主题，卡片式比赛列表，渐变搜索栏
/// 功能：搜索比赛 + 热门比赛列表，点击返回选中的比赛
/// 接口：GET /api/livespeed/index/search，GET /api/livespeed/index/search/match/hot
class HankPostMatchSearchPage extends StatefulWidget {
  const HankPostMatchSearchPage({Key? key}) : super(key: key);

  @override
  _HankPostMatchSearchPageState createState() =>
      _HankPostMatchSearchPageState();
}

class _HankPostMatchSearchPageState extends State<HankPostMatchSearchPage> {
  /// 搜索接口服务
  final HankSearchApiService _apiService = HankSearchApiService();

  /// 搜索关键词
  String _searchKeyword = '';

  /// 搜索结果列表
  List<HankSearchMatch> _searchMatches = [];

  /// 热门比赛列表
  List<HankSearchMatch> _hotMatches = [];

  /// 是否正在搜索
  bool _isSearchLoading = false;

  /// 是否正在加载热门
  bool _isHotLoading = true;

  /// 搜索框控制器
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

  /// 请求热门比赛
  /// 接口：GET /api/livespeed/index/search/match/hot
  Future<void> _fetchHotMatches() async {
    setState(() {
      _isHotLoading = true;
    });

    final result = await _apiService.fetchHotMatches();

    if (mounted) {
      setState(() {
        // 过滤只保留足球比赛（category=1）
        _hotMatches = result.where((m) => m.categoryId == 1).toList();
        _isHotLoading = false;
      });
    }
  }

  /// 请求搜索结果
  /// 接口：GET /api/livespeed/index/search
  /// [keyword] - 搜索关键词
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
          // 过滤只保留足球比赛
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

  /// 顶部导航栏 + 搜索框
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
            // 导航行
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
                      '选择比赛',
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
            // 搜索框
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
                  hintText: '搜索球队名称...',
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

  /// 主体内容
  Widget _buildBody() {
    return CustomScrollView(
      slivers: [
        // 搜索结果区域
        if (_searchKeyword.trim().isNotEmpty) ...[
          _buildSectionHeader('搜索结果'),
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
                    '暂无搜索结果',
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

        // 热门比赛区域
        _buildSectionHeader('热门比赛'),
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
                  '暂无热门比赛',
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

  /// 区域标题（吸顶）
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

  /// 单条比赛卡片（差异化：白底圆角卡片 + 紫色VS标签）
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
            // 联赛名称
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
            // 对阵双方
            Row(
              children: [
                // 主队
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
                // VS 标签
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
                // 客队
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

  /// 球队Logo
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
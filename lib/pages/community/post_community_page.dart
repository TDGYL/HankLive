import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/match_model.dart';
import '../../models/hank_search_model.dart';
import '../../utils/hank_auth_manager.dart';
import '../../utils/hank_network_manager.dart';
import '../../widgets/common/hank_dotted_border_container.dart';
import 'post_match_search_page.dart';

/// HankPostCommunityPage: 发帖页面
/// 差异化布局：浅紫色+白色主题，圆角输入区，标签卡片选择
/// 功能：输入内容、选择战术标签、选择话题分类、关联比赛、发布帖子
/// 接口：POST /api/livespeed/community/save
/// 支持从外部传入 matchModel，传入时直接展示关联比赛
class HankPostCommunityPage extends StatefulWidget {
  /// 外部传入的比赛模型 - MatchModel?类型，传入时直接展示关联比赛
  final MatchModel? matchModel;

  HankPostCommunityPage({
    Key? key,
    this.matchModel,
  }) : super(key: key);

  @override
  _HankPostCommunityPageState createState() => _HankPostCommunityPageState();
}

class _HankPostCommunityPageState extends State<HankPostCommunityPage> {
  /// 内容输入控制器
  final TextEditingController _contentController = TextEditingController();

  /// 话题分类候选池（多选，可换一批）
  final List<String> _allTopics = [
    '赛事讨论',
    '战术分析',
    '转会动态',
    '装备评测',
    '冠军预测',
    '青训观察',
    '球迷故事',
    '赛事预测',
    '球员评测',
    '历史回顾',
    '规则解读',
    '联赛综述',
  ];

  /// 当前展示的话题分类（从候选池中取5个）
  List<String> _topics = [];

  /// 已选话题分类
  final List<String> _selectedTopics = [];

  /// 选中的比赛 - HankSearchMatch?类型，存储关联比赛信息
  HankSearchMatch? _selectedMatch;

  /// 是否正在发布
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    // 初始化展示前5个话题
    _topics = _allTopics.sublist(0, 5);
    // 如果外部传入了matchModel，转换并展示
    if (widget.matchModel != null) {
      final m = widget.matchModel!;
      _selectedMatch = HankSearchMatch(
        matchId: int.tryParse(m.matchId),
        competitionName: m.leagueName,
        homeTeamName: m.homeTeam.teamName,
        homeTeamLogo: m.homeTeam.logoUrl,
        awayTeamName: m.awayTeam.teamName,
        awayTeamLogo: m.awayTeam.logoUrl,
        homeTeamScore: m.homeScore,
        awayTeamScore: m.awayScore,
      );
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  /// 发布帖子
  /// 接口：POST /api/livespeed/community/save
  Future<void> _handlePublish() async {
    final textContent = _contentController.text.trim();
    if (textContent.length < 10) {
      _showToast('帖子内容至少10个字符');
      return;
    }

    // 话题分类存入 images 字段
    List<String> images = [];
    if (_selectedTopics.isNotEmpty) {
      images.add(_selectedTopics.join(','));
    }

    // 构建请求参数
    final Map<String, dynamic> params = {
      'id': 0,
      'content': textContent,
      'images': images,
    };

    // 若有关联比赛则追加比赛参数
    if (_selectedMatch != null && _selectedMatch!.matchId != null) {
      params['match_type'] = 1;
      params['match_id'] = _selectedMatch!.matchId;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final response = await HankNetworkManager().postRequest(
        '/api/livespeed/community/save',
        data: params,
      );

      if (response.isSuccess && mounted) {
        _showToast('发布成功');
        Navigator.pop(context, true);
      } else if (mounted) {
        _showToast(response.message ?? '发布失败');
      }
    } catch (e) {
      if (mounted) {
        _showToast('发布失败，请检查网络');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  /// 跳转到比赛搜索页面
  Future<void> _navigateToMatchSearch() async {
    final match = await Navigator.push<HankSearchMatch>(
      context,
      MaterialPageRoute(builder: (_) => const HankPostMatchSearchPage()),
    );
    if (match != null) {
      setState(() {
        _selectedMatch = match;
      });
    }
  }

  /// 换一批话题，从候选池中随机取5个未展示的
  void _shuffleTopics() {
    final available = _allTopics.where((t) => !_topics.contains(t)).toList();
    if (available.isEmpty) {
      // 全部展示过了，重置为前5个
      setState(() {
        _topics = _allTopics.sublist(0, 5);
      });
      return;
    }
    available.shuffle();
    final newTopics = available.take(5).toList();
    setState(() {
      _topics = newTopics;
    });
  }

  /// 显示Toast
  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildContentInput(),
                    const SizedBox(height: 16),
                    _buildMatchSection(),
                    const SizedBox(height: 16),
                    _buildTopicsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 顶部导航栏：取消 + 标题 + 发布按钮
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 44,
          child: Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '取消',
                  style: TextStyle(
                    color: AppColors.slate500,
                    fontSize: 14,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  '发帖',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet900,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 4),
                child: ElevatedButton.icon(
                  onPressed: _isPublishing ? null : _handlePublish,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.violet600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: _isPublishing
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send, size: 12),
                  label: Text(
                    _isPublishing ? '发布中' : '发布',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 用户信息栏：头像 + 昵称 + 公开提示
  Widget _buildUserHeader() {
    final user = HankAuthManager().currentUser;
    final userName = user?.nickname ?? '球友';
    final userAvatar = user?.avatar;

    return Row(
      children: [
        _buildAvatar(userAvatar, userName, 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: const [
                  Icon(Icons.public, size: 10, color: AppColors.slate400),
                  SizedBox(width: 4),
                  Text(
                    '公开 · HankLive社区',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 内容输入区域
  Widget _buildContentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet100, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A7C3AED),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _contentController,
        maxLines: 5,
        maxLength: 500,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: AppColors.slate700,
        ),
        decoration: const InputDecoration(
          hintText: '分享你的想法、战术分析或赛事讨论...',
          hintStyle: TextStyle(
            color: AppColors.slate400,
            fontSize: 14,
          ),
          border: InputBorder.none,
          counterText: '',
        ),
      ),
    );
  }

  /// 关联比赛区域
  Widget _buildMatchSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题行
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.sports_soccer,
                  size: 16, color: AppColors.violet500),
              const SizedBox(width: 4),
              const Text(
                '关联比赛',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.violet200, width: 0.5),
                ),
                child: const Text(
                  '选填',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.slate400,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 内容区
        if (_selectedMatch == null)
          _buildMatchSelector()
        else
          _buildSelectedMatchCard(),
      ],
    );
  }

  /// 未选择比赛时的选择卡片（虚线边框风格）
  Widget _buildMatchSelector() {
    return GestureDetector(
      onTap: _navigateToMatchSearch,
      behavior: HitTestBehavior.opaque,
      child: HankDottedBorderContainer(
        radius: 16,
        color: AppColors.violet300.withOpacity(0.6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.violet400, AppColors.violet600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '点击关联比赛',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '关联后帖子将展示比赛卡片',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 已选择比赛的展示卡片
  Widget _buildSelectedMatchCard() {
    final match = _selectedMatch!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.violet50, AppColors.violet100],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet200.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // 联赛名 + 操作按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  match.competitionName ?? '',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.violet600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMatch = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.rose500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: AppColors.rose500),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          // 对阵双方
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildTeamLogo(match.homeTeamLogo, 36),
                    const SizedBox(height: 6),
                    Text(
                      match.homeTeamName ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x147C3AED),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.violet700,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildTeamLogo(match.awayTeamLogo, 36),
                    const SizedBox(height: 6),
                    Text(
                      match.awayTeamName ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 话题分类区域（多选，可换一批）
  Widget _buildTopicsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.violet100, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '添加话题',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate700,
                ),
              ),
              GestureDetector(
                onTap: _shuffleTopics,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: const [
                    Icon(Icons.refresh, size: 12, color: AppColors.violet500),
                    SizedBox(width: 3),
                    Text(
                      '换一批',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.violet500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _topics.map((topic) {
              final isSelected = _selectedTopics.contains(topic);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTopics.remove(topic);
                    } else {
                      _selectedTopics.add(topic);
                    }
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [AppColors.violet500, AppColors.violet600],
                          )
                        : null,
                    color: isSelected ? null : AppColors.violet50,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? null
                        : Border.all(color: AppColors.violet200),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.violet600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 构建头像组件
  /// [url] - 头像URL
  /// [name] - 昵称（用于生成默认头像）
  /// [size] - 头像尺寸
  Widget _buildAvatar(String? url, String name, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.violet300.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(name, size),
              )
            : _buildDefaultAvatar(name, size),
      ),
    );
  }

  /// 默认头像（首字母）
  Widget _buildDefaultAvatar(String name, double size) {
    final initial = name.isNotEmpty ? name.characters.first : '?';
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.violet400, AppColors.violet600],
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
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
        color: Colors.white,
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

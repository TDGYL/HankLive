import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/post_model.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/community/post_card.dart';

/// CommunityPage: 球友社区页面
/// 包含话题标签水平滚动条、发帖按钮、帖子卡片（内嵌比赛卡片+点赞交互）
class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  /// 当前选中的话题索引（0是热门讨论）
  int _selectedTopicIndex = 0;

  /// 话题标签数据
  late List<Map<String, dynamic>> _topics;

  /// 帖子数据
  late List<PostModel> _posts;

  @override
  void initState() {
    super.initState();
    _topics = MockDataService.getCommunityTopics();
    _posts = MockDataService.getPostList();
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: _buildPostCards(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  '球友社区',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.violet900,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('打开发帖编辑器'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.violet600,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x307C3AED),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          Icons.add,
                          size: 14,
                          color: Colors.white,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '发帖',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _topics.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (ctx, idx) {
                  final item = _topics[idx];
                  final isSelected = idx == _selectedTopicIndex;
                  final isHot = item['isHot'] == true;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTopicIndex = idx;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHot || isSelected
                            ? AppColors.violet600
                            : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isHot || isSelected
                              ? Colors.transparent
                              : AppColors.violet200,
                        ),
                        boxShadow: isHot || isSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x307C3AED),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        item['name'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isHot || isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isHot || isSelected
                              ? Colors.white
                              : AppColors.violet900,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPostCards() {
    final List<Widget> out = [];
    for (int i = 0; i < _posts.length; i++) {
      out.add(PostCard(
        post: _posts[i],
        onFollowTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('已关注该球友: ${_posts[i].userName}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onCommentTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('评论区展开'),
              duration: Duration(seconds: 1),
            ),
          );
        },
        onShareTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('分享成功'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ));
      if (i != _posts.length - 1) {
        out.add(const SizedBox(height: 16));
      }
    }
    return out;
  }
}

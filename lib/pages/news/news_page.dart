import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/news_model.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/news/feature_news_card.dart';
import '../../widgets/news/compact_news_card.dart';

/// NewsCategory: 资讯分类枚举
/// tactics: 深度战术 | newsflash: 快讯
enum NewsCategory { tactics, newsflash }

/// NewsPage: 绿荫资讯页面
/// 顶部两种分类切换，列表混合展示 Feature 大图卡片和 Compact 左右结构卡片
class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  /// 当前选中的分类
  NewsCategory _currentCategory = NewsCategory.tactics;

  /// 资讯数据列表
  late List<NewsModel> _newsList;

  @override
  void initState() {
    super.initState();
    _newsList = MockDataService.getNewsList();
  }

  void _switchCategory(NewsCategory c) {
    setState(() {
      _currentCategory = c;
    });
  }

  List<NewsModel> _getFilteredList() {
    // 此处展示全部资讯，两种分类仅切换顶部高亮
    return _newsList;
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
                  children: _buildNewsCards(),
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.violet100.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(color: Color(0x80DDD6FE), width: 0.5),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Text(
              '绿荫资讯',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.violet900,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                _buildCategoryPill(
                  label: '深度战术',
                  isSelected: _currentCategory == NewsCategory.tactics,
                  onTap: () => _switchCategory(NewsCategory.tactics),
                ),
                const SizedBox(width: 8),
                _buildCategoryPill(
                  label: '快讯',
                  isSelected: _currentCategory == NewsCategory.newsflash,
                  onTap: () => _switchCategory(NewsCategory.newsflash),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet600 : Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
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
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.slate500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNewsCards() {
    final list = _getFilteredList();
    final List<Widget> out = [];
    for (int i = 0; i < list.length; i++) {
      final n = list[i];
      if (n.type == NewsType.feature) {
        out.add(FeatureNewsCard(
          news: n,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('阅读战术深度文章'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ));
      } else {
        out.add(CompactNewsCard(
          news: n,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('阅读资讯：${n.title.substring(0, n.title.length > 10 ? 10 : n.title.length)}...'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ));
      }
      if (i != list.length - 1) {
        out.add(const SizedBox(height: 16));
      }
    }
    return out;
  }
}

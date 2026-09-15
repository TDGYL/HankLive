import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../models/news_model.dart';

/// CompactNewsCard: 左右结构高密度图文快讯卡片
class CompactNewsCard extends StatelessWidget {
  /// 资讯数据
  final NewsModel news;

  /// 点击回调
  final VoidCallback? onTap;

  CompactNewsCard({
    Key? key,
    required this.news,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.glassWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.violet100, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A7C3AED),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(news.categoryBgColor),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news.categoryTag,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(news.categoryTextColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        news.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        news.source,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.comment_outlined,
                            size: 12,
                            color: AppColors.violet500,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${news.commentCount}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 80,
                child: news.thumbnailUrl != null
                    ? Image.network(
                        news.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackThumb(),
                      )
                    : _buildFallbackThumb(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackThumb() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFEDE9FE),
            Color(0xFFDDD6FE),
          ],
        ),
      ),
      child: const Icon(
        Icons.newspaper,
        color: Color(0x668B5CF6),
        size: 32,
      ),
    );
  }
}

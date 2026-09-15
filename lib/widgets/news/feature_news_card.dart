import 'package:flutter/material.dart';
import '../../models/news_model.dart';

/// FeatureNewsCard: 大图深度战术文章卡片
/// 全铺式渐变背景图+覆盖文字的样式
class FeatureNewsCard extends StatelessWidget {
  /// 资讯数据
  final NewsModel news;

  /// 点击回调
  final VoidCallback? onTap;

  FeatureNewsCard({
    Key? key,
    required this.news,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFDDD6FE).withOpacity(0.6),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x200F172A),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            SizedBox(
              width: double.infinity,
              height: 192,
              child: news.coverImageUrl != null
                  ? Image.network(
                      news.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildFallbackBg(),
                    )
                  : _buildFallbackBg(),
            ),
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x660F172A),
                      Color(0xFF020617),
                    ],
                    stops: [0.2, 0.55, 1.0],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(news.categoryBgColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        news.categoryTag,
                        style: TextStyle(
                          fontSize: 9,
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
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.edit_note,
                              size: 12,
                              color: Color(0xFFA78BFA),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              news.timeDesc,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFC4B5FD),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${news.timeDesc}${news.readCountDesc.isNotEmpty ? ' · ${news.readCountDesc}' : ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFC4B5FD),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4C1D95),
            Color(0xFF312E81),
            Color(0xFF1E1B4B),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.newspaper,
          color: Color(0x66A78BFA),
          size: 48,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// AppTabItem: 底部Tab项数据模型
class AppTabItem {
  /// 图标
  final IconData icon;

  /// 选中时图标颜色
  final Color activeColor;

  /// 标题文字
  final String label;

  AppTabItem({
    required this.icon,
    required this.activeColor,
    required this.label,
  });
}

/// AppBottomNavBar: 底部导航栏
/// 毛玻璃半透明效果，4个Tab切换
class AppBottomNavBar extends StatelessWidget {
  /// 当前选中索引
  final int currentIndex;

  /// Tab项列表
  final List<AppTabItem> items;

  /// 切换回调
  final ValueChanged<int> onTabChanged;

  AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.items,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        border: const Border(
          top: BorderSide(color: Color(0xCCDDD6FE), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet900.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              final color =
                  isActive ? item.activeColor : const Color(0xFF94A3B8);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabChanged(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: color,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

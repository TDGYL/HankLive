import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// AppTabItem: bottomTabitemDatamodel
class AppTabItem {
  /// icon
  final IconData icon;

  /// selectedwheniconcolor
  final Color activeColor;

  /// titletext
  final String label;

  AppTabItem({
    required this.icon,
    required this.activeColor,
    required this.label,
  });
}

/// AppBottomNavBar: bottomnavbar
/// frosted glasstranslucent effect，4eachTabtoggle
class AppBottomNavBar extends StatelessWidget {
  /// whenbeforeselectedindex
  final int currentIndex;

  /// Tabitem list
  final List<AppTabItem> items;

  /// togglecallback
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

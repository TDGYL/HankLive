import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/mock_data_service.dart';

/// SearchModal: allmatchSearchpopup
/// displaySearchfield、TrendingSearchkeyword
class SearchModal extends StatefulWidget {
  /// Searchkeywordselectedcallback
  final ValueChanged<String>? onKeywordSelected;

  SearchModal({
    Key? key,
    this.onKeywordSelected,
  }) : super(key: key);

  @override
  _SearchModalState createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  /// textinputcontroller
  late final TextEditingController _controller;

  /// TrendingSearchkeyword
  late final List<String> _hotSearches;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _hotSearches = MockDataService.getHotSearches();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onKeywordTap(String keyword) {
    widget.onKeywordSelected?.call(keyword);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('filter: $keyword'),
        duration: const Duration(seconds: 1),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: const Color(0xD9020617),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.violet400.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 14,
                            color: Color(0xFFC4B5FD),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              cursorColor: AppColors.violet300,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintText: 'SearchTeam/League (e.g.: Arsenal, Real Madrid...)',
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: Color(0x99C4B5FD),
                                ),
                              ),
                              onSubmitted: (v) {
                                if (v.trim().isNotEmpty) {
                                  _onKeywordTap(v.trim());
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC4B5FD),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'TrendingSearch',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC4B5FD),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _hotSearches
                    .map(
                      (kw) => GestureDetector(
                        onTap: () => _onKeywordTap(kw),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.violet900.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppColors.violet500.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            kw,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFFEDE9FE),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

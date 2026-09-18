import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// CalendarBottomSheet: calendarselectbottompopup
/// rootbased onpassed inDaterange constraint，limitoptionalDate
class CalendarBottomSheet extends StatefulWidget {
  /// calendartitle
  final String title;

  /// initial selectedDate
  final DateTime initialDate;

  /// mostunderoptionalDate
  final DateTime firstDate;

  /// mostbigoptionalDate
  final DateTime lastDate;

  CalendarBottomSheet({
    Key? key,
    required this.title,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  }) : super(key: key);

  /// popupcalendarbottompopup，BackselectedDate（CancelthenBacknull）
  static Future<DateTime?> show(
    BuildContext context, {
    required String title,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      builder: (_) => CalendarBottomSheet(
        title: title,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  _CalendarBottomSheetState createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<CalendarBottomSheet> {
  /// whenbeforeselectedDate
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // topdragitem
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.violet200,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          // titlerow
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: AppColors.violet600,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate900,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          // calendarcomponent
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: AppColors.violet600,
                    onPrimary: Colors.white,
                    surface: AppColors.violet50,
                    onSurface: AppColors.slate800,
                  ),
            ),
            child: CalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
          // bottomConfirmbutton
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selectedDate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.violet600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Confirmselect',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

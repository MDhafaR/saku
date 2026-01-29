import 'package:flutter/material.dart';

class TimePeriodSelector extends StatefulWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;
  final Function(DateTimeRange)? onCustomDateSelected;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.onCustomDateSelected,
  });

  @override
  State<TimePeriodSelector> createState() => _TimePeriodSelectorState();
}

class _TimePeriodSelectorState extends State<TimePeriodSelector> {
  final List<String> periods = ['All', 'Daily', 'Monthly', 'Yearly', 'Custom'];

  Future<void> _showDateRangePicker() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 30)),
        end: now,
      ),
      initialEntryMode: DatePickerEntryMode.input, // Shows compact dialog first
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF111111),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111111),
            ),
          ),
          child: child!,
        );
      },
    );

    if (result != null && widget.onCustomDateSelected != null) {
      widget.onCustomDateSelected!(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = periods.indexOf(widget.selectedPeriod);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(30),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / periods.length;

          return Stack(
            children: [
              // Sliding indicator
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: (selectedIndex >= 0 ? selectedIndex : 0) * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              // Tab labels
              Row(
                children: periods.map((period) {
                  final isSelected = widget.selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        widget.onPeriodChanged(period);
                        if (period == 'Custom') {
                          _showDateRangePicker();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 4,
                        ),
                        child: Text(
                          period,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected
                                ? const Color(0xFF111111)
                                : const Color(0xFF9CA3AF),
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final periods = ['Daily', 'Monthly', 'Yearly', 'Custom'];

    return Row(
      children: periods.map((period) {
        final isSelected = period == selectedPeriod;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: () => onPeriodChanged(period),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.purple[600]
                    : Colors.grey[800],
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                period,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

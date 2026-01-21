import 'package:flutter/material.dart';
import '../../../../core/presentation/components/saku_card.dart';

class ExpenseComparisonChart extends StatelessWidget {
  const ExpenseComparisonChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SakuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Komparasi Pengeluaran',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow('Makan', 850, 0.7, const Color(0xFFF59E0B)),
          const SizedBox(height: 12),
          _buildComparisonRow('Transport', 620, 0.5, const Color(0xFF2563EB)),
          const SizedBox(height: 12),
          _buildComparisonRow('Belanja', 450, 0.35, const Color(0xFFE91E63)),
          const SizedBox(height: 12),
          _buildComparisonRow('Lainnya', 200, 0.15, const Color(0xFF9CA3AF)),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    int amount,
    double percentage,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '\$$amount',
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111111),
            ),
          ),
        ),
      ],
    );
  }
}

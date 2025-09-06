import 'package:flutter/material.dart';

class ChartPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final String? actionText;
  final VoidCallback? onActionTap;
  final List<Widget>? headerActions;

  const ChartPanel({
    super.key,
    required this.title,
    required this.child,
    this.actionText,
    this.onActionTap,
    this.headerActions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (headerActions != null) ...headerActions!,
              if (actionText != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

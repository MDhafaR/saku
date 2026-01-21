import 'package:flutter/material.dart';

class CustomNumpad extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onDelete;
  final VoidCallback onSubmit;
  final Color? submitColor;

  const CustomNumpad({
    super.key,
    required this.onKeyPressed,
    required this.onDelete,
    required this.onSubmit,
    this.submitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Avoid expanded if not needed
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(context, '1'),
            _buildNumberButton(context, '2'),
            _buildNumberButton(context, '3'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(context, '4'),
            _buildNumberButton(context, '5'),
            _buildNumberButton(context, '6'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(context, '7'),
            _buildNumberButton(context, '8'),
            _buildNumberButton(context, '9'),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildButton(
              context: context,
              child: Text(
                '000',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => onKeyPressed('000'),
            ),
            _buildNumberButton(context, '0'),
            _buildButton(
              context: context,
              child: Icon(
                Icons.backspace_outlined,
                color: Theme.of(context).iconTheme.color,
                size: 24,
              ),
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, String value) {
    return _buildButton(
      context: context,
      child: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: () => onKeyPressed(value),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 64, // Fixed width for consistency
      height: 48,
      alignment: Alignment.center,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 64,
          height: 48,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

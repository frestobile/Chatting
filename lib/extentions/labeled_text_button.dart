import 'package:flutter/material.dart';
import 'package:ainaglam/extentions/context.dart';

class LabeledTextButton extends StatelessWidget {
  const LabeledTextButton({
    required this.label,
    required this.action,
    required this.onTap,
    required this.style,
    super.key,
  });

  final String label;
  final String action;
  final VoidCallback onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '$label ',
          style: context.textTheme.labelMedium,
          children: [
            TextSpan(
              text: action,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

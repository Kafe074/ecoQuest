import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_theme.dart';

/// Compact, modern answer tile shared by the quiz and the impact simulator:
/// a slim white card with a small letter/icon chip, dense text and a subtle
/// caret. Deliberately lighter than the chunky clay surfaces so a list of
/// 3-4 options fits on screen without scrolling.
class OptionTile extends StatelessWidget {
  const OptionTile({
    super.key,
    required this.color,
    required this.label,
    required this.onTap,
    this.leadingText,
    this.leadingIcon,
  }) : assert(leadingText != null || leadingIcon != null,
            'Provide leadingText or leadingIcon');

  final Color color;
  final String label;
  final VoidCallback onTap;

  /// Short chip content, e.g. 'A', 'B', 'C'.
  final String? leadingText;

  /// Alternative chip icon when there is no letter.
  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.10),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: color.withValues(alpha: 0.12),
          highlightColor: color.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: leadingText != null
                      ? Text(
                          leadingText!,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.darken(color, 0.2),
                          ),
                        )
                      : PhosphorIcon(
                          leadingIcon!,
                          size: 14,
                          color: AppTheme.darken(color, 0.2),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                PhosphorIcon(
                  PhosphorIconsBold.caretRight,
                  size: 13,
                  color: color.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

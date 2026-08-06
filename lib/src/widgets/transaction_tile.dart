import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
              border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
            ),
            child: Icon(transaction.icon, color: transaction.iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                const SizedBox(height: 4),
                Text(transaction.subtitle,
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(transaction.formattedAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: transaction.type == TransactionType.income
                        ? const Color(0xFF0F7B52)
                        : const Color(0xFFEA5F5F),
                  )),
              const SizedBox(height: 4),
              Text(transaction.dateLabel,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

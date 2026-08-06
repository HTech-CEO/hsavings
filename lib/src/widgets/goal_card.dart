import 'package:flutter/material.dart';
import '../models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final SavingGoal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11151D) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Meta em andamento',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              Text('Ver todas', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          Text(goal.title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
          const SizedBox(height: 8),
          Text(goal.targetLabel, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 14,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 14,
                    width: constraints.maxWidth * goal.progress,
                    decoration: BoxDecoration(
                      color: goal.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goal.progressLabel, style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
              Icon(Icons.arrow_forward_ios, size: 18, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ],
      ),
    );
  }
}

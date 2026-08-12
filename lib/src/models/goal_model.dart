import 'package:flutter/material.dart';

class SavingGoal {
  final String title;
  final double collected;
  final double target;
  final Color color;

  const SavingGoal({
    required this.title,
    required this.collected,
    required this.target,
    required this.color,
  });

  double get progress => (collected / target).clamp(0, 1);
  String get progressLabel => '${(progress * 100).round()}%';
  String get targetLabel => '€${collected.toStringAsFixed(0)} / €${target.toStringAsFixed(0)}';
}

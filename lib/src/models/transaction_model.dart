import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionModel {
  final String title;
  final String subtitle;
  final double amount;
  final String dateLabel;
  final TransactionType type;
  final IconData icon;
  final Color iconColor;

  const TransactionModel({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateLabel,
    required this.type,
    required this.icon,
    required this.iconColor,
  });

  String get formattedAmount {
    return '${type == TransactionType.income ? '+' : '-'}R\$${amount.toStringAsFixed(2)}';
  }
}

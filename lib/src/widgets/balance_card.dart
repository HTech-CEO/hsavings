import 'dart:ui';

import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double monthlyChange;
  final VoidCallback onMorePressed;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthlyChange,
    required this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF174380);
    const onPrimary = Colors.white;
    final theme = Theme.of(context);
    final balanceColor = monthlyChange > 0 ? Color.fromARGB(255, 5, 141, 75) : Color(0xFFEA5F5F);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0x2E),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: onPrimary.withValues(alpha: 0x3D)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(255, 255, 255, 0.24),
                Color.fromRGBO(255, 255, 255, 0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Saldo total',
                      style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.w500)),
                  Material(
                    color: Color.fromRGBO(255, 255, 255, 0.24),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onMorePressed,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Icon(Icons.more_horiz, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('€ ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_upward, color: balanceColor, size: 16),
                  const SizedBox(width: 5),
                  Text('+${monthlyChange.toStringAsFixed(1)}%',
                      style: TextStyle(color: balanceColor, fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(width: 6),
                  const Text('vs mês anterior', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

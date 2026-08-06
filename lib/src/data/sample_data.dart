import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../models/transaction_model.dart';

const totalBalance = 8642.19;
const monthlyGrowth = 12.5;
const monthlyIncome = 12750.0;
const monthlyExpense = 4107.81;

const recentGoal = SavingGoal(
  title: 'Viagem dos sonhos',
  collected: 6000,
  target: 10000,
  color: Color(0xFF174380),
);

final recentTransactions = <TransactionModel>[
  const TransactionModel(
    title: 'Supermercado Extra',
    subtitle: 'Alimentação',
    amount: 198.75,
    dateLabel: 'Hoje',
    type: TransactionType.expense,
    icon: Icons.shopping_cart_outlined,
    iconColor: Color(0xFF36B37E),
  ),
  const TransactionModel(
    title: 'Salário',
    subtitle: 'Receita',
    amount: 7250.0,
    dateLabel: 'Ontem',
    type: TransactionType.income,
    icon: Icons.attach_money_rounded,
    iconColor: Color(0xFF0F7B52),
  ),
  const TransactionModel(
    title: 'Posto Ipiranga',
    subtitle: 'Transporte',
    amount: 150.0,
    dateLabel: 'Ontem',
    type: TransactionType.expense,
    icon: Icons.local_gas_station_outlined,
    iconColor: Color(0xFFF08A5D),
  ),
];

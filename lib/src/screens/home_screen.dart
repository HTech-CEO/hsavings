import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/sample_data.dart';
import '../widgets/action_button.dart';
import '../widgets/balance_card.dart';
import '../widgets/goal_card.dart';
import '../widgets/transaction_tile.dart';
import 'financial_plan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int selectedIndex = 0;

  late final AnimationController _headerController;
  late final Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _onNavigationTap(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: isDark ? const Color(0xFF11151D) : Colors.white,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: selectedIndex == 2
          ? const FinancialPlanScreen()
          : Container(
              color: const Color(0xFF174380),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF174380),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                        child: FadeTransition(
                          opacity: _headerAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('Olá, Gabriel 👋',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            )),
                                        SizedBox(height: 4),
                                        Text('Que bom te ver por aqui!',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Color(0xCCFFFFFF),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=256&q=80'),
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0xEB), width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0x14),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              BalanceCard(
                                balance: totalBalance,
                                monthlyChange: monthlyGrowth,
                                onMorePressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TweenAnimationBuilder<Offset>(
                        duration: const Duration(milliseconds: 700),
                        tween: Tween(begin: const Offset(0, 0.05), end: Offset.zero),
                        builder: (context, offset, child) {
                          return Transform.translate(
                            offset: offset * 100,
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 140),
                              children: [
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    ActionButton(icon: Icons.add, label: 'Receita', color: Color.fromARGB(255, 5, 141, 75)),
                                    ActionButton(icon: Icons.receipt_long_outlined, label: 'Despesa', color: Color(0xFFEA5F5F)),
                                    ActionButton(icon: Icons.savings, label: 'Poupar', color: Color(0xFF007BFF)),
                                    ActionButton(icon: Icons.account_balance_wallet, label: 'Investir', color: Color.fromARGB(255, 95, 5, 241)),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                _buildOverviewCard(theme),
                                const SizedBox(height: 18),
                                _buildRecentTransactions(theme),
                                const SizedBox(height: 18),
                                GoalCard(goal: recentGoal),
                                const SizedBox(height: 96),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigation(theme),
    );
  }

  Widget _buildOverviewCard(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
        color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Visão geral', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.onSurface)),
              Text('Este mês', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _OverviewItem(
                label: 'Receitas',
                value: '€ 12.750,00',
                color: const Color.fromARGB(255, 5, 141, 75),
                onTap: () {},
              ),
              const SizedBox(width: 18),
              _OverviewItem(
                label: 'Despesas',
                value: '€ 4.107,81',
                color: const Color(0xFFEA5F5F),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _OverviewItem(
                label: 'Poupanças',
                value: '€ 12.750,00',
                color: Color(0xFF007BFF),
                onTap: () {},
              ),
              const SizedBox(width: 18),
              _OverviewItem(
                label: 'Investimentos',
                value: '€ 4.107,81',
                color: Color.fromARGB(255, 95, 5, 241),
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Saldo do mês', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('€ 8.642,19', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [theme.colorScheme.primary.withValues(alpha: 0.16), theme.colorScheme.primary.withValues(alpha: 0.06)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: Text('Gráfico de ganho mensal', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.show_chart, color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
        color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Transações recentes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: theme.colorScheme.onSurface)),
              GestureDetector(
                onTap: () {},
                child: Text('Ver todas', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...recentTransactions.map(
            (transaction) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TransactionTile(transaction: transaction),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    final items = const [
      _NavigationItem(label: 'Início', icon: Icons.home),
      _NavigationItem(label: 'Resumo', icon: Icons.insert_chart_outlined),
      _NavigationItem(label: 'Plano', icon: Icons.pie_chart_outline),
      _NavigationItem(label: 'Menu', icon: Icons.menu),
    ];

    final bottomInset = MediaQuery.of(context).padding.bottom;

    final nav = Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        boxShadow: [BoxShadow(color: theme.colorScheme.shadow.withValues(alpha: 0x14), blurRadius: 18, offset: const Offset(0, -4))],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, top: 6, bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => _onNavigationTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, size: 22, color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );

    final filler = Container(
      height: bottomInset,
      color: isDark ? const Color(0xFF11151D) : Colors.white,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [nav, filler],
    );
  }
}

class _OverviewItem extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _OverviewItem({
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  State<_OverviewItem> createState() => _OverviewItemState();
}

class _OverviewItemState extends State<_OverviewItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 120),
      value: 1.0,
      lowerBound: 0.94,
      upperBound: 1.0,
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _scaleAnimation = curved;
    _shadowAnimation = Tween<double>(begin: 2, end: 10).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    try {
      await _controller.animateTo(0.94);
      await _controller.animateTo(1.0);
    } finally {
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _shadowAnimation,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
                  gradient: LinearGradient(
                    colors: [widget.color.withValues(alpha: 0.16), theme.colorScheme.primary.withValues(alpha: 0.06)],
                  ),
                ),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.label, style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.88), fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 10),
                Text(widget.value, style: TextStyle(color: widget.color.withValues(alpha: 0x1F), fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  final String label;
  final IconData icon;

  const _NavigationItem({required this.label, required this.icon});
}
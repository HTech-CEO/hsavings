import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum PlanGroupType { income, investment, saving, fixedExpense, variableExpense }

class PlanCategoryTemplate {
  final String id;
  final String label;
  final IconData icon;
  final Color color;

  const PlanCategoryTemplate({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class PlanLine {
  final String id;
  String templateId;
  String label;
  IconData icon;
  Color color;
  double amount;

  PlanLine({
    required this.id,
    required this.templateId,
    required this.label,
    required this.icon,
    required this.color,
    required this.amount,
  });
}

class FinancialPlanScreen extends StatefulWidget {
  const FinancialPlanScreen({super.key});

  @override
  State<FinancialPlanScreen> createState() => _FinancialPlanScreenState();
}

class _FinancialPlanScreenState extends State<FinancialPlanScreen>
    with TickerProviderStateMixin {
  final double monthlyIncome = 12750.0;

  final Map<PlanGroupType, List<PlanLine>> _lines = {
    PlanGroupType.income: [],
    PlanGroupType.investment: [],
    PlanGroupType.saving: [],
    PlanGroupType.fixedExpense: [],
    PlanGroupType.variableExpense: [],
  };

  late final AnimationController _chartController;
  late final Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _chartAnimation = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  List<PlanCategoryTemplate> _templatesFor(PlanGroupType group) {
    switch (group) {
      case PlanGroupType.income:
        return const [
          PlanCategoryTemplate(id: 'salary', label: 'Salário', icon: Icons.work_outline_rounded, color: Color(0xFF14B87A)),
          PlanCategoryTemplate(id: 'freelance', label: 'Freelance', icon: Icons.computer_outlined, color: Color(0xFF3BC9A4)),
          PlanCategoryTemplate(id: 'rental', label: 'Renda', icon: Icons.real_estate_agent_outlined, color: Color(0xFF4F9DFF)),
          PlanCategoryTemplate(id: 'bonus', label: 'Bônus', icon: Icons.auto_awesome_outlined, color: Color(0xFFFFB84D)),
        ];
      case PlanGroupType.investment:
        return const [
          PlanCategoryTemplate(id: 'etf', label: 'ETF', icon: Icons.trending_up_rounded, color: Color(0xFF7C4DFF)),
          PlanCategoryTemplate(id: 'stocks', label: 'Ações', icon: Icons.bar_chart_rounded, color: Color(0xFF5E6BFF)),
          PlanCategoryTemplate(id: 'crypto', label: 'Cripto', icon: Icons.currency_bitcoin_rounded, color: Color(0xFFF5A623)),
          PlanCategoryTemplate(id: 'ppr', label: 'PPR', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF00B8D9)),
          PlanCategoryTemplate(id: 'certificado', label: 'Cert. de Aforro', icon: Icons.savings_rounded, color: Color(0xFF00A36C)),
        ];
      case PlanGroupType.saving:
        return const [
          PlanCategoryTemplate(id: 'saving', label: 'Poupança', icon: Icons.savings_rounded, color: Color(0xFF1A73E8)),
          PlanCategoryTemplate(id: 'emergency', label: 'Fundo de emergência', icon: Icons.shield_outlined, color: Color(0xFF00BFA5)),
        ];
      case PlanGroupType.fixedExpense:
        return const [
          PlanCategoryTemplate(id: 'rent_house', label: 'Aluguel', icon: Icons.home_rounded, color: Color(0xFFEA4F5D)),
          PlanCategoryTemplate(id: 'utilities', label: 'Internet / Luz', icon: Icons.lightbulb_outline_rounded, color: Color(0xFFF7956A)),
          PlanCategoryTemplate(id: 'insurance', label: 'Seguros', icon: Icons.security_rounded, color: Color(0xFF9B5DE5)),
          PlanCategoryTemplate(id: 'loan', label: 'Empréstimo', icon: Icons.payments_rounded, color: Color(0xFFDB4D87)),
          PlanCategoryTemplate(id: 'subscriptions', label: 'Assinaturas', icon: Icons.subscriptions_rounded, color: Color(0xFF5F7AFF)),
          PlanCategoryTemplate(id: 'transport_fix', label: 'Transporte fixo', icon: Icons.directions_car_rounded, color: Color(0xFFFF8A65)),
        ];
      case PlanGroupType.variableExpense:
        return const [
          PlanCategoryTemplate(id: 'food', label: 'Alimentação', icon: Icons.restaurant_rounded, color: Color(0xFFF26A6A)),
          PlanCategoryTemplate(id: 'leisure', label: 'Lazer', icon: Icons.movie_filter_rounded, color: Color(0xFFFFC857)),
          PlanCategoryTemplate(id: 'shopping', label: 'Compras', icon: Icons.shopping_bag_rounded, color: Color(0xFFB98BFF)),
          PlanCategoryTemplate(id: 'health', label: 'Saúde', icon: Icons.medical_services_outlined, color: Color(0xFF6ED3C5)),
          PlanCategoryTemplate(id: 'travel', label: 'Viagens', icon: Icons.flight_takeoff_rounded, color: Color(0xFF46A5FF)),
          PlanCategoryTemplate(id: 'other', label: 'Diversos', icon: Icons.more_horiz_rounded, color: Color(0xFF95A5A6)),
        ];
    }
  }

  PlanCategoryTemplate _templateForId(PlanGroupType group, String templateId) {
    return _templatesFor(group).firstWhere(
      (template) => template.id == templateId,
      orElse: () => _templatesFor(group).first,
    );
  }

  void _animateChart() {
    _chartController.forward(from: 0);
  }

  void _addLine(PlanGroupType group) {
    final templates = _templatesFor(group);
    final chosen = templates.first;
    final line = PlanLine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      templateId: chosen.id,
      label: chosen.label,
      icon: chosen.icon,
      color: chosen.color,
      amount: 0,
    );

    setState(() {
      _lines[group] ??= [];
      _lines[group]!.add(line);
    });
    _animateChart();
  }

  void _updateLineTemplate(String lineId, PlanGroupType group, String templateId) {
    final template = _templateForId(group, templateId);
    setState(() {
      final index = (_lines[group] ?? []).indexWhere((line) => line.id == lineId);
      if (index >= 0) {
        final line = _lines[group]![index];
        line.templateId = template.id;
        line.label = template.label;
        line.icon = template.icon;
        line.color = template.color;
      }
    });
    _animateChart();
  }

  void _updateLineAmount(String lineId, PlanGroupType group, String value) {
    final parsed = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    setState(() {
      final index = (_lines[group] ?? []).indexWhere((line) => line.id == lineId);
      if (index >= 0) {
        _lines[group]![index].amount = parsed;
      }
    });
    _animateChart();
  }

  void _removeLine(String lineId, PlanGroupType group) {
    setState(() {
      _lines[group]?.removeWhere((line) => line.id == lineId);
    });
    _animateChart();
  }

  double _sumGroup(PlanGroupType group) {
    return (_lines[group] ?? []).fold<double>(0, (sum, line) => sum + line.amount);
  }

  double get totalIncome => _sumGroup(PlanGroupType.income);
  double get totalInvestments => _sumGroup(PlanGroupType.investment);
  double get totalSavings => _sumGroup(PlanGroupType.saving);
  double get totalFixedExpenses => _sumGroup(PlanGroupType.fixedExpense);
  double get totalVariableExpenses => _sumGroup(PlanGroupType.variableExpense);

  double get remainingBalance => totalIncome - (
      totalInvestments +
      totalSavings +
      totalFixedExpenses +
      totalVariableExpenses
  );

  List<PieChartSectionData> get chartSections {
    final values = <({String label, double value, Color color})>[
      (label: 'Receitas', value: totalIncome, color: const Color(0xFF14B87A)),
      (label: 'Investimentos', value: totalInvestments, color: const Color(0xFF7C4DFF)),
      (label: 'Poupanças', value: totalSavings, color: const Color(0xFF1A73E8)),
      (label: 'Despesas fixas', value: totalFixedExpenses, color: const Color(0xFFEA4F5D)),
      (label: 'Despesas variáveis', value: totalVariableExpenses, color: const Color(0xFFFFA726)),
      (label: 'Livre', value: remainingBalance > 0 ? remainingBalance : 0.0, color: const Color(0xFFB0BEC5)),
    ];

    final total = values.fold<double>(0, (sum, item) => sum + (item.value > 0 ? item.value : 0));

    if (total <= 0) {
      return [
        PieChartSectionData(
          color: const Color(0xFFB0BEC5),
          value: 1,
          title: '',
          radius: 78,
        ),
      ];
    }

    return values
        .where((item) => item.value > 0)
        .map((item) {
          final share = item.value / total;
          return PieChartSectionData(
            color: item.color,
            value: item.value,
            title: share >= 0.08 ? '${(share * 100).round()}%' : '',
            titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
            radius: 78,
          );
        })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF10141A) : const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(Icons.pie_chart_rounded, color: theme.colorScheme.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Plano financeiro', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface)),
                                    Text('Distribuição do mês', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Receita total',
                                  value: '€ ${totalIncome.toStringAsFixed(2).replaceAll('.', ',')}',
                                  color: const Color(0xFF14B87A),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _SummaryCard(
                                  label: 'Saldo restante',
                                  value: '€ ${remainingBalance.toStringAsFixed(2).replaceAll('.', ',')}',
                                  color: remainingBalance >= 0 ? const Color(0xFF1A73E8) : const Color(0xFFEA4F5D),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          _PlanChartCard(
                            sections: chartSections,
                            remainingBalance: remainingBalance,
                            animation: _chartAnimation,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _CategoryGroupCard(
                              title: 'Receitas',
                              groupType: PlanGroupType.income,
                              lines: _lines[PlanGroupType.income] ?? const [],
                              onAdd: () => _addLine(PlanGroupType.income),
                              onRemove: (lineId) => _removeLine(lineId, PlanGroupType.income),
                              onAmountChanged: (lineId, value) => _updateLineAmount(lineId, PlanGroupType.income, value),
                              onTemplateChanged: (lineId, value) => _updateLineTemplate(lineId, PlanGroupType.income, value),
                            ),
                            const SizedBox(height: 14),
                            _CategoryGroupCard(
                              title: 'Investimentos',
                              groupType: PlanGroupType.investment,
                              lines: _lines[PlanGroupType.investment] ?? const [],
                              onAdd: () => _addLine(PlanGroupType.investment),
                              onRemove: (lineId) => _removeLine(lineId, PlanGroupType.investment),
                              onAmountChanged: (lineId, value) => _updateLineAmount(lineId, PlanGroupType.investment, value),
                              onTemplateChanged: (lineId, value) => _updateLineTemplate(lineId, PlanGroupType.investment, value),
                            ),
                            const SizedBox(height: 14),
                            _CategoryGroupCard(
                              title: 'Poupanças',
                              groupType: PlanGroupType.saving,
                              lines: _lines[PlanGroupType.saving] ?? const [],
                              onAdd: () => _addLine(PlanGroupType.saving),
                              onRemove: (lineId) => _removeLine(lineId, PlanGroupType.saving),
                              onAmountChanged: (lineId, value) => _updateLineAmount(lineId, PlanGroupType.saving, value),
                              onTemplateChanged: (lineId, value) => _updateLineTemplate(lineId, PlanGroupType.saving, value),
                            ),
                            const SizedBox(height: 14),
                            _CategoryGroupCard(
                              title: 'Despesas fixas',
                              groupType: PlanGroupType.fixedExpense,
                              lines: _lines[PlanGroupType.fixedExpense] ?? const [],
                              onAdd: () => _addLine(PlanGroupType.fixedExpense),
                              onRemove: (lineId) => _removeLine(lineId, PlanGroupType.fixedExpense),
                              onAmountChanged: (lineId, value) => _updateLineAmount(lineId, PlanGroupType.fixedExpense, value),
                              onTemplateChanged: (lineId, value) => _updateLineTemplate(lineId, PlanGroupType.fixedExpense, value),
                            ),
                            const SizedBox(height: 14),
                            _CategoryGroupCard(
                              title: 'Despesas variáveis',
                              groupType: PlanGroupType.variableExpense,
                              lines: _lines[PlanGroupType.variableExpense] ?? const [],
                              onAdd: () => _addLine(PlanGroupType.variableExpense),
                              onRemove: (lineId) => _removeLine(lineId, PlanGroupType.variableExpense),
                              onAmountChanged: (lineId, value) => _updateLineAmount(lineId, PlanGroupType.variableExpense, value),
                              onTemplateChanged: (lineId, value) => _updateLineTemplate(lineId, PlanGroupType.variableExpense, value),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
        ],
      ),
    );
  }
}

class _PlanChartCard extends StatelessWidget {
  final List<PieChartSectionData> sections;
  final double remainingBalance;
  final Animation<double> animation;

  const _PlanChartCard({
    required this.sections,
    required this.remainingBalance,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = sections.isEmpty || sections.every((section) => section.value <= 0)
            ? 1.0
            : animation.value.clamp(0.12, 1.0);

        final animatedSections = sections
            .map((section) => section.copyWith(value: section.value * progress))
            .toList();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : const Color(0xFFB7C8DD)).withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Distribuição do mês',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: remainingBalance >= 0
                            ? const Color(0xFF1F8D67).withValues(alpha: 0.08)
                            : const Color(0xFFEA4F5D).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        remainingBalance >= 0 ? 'Saldo positivo' : 'Saldo negativo',
                        style: TextStyle(
                          color: remainingBalance >= 0 ? const Color(0xFF1F8D67) : const Color(0xFFEA4F5D),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 255,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 52,
                    startDegreeOffset: -90,
                    centerSpaceColor: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
                    sections: animatedSections,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: const [
                  _LegendChip(label: 'Receitas', color: Color(0xFF14B87A)),
                  _LegendChip(label: 'Investimentos', color: Color(0xFF7C4DFF)),
                  _LegendChip(label: 'Poupanças', color: Color(0xFF1A73E8)),
                  _LegendChip(label: 'Despesas fixas', color: Color(0xFFEA4F5D)),
                  _LegendChip(label: 'Despesas variáveis', color: Color(0xFFFFA726)),
                  _LegendChip(label: 'Livre', color: Color(0xFFB0BEC5)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: remainingBalance >= 0 ? const Color(0xFF1F8D67).withValues(alpha: 0.08) : const Color(0xFFEA4F5D).withValues(alpha: 0.08),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dinheiro ainda por dividir', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    Text('€ ${remainingBalance.toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(color: remainingBalance >= 0 ? const Color(0xFF1F8D67) : const Color(0xFFEA4F5D), fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _LegendChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CategoryGroupCard extends StatelessWidget {
  final String title;
  final PlanGroupType groupType;
  final List<PlanLine> lines;
  final VoidCallback onAdd;
  final Function(String) onRemove;
  final Function(String, String) onAmountChanged;
  final Function(String, String) onTemplateChanged;

  const _CategoryGroupCard({
    required this.title,
    required this.groupType,
    required this.lines,
    required this.onAdd,
    required this.onRemove,
    required this.onAmountChanged,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final templates = _templatesForType(groupType);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF11151D) : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0x3D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: theme.colorScheme.onSurface)),
              IconButton.filled(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                tooltip: 'Nova linha',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (lines.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.surfaceContainerLowest,
              ),
              child: Text('Nenhuma linha configurada. Adicione uma categoria para começar.', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
            )
          else
            ...lines.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PlanLineEditor(
                    line: line,
                    templates: templates,
                    onRemove: () => onRemove(line.id),
                    onAmountChanged: (value) => onAmountChanged(line.id, value),
                    onTemplateChanged: (value) => onTemplateChanged(line.id, value),
                  ),
                )),
        ],
      ),
    );
  }

  List<PlanCategoryTemplate> _templatesForType(PlanGroupType groupType) {
    switch (groupType) {
      case PlanGroupType.income:
        return const [
          PlanCategoryTemplate(id: 'salary', label: 'Salário', icon: Icons.work_outline_rounded, color: Color(0xFF14B87A)),
          PlanCategoryTemplate(id: 'freelance', label: 'Freelance', icon: Icons.computer_outlined, color: Color(0xFF3BC9A4)),
          PlanCategoryTemplate(id: 'rental', label: 'Renda', icon: Icons.real_estate_agent_outlined, color: Color(0xFF4F9DFF)),
          PlanCategoryTemplate(id: 'bonus', label: 'Bônus', icon: Icons.auto_awesome_outlined, color: Color(0xFFFFB84D)),
        ];
      case PlanGroupType.investment:
        return const [
          PlanCategoryTemplate(id: 'etf', label: 'ETF', icon: Icons.trending_up_rounded, color: Color(0xFF7C4DFF)),
          PlanCategoryTemplate(id: 'stocks', label: 'Ações', icon: Icons.bar_chart_rounded, color: Color(0xFF5E6BFF)),
          PlanCategoryTemplate(id: 'crypto', label: 'Cripto', icon: Icons.currency_bitcoin_rounded, color: Color(0xFFF5A623)),
          PlanCategoryTemplate(id: 'ppr', label: 'PPR', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF00B8D9)),
          PlanCategoryTemplate(id: 'certificado', label: 'Cert. de Aforro', icon: Icons.savings_rounded, color: Color(0xFF00A36C)),
        ];
      case PlanGroupType.saving:
        return const [
          PlanCategoryTemplate(id: 'saving', label: 'Poupança', icon: Icons.savings_rounded, color: Color(0xFF1A73E8)),
          PlanCategoryTemplate(id: 'emergency', label: 'Fundo de emergência', icon: Icons.shield_outlined, color: Color(0xFF00BFA5)),
        ];
      case PlanGroupType.fixedExpense:
        return const [
          PlanCategoryTemplate(id: 'rent_house', label: 'Aluguel', icon: Icons.home_rounded, color: Color(0xFFEA4F5D)),
          PlanCategoryTemplate(id: 'utilities', label: 'Internet / Luz', icon: Icons.lightbulb_outline_rounded, color: Color(0xFFF7956A)),
          PlanCategoryTemplate(id: 'insurance', label: 'Seguros', icon: Icons.security_rounded, color: Color(0xFF9B5DE5)),
          PlanCategoryTemplate(id: 'loan', label: 'Empréstimo', icon: Icons.payments_rounded, color: Color(0xFFDB4D87)),
          PlanCategoryTemplate(id: 'subscriptions', label: 'Assinaturas', icon: Icons.subscriptions_rounded, color: Color(0xFF5F7AFF)),
          PlanCategoryTemplate(id: 'transport_fix', label: 'Transporte fixo', icon: Icons.directions_car_rounded, color: Color(0xFFFF8A65)),
        ];
      case PlanGroupType.variableExpense:
        return const [
          PlanCategoryTemplate(id: 'food', label: 'Alimentação', icon: Icons.restaurant_rounded, color: Color(0xFFF26A6A)),
          PlanCategoryTemplate(id: 'leisure', label: 'Lazer', icon: Icons.movie_filter_rounded, color: Color(0xFFFFC857)),
          PlanCategoryTemplate(id: 'shopping', label: 'Compras', icon: Icons.shopping_bag_rounded, color: Color(0xFFB98BFF)),
          PlanCategoryTemplate(id: 'health', label: 'Saúde', icon: Icons.medical_services_outlined, color: Color(0xFF6ED3C5)),
          PlanCategoryTemplate(id: 'travel', label: 'Viagens', icon: Icons.flight_takeoff_rounded, color: Color(0xFF46A5FF)),
          PlanCategoryTemplate(id: 'other', label: 'Diversos', icon: Icons.more_horiz_rounded, color: Color(0xFF95A5A6)),
        ];
    }
  }
}

class _PlanLineEditor extends StatelessWidget {
  final PlanLine line;
  final List<PlanCategoryTemplate> templates;
  final VoidCallback onRemove;
  final ValueChanged<String> onAmountChanged;
  final ValueChanged<String> onTemplateChanged;

  const _PlanLineEditor({
    required this.line,
    required this.templates,
    required this.onRemove,
    required this.onAmountChanged,
    required this.onTemplateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: line.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(line.icon, color: line.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: line.templateId,
                    decoration: InputDecoration(
                      hintText: 'Categoria',
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: templates
                        .map(
                          (template) => DropdownMenuItem(
                            value: template.id,
                            child: Text(
                              template.label,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onTemplateChanged(value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 18),
                tooltip: 'Remover linha',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: line.amount == 0 ? '' : line.amount.toStringAsFixed(2).replaceAll('.', ','),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Valor em €',
              prefixText: '€ ',
              filled: true,
              fillColor: theme.colorScheme.surface,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: onAmountChanged,
          ),
        ],
      ),
    );
  }
}

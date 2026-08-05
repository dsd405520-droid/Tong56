import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const StudentDashboardApp());
}

class StudentDashboardApp extends StatelessWidget {
  const StudentDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ສະຖິຕິນັກຮຽນ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2A78D6),
        scaffoldBackgroundColor: const Color(0xFFF5F4F0),
        fontFamily: 'NotoSansLao',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF2A78D6),
        scaffoldBackgroundColor: const Color(0xFF161615),
        fontFamily: 'NotoSansLao',
      ),
      themeMode: ThemeMode.system,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1C) : Colors.white;
    final mutedColor = isDark ? const Color(0xFFC3C2B7) : const Color(0xFF52514E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ສະຖິຕິນັກຮຽນ ມ.1 - ມ.7'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary cards
            _SummaryCards(cardColor: cardColor, mutedColor: mutedColor),
            const SizedBox(height: 24),

            // Grade level breakdown
            _SectionCard(
              title: 'ແຍກຕາມລະດັບຊັ້ນຮຽນ (ມ.1 - ມ.7)',
              cardColor: cardColor,
              child: const _GradeLevelChart(),
              legend: const [
                _LegendItem(color: Color(0xFF1BAF7A), label: 'ມາຮຽນປົກກະຕິ'),
                _LegendItem(color: Color(0xFFE34948), label: 'ຂາດຮຽນ'),
              ],
            ),
            const SizedBox(height: 16),

            // Monthly trend
            _SectionCard(
              title: 'ແນວໂນ້ມການມາຮຽນລາຍເດືອນ',
              cardColor: cardColor,
              child: const _MonthlyTrendChart(),
            ),
            const SizedBox(height: 16),

            // Gender distribution
            _SectionCard(
              title: 'ແຍກຕາມເພດ',
              cardColor: cardColor,
              child: const _GenderPieChart(),
              legend: const [
                _LegendItem(color: Color(0xFFE87BA4), label: 'ຍິງ (52.4%)'),
                _LegendItem(color: Color(0xFF2A78D6), label: 'ຊາຍ (47.6%)'),
              ],
            ),
            const SizedBox(height: 16),

            // Attendance status
            _SectionCard(
              title: 'ສະຖານະການມາໂຮງຮຽນ',
              cardColor: cardColor,
              child: _HorizontalBarGroup(
                mutedColor: mutedColor,
                items: const [
                  _BarItem('ມາທັນເວລາ', 17884.86, 17884.86, Color(0xFF1BAF7A)),
                  _BarItem('ມາຊ້າ', 22.64, 17884.86, Color(0xFFEDA100)),
                  _BarItem('ລາພັກ', 0.34, 17884.86, Color(0xFF4A3AA7)),
                  _BarItem('ຂາດຮຽນ', 115.82, 17884.86, Color(0xFFE34948)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Streams
            _SectionCard(
              title: 'ສາຍການຮຽນ ມ.ປາຍ',
              cardColor: cardColor,
              child: _HorizontalBarGroup(
                mutedColor: mutedColor,
                items: const [
                  _BarItem('ວິທະຍາສາດ-ທຳມະຊາດ', 4500, 4500, Color(0xFF1BAF7A)),
                  _BarItem('ວິທະຍາສາດ-ສັງຄົມ', 3442, 4500, Color(0xFF2A78D6)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------- Summary cards ----------

class _SummaryCards extends StatelessWidget {
  final Color cardColor;
  final Color mutedColor;
  const _SummaryCards({required this.cardColor, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;
        final cards = [
          _MetricCard(
            label: 'ນັກຮຽນທັງໝົດ',
            value: '18,122',
            delta: '+0.02% ຈາກເດືອນກ່ອນ',
            deltaUp: true,
            cardColor: cardColor,
            mutedColor: mutedColor,
          ),
          _MetricCard(
            label: 'ມາຮຽນປົກກະຕິ',
            value: '17,984',
            delta: '99.24% ຂອງທັງໝົດ',
            deltaUp: false,
            cardColor: cardColor,
            mutedColor: mutedColor,
          ),
          _MetricCard(
            label: 'ຜິດປົກກະຕິ',
            value: '138',
            delta: '0.76% ຂອງທັງໝົດ',
            deltaUp: false,
            cardColor: cardColor,
            mutedColor: mutedColor,
          ),
        ];

        if (isNarrow) {
          return Column(
            children: [
              for (final c in cards) ...[c, const SizedBox(height: 12)],
            ],
          );
        }
        return Row(
          children: [
            for (final c in cards) ...[
              Expanded(child: c),
              if (c != cards.last) const SizedBox(width: 12),
            ],
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final bool deltaUp;
  final Color cardColor;
  final Color mutedColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.delta,
    required this.deltaUp,
    required this.cardColor,
    required this.mutedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: mutedColor)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            delta,
            style: TextStyle(
              fontSize: 12,
              color: deltaUp ? const Color(0xFF1BAF7A) : mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Section card wrapper ----------

class _SectionCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Widget child;
  final List<_LegendItem>? legend;

  const _SectionCard({
    required this.title,
    required this.cardColor,
    required this.child,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          child,
          if (legend != null) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 8, children: legend!),
          ],
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ---------- Grade level bar chart ----------

class _GradeLevelChart extends StatelessWidget {
  const _GradeLevelChart();

  static const grades = ['ມ.1', 'ມ.2', 'ມ.3', 'ມ.4', 'ມ.5', 'ມ.6', 'ມ.7'];
  static const normal = [2630.0, 2565.0, 2485.0, 2430.0, 2575.0, 2622.0, 2677.0];
  static const absent = [20.0, 15.0, 15.0, 20.0, 25.0, 20.0, 23.0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 3000,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                reservedSize: 44,
                getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= grades.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(grades[i], style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(grades.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: normal[i],
                  color: const Color(0xFF1BAF7A),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
                BarChartRodData(
                  toY: absent[i],
                  color: const Color(0xFFE34948),
                  width: 12,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
                ),
              ],
              barsSpace: 4,
            );
          }),
        ),
      ),
    );
  }
}

// ---------- Monthly trend line chart ----------

class _MonthlyTrendChart extends StatelessWidget {
  const _MonthlyTrendChart();

  static const months = ['ມັງກອນ', 'ກຸມພາ', 'ມີນາ'];
  static const rates = [98.5, 99.0, 99.24];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: 97,
          maxY: 100,
          gridData: FlGridData(
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= months.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(months[i], style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(rates.length, (i) => FlSpot(i.toDouble(), rates[i])),
              isCurved: true,
              color: const Color(0xFF2A78D6),
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: const Color(0xFF2A78D6).withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Gender pie chart ----------

class _GenderPieChart extends StatelessWidget {
  const _GenderPieChart();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: 9500,
              color: const Color(0xFFE87BA4),
              title: '',
              radius: 45,
            ),
            PieChartSectionData(
              value: 8622,
              color: const Color(0xFF2A78D6),
              title: '',
              radius: 45,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Horizontal bar list (used for status + streams) ----------

class _BarItem {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  const _BarItem(this.label, this.value, this.maxValue, this.color);
}

class _HorizontalBarGroup extends StatelessWidget {
  final List<_BarItem> items;
  final Color mutedColor;
  const _HorizontalBarGroup({required this.items, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          _HorizontalBar(item: item, mutedColor: mutedColor),
          if (item != items.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  final _BarItem item;
  final Color mutedColor;
  const _HorizontalBar({required this.item, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final ratio = item.maxValue == 0 ? 0.0 : (item.value / item.maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.label, style: TextStyle(fontSize: 12, color: mutedColor)),
            Text(
              item.value % 1 == 0 ? item.value.toInt().toString() : item.value.toStringAsFixed(2),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(height: 10, width: constraints.maxWidth, color: item.color.withOpacity(0.15)),
                  Container(height: 10, width: constraints.maxWidth * ratio, color: item.color),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

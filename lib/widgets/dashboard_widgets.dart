import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/school_data.dart';

// ---------- Summary cards ----------

class SummaryCards extends StatelessWidget {
  final Color cardColor;
  final Color mutedColor;
  final Summary summary;
  const SummaryCards({
    super.key,
    required this.cardColor,
    required this.mutedColor,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      MetricCard(
        label: 'ນັກຮຽນທັງໝົດ',
        value: _formatInt(summary.totalStudents),
        delta:
            '${summary.changeFromLastMonthPercent >= 0 ? '+' : ''}${summary.changeFromLastMonthPercent}% ຈາກເດືອນກ່ອນ',
        deltaUp: true,
        cardColor: cardColor,
        mutedColor: mutedColor,
      ),
      MetricCard(
        label: 'ມາຮຽນປົກກະຕິ',
        value: _formatInt(summary.normalCount),
        delta: '${summary.normalPercent}% ຂອງທັງໝົດ',
        deltaUp: false,
        cardColor: cardColor,
        mutedColor: mutedColor,
      ),
      MetricCard(
        label: 'ຜິດປົກກະຕິ',
        value: _formatInt(summary.abnormalCount),
        delta: '${summary.abnormalPercent}% ຂອງທັງໝົດ',
        deltaUp: false,
        cardColor: cardColor,
        mutedColor: mutedColor,
      ),
    ];

    return Row(
      children: [
        for (final c in cards) ...[
          Expanded(child: c),
          if (c != cards.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  static String _formatInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String delta;
  final bool deltaUp;
  final Color cardColor;
  final Color mutedColor;

  const MetricCard({
    super.key,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: mutedColor)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(
            delta,
            style: TextStyle(
              fontSize: 10,
              color: deltaUp ? const Color(0xFF1BAF7A) : mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Section card wrapper ----------

class SectionCard extends StatelessWidget {
  final String title;
  final Color cardColor;
  final Widget child;
  final List<LegendItem>? legend;

  const SectionCard({
    super.key,
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
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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

class LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const LegendItem({super.key, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

// ---------- Grade level bar chart ----------

class GradeLevelChart extends StatelessWidget {
  final List<GradeLevel> data;
  const GradeLevelChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final maxTotal =
        data.map((g) => g.total).fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = ((maxTotal / 500).ceil() + 1) * 500.0;

    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 500,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                reservedSize: 44,
                getTitlesWidget: (v, meta) => Text(v.toInt().toString(),
                    style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(data[i].grade,
                        style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].normal.toDouble(),
                  color: const Color(0xFF1BAF7A),
                  width: 12,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
                ),
                BarChartRodData(
                  toY: data[i].absent.toDouble(),
                  color: const Color(0xFFE34948),
                  width: 12,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(3)),
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

class MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTrend> data;
  const MonthlyTrendChart({super.key, required this.data});

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
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Colors.grey.withOpacity(0.15), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, meta) =>
                    Text('${v.toInt()}%', style: const TextStyle(fontSize: 11)),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(data[i].month,
                        style: const TextStyle(fontSize: 12)),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(data.length,
                  (i) => FlSpot(i.toDouble(), data[i].attendancePercent)),
              isCurved: true,
              color: const Color(0xFF2A78D6),
              barWidth: 2,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                  show: true, color: const Color(0xFF2A78D6).withOpacity(0.1)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Gender pie chart ----------

class GenderPieChart extends StatelessWidget {
  final GenderDistribution data;
  const GenderPieChart({super.key, required this.data});

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
              value: data.femaleCount.toDouble(),
              color: const Color(0xFFE87BA4),
              title: '',
              radius: 45,
            ),
            PieChartSectionData(
              value: data.maleCount.toDouble(),
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

class BarItem {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  const BarItem(this.label, this.value, this.maxValue, this.color);
}

class HorizontalBarGroup extends StatelessWidget {
  final List<BarItem> items;
  final Color mutedColor;
  const HorizontalBarGroup(
      {super.key, required this.items, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items) ...[
          HorizontalBar(item: item, mutedColor: mutedColor),
          if (item != items.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class HorizontalBar extends StatelessWidget {
  final BarItem item;
  final Color mutedColor;
  const HorizontalBar({super.key, required this.item, required this.mutedColor});

  @override
  Widget build(BuildContext context) {
    final ratio =
        item.maxValue == 0 ? 0.0 : (item.value / item.maxValue).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.label, style: TextStyle(fontSize: 12, color: mutedColor)),
            Text(
              item.value % 1 == 0
                  ? item.value.toInt().toString()
                  : item.value.toStringAsFixed(2),
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
                  Container(
                      height: 10,
                      width: constraints.maxWidth,
                      color: item.color.withOpacity(0.15)),
                  Container(
                      height: 10,
                      width: constraints.maxWidth * ratio,
                      color: item.color),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
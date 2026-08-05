import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const StudentDashboardApp());
}

class ApiConfig {
  static const String baseUrl = 'http://127.0.0.1:8000/schooldata';
}

class SchoolDataService {
  static Future<SchoolData> fetchAll() async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}/all'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load school data (${res.statusCode})');
    }
    final Map<String, dynamic> json = jsonDecode(utf8.decode(res.bodyBytes));
    return SchoolData.fromJson(json);
  }
}

class SchoolData {
  final Summary summary;
  final List<GradeLevel> gradeLevelBreakdown;
  final List<MonthlyTrend> monthlyAttendanceTrend;
  final AttendanceStatus attendanceStatus;
  final GenderDistribution genderDistribution;
  final StreamsBreakdown streamsBreakdown;

  SchoolData({
    required this.summary,
    required this.gradeLevelBreakdown,
    required this.monthlyAttendanceTrend,
    required this.attendanceStatus,
    required this.genderDistribution,
    required this.streamsBreakdown,
  });

  factory SchoolData.fromJson(Map<String, dynamic> j) {
    return SchoolData(
      summary: Summary.fromJson(j['summary']),
      gradeLevelBreakdown: (j['grade_level_breakdown'] as List)
          .map((e) => GradeLevel.fromJson(e))
          .toList(),
      monthlyAttendanceTrend: (j['monthly_attendance_trend'] as List)
          .map((e) => MonthlyTrend.fromJson(e))
          .toList(),
      attendanceStatus: AttendanceStatus.fromJson(j['attendance_status']),
      genderDistribution: GenderDistribution.fromJson(j['gender_distribution']),
      streamsBreakdown: StreamsBreakdown.fromJson(j['streams_breakdown']),
    );
  }
}

class Summary {
  final int totalStudents;
  final double changeFromLastMonthPercent;
  final int normalCount;
  final double normalPercent;
  final int abnormalCount;
  final double abnormalPercent;

  Summary({
    required this.totalStudents,
    required this.changeFromLastMonthPercent,
    required this.normalCount,
    required this.normalPercent,
    required this.abnormalCount,
    required this.abnormalPercent,
  });

  factory Summary.fromJson(Map<String, dynamic> j) => Summary(
        totalStudents: j['total_students'],
        changeFromLastMonthPercent:
            (j['change_from_last_month_percent'] as num).toDouble(),
        normalCount: j['normal_attendance']['count'],
        normalPercent: (j['normal_attendance']['percent'] as num).toDouble(),
        abnormalCount: j['abnormal_attendance']['count'],
        abnormalPercent:
            (j['abnormal_attendance']['percent'] as num).toDouble(),
      );
}

class GradeLevel {
  final String grade;
  final int total;
  final int normal;
  final int absent;

  GradeLevel({
    required this.grade,
    required this.total,
    required this.normal,
    required this.absent,
  });

  factory GradeLevel.fromJson(Map<String, dynamic> j) => GradeLevel(
        grade: j['grade'],
        total: j['total'],
        normal: j['normal'],
        absent: j['absent'],
      );
}

class MonthlyTrend {
  final String month;
  final double attendancePercent;
  final double absentPercent;

  MonthlyTrend({
    required this.month,
    required this.attendancePercent,
    required this.absentPercent,
  });

  factory MonthlyTrend.fromJson(Map<String, dynamic> j) => MonthlyTrend(
        month: j['month'],
        attendancePercent: (j['attendance_percent'] as num).toDouble(),
        absentPercent: (j['absent_percent'] as num).toDouble(),
      );
}

class AttendanceStatus {
  final double onTimeCount;
  final double onTimePercent;
  final double lateCount;
  final double latePercent;
  final double leaveCount;
  final double leavePercent;
  final double absentCount;
  final double absentPercent;

  AttendanceStatus({
    required this.onTimeCount,
    required this.onTimePercent,
    required this.lateCount,
    required this.latePercent,
    required this.leaveCount,
    required this.leavePercent,
    required this.absentCount,
    required this.absentPercent,
  });

  factory AttendanceStatus.fromJson(Map<String, dynamic> j) => AttendanceStatus(
        onTimeCount: (j['on_time']['count'] as num).toDouble(),
        onTimePercent: (j['on_time']['percent'] as num).toDouble(),
        lateCount: (j['late']['count'] as num).toDouble(),
        latePercent: (j['late']['percent'] as num).toDouble(),
        leaveCount: (j['leave']['count'] as num).toDouble(),
        leavePercent: (j['leave']['percent'] as num).toDouble(),
        absentCount: (j['absent']['count'] as num).toDouble(),
        absentPercent: (j['absent']['percent'] as num).toDouble(),
      );
}

class GenderDistribution {
  final int femaleCount;
  final double femalePercent;
  final int maleCount;
  final double malePercent;

  GenderDistribution({
    required this.femaleCount,
    required this.femalePercent,
    required this.maleCount,
    required this.malePercent,
  });

  factory GenderDistribution.fromJson(Map<String, dynamic> j) =>
      GenderDistribution(
        femaleCount: j['female']['count'],
        femalePercent: (j['female']['percent'] as num).toDouble(),
        maleCount: j['male']['count'],
        malePercent: (j['male']['percent'] as num).toDouble(),
      );
}

class StreamsBreakdown {
  final int scienceCount;
  final double sciencePercent;
  final int socialScienceCount;
  final double socialSciencePercent;

  StreamsBreakdown({
    required this.scienceCount,
    required this.sciencePercent,
    required this.socialScienceCount,
    required this.socialSciencePercent,
  });

  factory StreamsBreakdown.fromJson(Map<String, dynamic> j) => StreamsBreakdown(
        scienceCount: j['science']['count'],
        sciencePercent: (j['science']['percent'] as num).toDouble(),
        socialScienceCount: j['social_science']['count'],
        socialSciencePercent:
            (j['social_science']['percent'] as num).toDouble(),
      );
}

// ---------- APP ----------
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

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<SchoolData> _futureData;

  @override
  void initState() {
    super.initState();
    _futureData = SchoolDataService.fetchAll();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = SchoolDataService.fetchAll();
    });
    await _futureData;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1C) : Colors.white;
    final mutedColor =
        isDark ? const Color(0xFFC3C2B7) : const Color(0xFF52514E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ສະຖິຕິນັກຮຽນ ມ.1 - ມ.7'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: FutureBuilder<SchoolData>(
          future: _futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 40, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        'ໂຫຼດຂໍ້ມູນບໍ່ສຳເລັດ: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('ລອງໃໝ່'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCards(
                    cardColor: cardColor,
                    mutedColor: mutedColor,
                    summary: data.summary,
                  ),
                  const SizedBox(height: 24),
                  _SectionCard(
                    title: 'ແຍກຕາມລະດັບຊັ້ນຮຽນ (ມ.1 - ມ.7)',
                    cardColor: cardColor,
                    child: _GradeLevelChart(data: data.gradeLevelBreakdown),
                    legend: const [
                      _LegendItem(
                          color: Color(0xFF1BAF7A), label: 'ມາຮຽນປົກກະຕິ'),
                      _LegendItem(color: Color(0xFFE34948), label: 'ຂາດຮຽນ'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ແນວໂນ້ມການມາຮຽນລາຍເດືອນ',
                    cardColor: cardColor,
                    child:
                        _MonthlyTrendChart(data: data.monthlyAttendanceTrend),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ແຍກຕາມເພດ',
                    cardColor: cardColor,
                    child: _GenderPieChart(data: data.genderDistribution),
                    legend: [
                      _LegendItem(
                          color: const Color(0xFFE87BA4),
                          label:
                              'ຍິງ (${data.genderDistribution.femalePercent.toStringAsFixed(1)}%)'),
                      _LegendItem(
                          color: const Color(0xFF2A78D6),
                          label:
                              'ຊາຍ (${data.genderDistribution.malePercent.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ສະຖານະການມາໂຮງຮຽນ',
                    cardColor: cardColor,
                    child: _HorizontalBarGroup(
                      mutedColor: mutedColor,
                      items: [
                        _BarItem(
                            'ມາທັນເວລາ',
                            data.attendanceStatus.onTimeCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFF1BAF7A)),
                        _BarItem(
                            'ມາຊ້າ',
                            data.attendanceStatus.lateCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFFEDA100)),
                        _BarItem(
                            'ລາພັກ',
                            data.attendanceStatus.leaveCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFF4A3AA7)),
                        _BarItem(
                            'ຂາດຮຽນ',
                            data.attendanceStatus.absentCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFFE34948)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'ສາຍການຮຽນ ມ.ປາຍ',
                    cardColor: cardColor,
                    child: _HorizontalBarGroup(
                      mutedColor: mutedColor,
                      items: [
                        _BarItem(
                            'ວິທະຍາສາດ-ທຳມະຊາດ',
                            data.streamsBreakdown.scienceCount.toDouble(),
                            data.streamsBreakdown.scienceCount.toDouble(),
                            const Color(0xFF1BAF7A)),
                        _BarItem(
                            'ວິທະຍາສາດ-ສັງຄົມ',
                            data.streamsBreakdown.socialScienceCount.toDouble(),
                            data.streamsBreakdown.scienceCount.toDouble(),
                            const Color(0xFF2A78D6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------- Summary cards ----------

class _SummaryCards extends StatelessWidget {
  final Color cardColor;
  final Color mutedColor;
  final Summary summary;
  const _SummaryCards({
    required this.cardColor,
    required this.mutedColor,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 480;
        final cards = [
          _MetricCard(
            label: 'ນັກຮຽນທັງໝົດ',
            value: _formatInt(summary.totalStudents),
            delta:
                '${summary.changeFromLastMonthPercent >= 0 ? '+' : ''}${summary.changeFromLastMonthPercent}% ຈາກເດືອນກ່ອນ',
            deltaUp: true,
            cardColor: cardColor,
            mutedColor: mutedColor,
          ),
          _MetricCard(
            label: 'ມາຮຽນປົກກະຕິ',
            value: _formatInt(summary.normalCount),
            delta: '${summary.normalPercent}% ຂອງທັງໝົད',
            deltaUp: false,
            cardColor: cardColor,
            mutedColor: mutedColor,
          ),
          _MetricCard(
            label: 'ຜິດປົກກະຕິ',
            value: _formatInt(summary.abnormalCount),
            delta: '${summary.abnormalPercent}% ຂອງທັງໝົດ',
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
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w500)),
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
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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

class _GradeLevelChart extends StatelessWidget {
  final List<GradeLevel> data;
  const _GradeLevelChart({required this.data});

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

class _MonthlyTrendChart extends StatelessWidget {
  final List<MonthlyTrend> data;
  const _MonthlyTrendChart({required this.data});

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

class _GenderPieChart extends StatelessWidget {
  final GenderDistribution data;
  const _GenderPieChart({required this.data});

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

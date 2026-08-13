import 'package:flutter/material.dart';

import '../models/school_data.dart';
import '../services/school_data_service.dart';
import '../widgets/dashboard_widgets.dart';
import '../services/auth_service.dart';
import '../pages/login_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<SchoolData> _futureData;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _futureData = SchoolDataService.fetchAll();
    _loadAdminStatus();
  }

  Future<void> _loadAdminStatus() async {
    final isAdmin = await AuthService.isAdmin();
    if (mounted)
      setState(() {
        _isAdmin = isAdmin;
      });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Chip(
                avatar: Icon(
                  _isAdmin ? Icons.verified_user : Icons.person_outline,
                  size: 16,
                  color: _isAdmin ? Colors.white : null,
                ),
                label: Text(_isAdmin ? 'Admin' : 'User'),
                backgroundColor: _isAdmin ? const Color(0xFF2A78D6) : null,
                labelStyle: TextStyle(color: _isAdmin ? Colors.white : null),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'ອອກຈາກລະບົບ',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
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
                  SummaryCards(
                    cardColor: cardColor,
                    mutedColor: mutedColor,
                    summary: data.summary,
                  ),
                  const SizedBox(height: 24),
                  SectionCard(
                    title: 'ແຍກຕາມລະດັບຊັ້ນຮຽນ (ມ.1 - ມ.7)',
                    cardColor: cardColor,
                    child: GradeLevelChart(data: data.gradeLevelBreakdown),
                    legend: const [
                      LegendItem(
                          color: Color(0xFF1BAF7A), label: 'ມາຮຽນປົກກະຕິ'),
                      LegendItem(color: Color(0xFFE34948), label: 'ຂາດຮຽນ'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'ແນວໂນ້ມການມາຮຽນລາຍເດືອນ',
                    cardColor: cardColor,
                    child: MonthlyTrendChart(data: data.monthlyAttendanceTrend),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'ແຍກຕາມເພດ',
                    cardColor: cardColor,
                    child: GenderPieChart(data: data.genderDistribution),
                    legend: [
                      LegendItem(
                          color: const Color(0xFFE87BA4),
                          label:
                              'ຍິງ (${data.genderDistribution.femalePercent.toStringAsFixed(1)}%)'),
                      LegendItem(
                          color: const Color(0xFF2A78D6),
                          label:
                              'ຊາຍ (${data.genderDistribution.malePercent.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'ສະຖານະການມາໂຮງຮຽນ',
                    cardColor: cardColor,
                    child: HorizontalBarGroup(
                      mutedColor: mutedColor,
                      items: [
                        BarItem(
                            'ມາທັນເວລາ',
                            data.attendanceStatus.onTimeCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFF1BAF7A)),
                        BarItem(
                            'ມາຊ້າ',
                            data.attendanceStatus.lateCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFFEDA100)),
                        BarItem(
                            'ລາພັກ',
                            data.attendanceStatus.leaveCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFF4A3AA7)),
                        BarItem(
                            'ຂາດຮຽນ',
                            data.attendanceStatus.absentCount,
                            data.attendanceStatus.onTimeCount,
                            const Color(0xFFE34948)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SectionCard(
                    title: 'ສາຍການຮຽນ ມ.ປາຍ',
                    cardColor: cardColor,
                    child: HorizontalBarGroup(
                      mutedColor: mutedColor,
                      items: [
                        BarItem(
                            'ວິທະຍາສາດ-ທຳມະຊາດ',
                            data.streamsBreakdown.scienceCount.toDouble(),
                            data.streamsBreakdown.scienceCount.toDouble(),
                            const Color(0xFF1BAF7A)),
                        BarItem(
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
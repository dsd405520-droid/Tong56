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
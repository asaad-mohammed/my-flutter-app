// ════════════════════════════════════════════════════════
//  core/models/family_member.dart
//  نموذج بيانات فرد العائلة مع السجل الطبي الكامل
// ════════════════════════════════════════════════════════

enum FamilyRelation {
  father, mother, son, daughter,
  husband, wife, brother, sister,
  grandfather, grandmother, other,
}

enum MemberStatus {
  safe,    // بأمان
  unknown, // غير معروف
  danger,  // خطر
  sos,     // يستغيث الآن
}

enum BloodType { aPos, aNeg, bPos, bNeg, abPos, abNeg, oPos, oNeg }

// ────────────────────────────────────────────────────────
//  FamilyMember
// ────────────────────────────────────────────────────────
class FamilyMember {
  final String id;
  final String nationalId;     // رقم الهوية
  final String nameAr;
  final String nameEn;
  final int age;
  final bool isMale;
  final FamilyRelation relation;
  final BloodType bloodType;
  final String phone;

  // ── السجل الطبي ──────────────────────────────────────
  final List<String> chronicDiseases;  // أمراض مزمنة
  final List<String> allergies;        // حساسيات
  final List<String> currentMeds;      // أدوية حالية
  final String? emergencyNote;         // ملاحظة طوارئ مهمة

  // ── الحالة ───────────────────────────────────────────
  MemberStatus status;
  DateTime? lastSeen;
  double? lastLat;
  double? lastLng;
  String? lastLocation;

  // ── حماية الأطفال ────────────────────────────────────
  bool get isChild => age < 14;

  FamilyMember({
    required this.id,
    required this.nationalId,
    required this.nameAr,
    required this.nameEn,
    required this.age,
    required this.isMale,
    required this.relation,
    required this.bloodType,
    required this.phone,
    this.chronicDiseases = const [],
    this.allergies = const [],
    this.currentMeds = const [],
    this.emergencyNote,
    this.status = MemberStatus.safe,
    this.lastSeen,
    this.lastLat,
    this.lastLng,
    this.lastLocation,
  });

  // ── أسماء ────────────────────────────────────────────
  String get initials {
    final parts = nameAr.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return nameAr.isNotEmpty ? nameAr[0] : '؟';
  }

  String bloodLabel() {
    const m = {
      BloodType.aPos: 'A+',
      BloodType.aNeg: 'A−',
      BloodType.bPos: 'B+',
      BloodType.bNeg: 'B−',
      BloodType.abPos: 'AB+',
      BloodType.abNeg: 'AB−',
      BloodType.oPos: 'O+',
      BloodType.oNeg: 'O−',
    };
    return m[bloodType] ?? '?';
  }

  String relationLabel(bool isAr) {
    if (isAr) {
      const ar = {
        FamilyRelation.father: 'الأب',
        FamilyRelation.mother: 'الأم',
        FamilyRelation.son: 'الابن',
        FamilyRelation.daughter: 'البنت',
        FamilyRelation.husband: 'الزوج',
        FamilyRelation.wife: 'الزوجة',
        FamilyRelation.brother: 'الأخ',
        FamilyRelation.sister: 'الأخت',
        FamilyRelation.grandfather: 'الجد',
        FamilyRelation.grandmother: 'الجدة',
        FamilyRelation.other: 'أخرى',
      };
      return ar[relation] ?? '';
    }
    const en = {
      FamilyRelation.father: 'Father',
      FamilyRelation.mother: 'Mother',
      FamilyRelation.son: 'Son',
      FamilyRelation.daughter: 'Daughter',
      FamilyRelation.husband: 'Husband',
      FamilyRelation.wife: 'Wife',
      FamilyRelation.brother: 'Brother',
      FamilyRelation.sister: 'Sister',
      FamilyRelation.grandfather: 'Grandfather',
      FamilyRelation.grandmother: 'Grandmother',
      FamilyRelation.other: 'Other',
    };
    return en[relation] ?? '';
  }

  FamilyMember copyWith({
    MemberStatus? status,
    String? lastLocation,
    double? lastLat,
    double? lastLng,
    DateTime? lastSeen,
  }) {
    return FamilyMember(
      id: id,
      nationalId: nationalId,
      nameAr: nameAr,
      nameEn: nameEn,
      age: age,
      isMale: isMale,
      relation: relation,
      bloodType: bloodType,
      phone: phone,
      chronicDiseases: chronicDiseases,
      allergies: allergies,
      currentMeds: currentMeds,
      emergencyNote: emergencyNote,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      lastLocation: lastLocation ?? this.lastLocation,
      lastLat: lastLat ?? this.lastLat,
      lastLng: lastLng ?? this.lastLng,
    );
  }
}

// ────────────────────────────────────────────────────────
//  EmergencyReport — البلاغ الكامل المرسل للطوارئ
// ────────────────────────────────────────────────────────
enum ReportStatus {
  pending,    // انتظار
  dispatched, // في الطريق
  resolved,   // تم الحل
  cancelled,  // ملغى
}

class EmergencyReport {
  final String reportId;
  final DateTime time;
  final FamilyMember patient;   // المريض/المحتاج مساعدة
  final FamilyMember reporter;  // مقدّم البلاغ
  final String emergencyType;   // نوع الطارئ
  final String description;
  final String? location;
  final double? lat;
  final double? lng;
  ReportStatus status;

  EmergencyReport({
    required this.reportId,
    required this.time,
    required this.patient,
    required this.reporter,
    required this.emergencyType,
    required this.description,
    this.location,
    this.lat,
    this.lng,
    this.status = ReportStatus.dispatched,
  });
}
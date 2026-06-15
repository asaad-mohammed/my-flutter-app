// ════════════════════════════════════════════════════════
//  core/providers/family_provider.dart
//  إدارة حالة نظام العائلة بالكامل
// ════════════════════════════════════════════════════════
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_member.dart';

// ────────────────────────────────────────────────────────
//  بيانات تجريبية — استبدلها بقاعدة بيانات حقيقية
// ────────────────────────────────────────────────────────
final List<FamilyMember> _mockFamily = [
  FamilyMember(
    id: 'f1',
    nationalId: '197001234567',
    nameAr: 'محمد أحمد العلي',
    nameEn: 'Mohammed Ahmed Al-Ali',
    age: 55,
    isMale: true,
    relation: FamilyRelation.father,
    bloodType: BloodType.oPos,
    phone: '+9647701234567',
    chronicDiseases: ['ضغط الدم', 'السكري'],
    currentMeds: ['ميتفورمين 500mg', 'أملوديبين 5mg'],
    allergies: ['البنسلين'],
    emergencyNote: 'مريض السكري — يحتاج أنسولين عند الطوارئ',
    status: MemberStatus.safe,
    lastLocation: 'سليمانية، شارع 40',
  ),
  FamilyMember(
    id: 'f2',
    nationalId: '199501234567',
    nameAr: 'أحمد محمد العلي',
    nameEn: 'Ahmed Mohammed Al-Ali',
    age: 30,
    isMale: true,
    relation: FamilyRelation.son,
    bloodType: BloodType.oPos,
    phone: '+9647702345678',
    chronicDiseases: [],
    currentMeds: [],
    allergies: [],
    status: MemberStatus.safe,
    lastLocation: 'سليمانية، المركز',
  ),
  FamilyMember(
    id: 'f3',
    nationalId: '199801234567',
    nameAr: 'فاطمة محمد العلي',
    nameEn: 'Fatima Mohammed Al-Ali',
    age: 27,
    isMale: false,
    relation: FamilyRelation.daughter,
    bloodType: BloodType.aPos,
    phone: '+9647703456789',
    chronicDiseases: [],
    currentMeds: [],
    allergies: ['الفراولة'],
    status: MemberStatus.safe,
    lastLocation: 'سليمانية، جامعة',
  ),
  FamilyMember(
    id: 'f4',
    nationalId: '201501234567',
    nameAr: 'عمر أحمد العلي',
    nameEn: 'Omar Ahmed Al-Ali',
    age: 10,
    isMale: true,
    relation: FamilyRelation.son,
    bloodType: BloodType.bPos,
    phone: '',
    chronicDiseases: ['الربو'],
    currentMeds: ['بخاخ سالبيتامول'],
    allergies: ['الغبار', 'وبر الحيوانات'],
    emergencyNote: 'طفل مصاب بالربو — يحمل بخاخاً دائماً',
    status: MemberStatus.safe,
    lastLocation: 'سليمانية، مدرسة',
  ),
  FamilyMember(
    id: 'f5',
    nationalId: '201801234567',
    nameAr: 'سارة أحمد العلي',
    nameEn: 'Sara Ahmed Al-Ali',
    age: 7,
    isMale: false,
    relation: FamilyRelation.daughter,
    bloodType: BloodType.oPos,
    phone: '',
    chronicDiseases: [],
    currentMeds: [],
    allergies: [],
    status: MemberStatus.safe,
    lastLocation: 'سليمانية، مدرسة',
  ),
];

// ────────────────────────────────────────────────────────
//  FamilyState
// ────────────────────────────────────────────────────────
class FamilyState {
  final List<FamilyMember>   members;
  final List<EmergencyReport> reports;
  final bool                  isLoading;
  final String?               activeSOSMemberId; // من يستغيث الآن

  const FamilyState({
    this.members            = const [],
    this.reports            = const [],
    this.isLoading          = false,
    this.activeSOSMemberId,
  });

  FamilyState copyWith({
    List<FamilyMember>?   members,
    List<EmergencyReport>? reports,
    bool?                  isLoading,
    String?                activeSOSMemberId,
    bool                   clearSOS = false,
  }) => FamilyState(
    members:            members   ?? this.members,
    reports:            reports   ?? this.reports,
    isLoading:          isLoading ?? this.isLoading,
    activeSOSMemberId:  clearSOS ? null : (activeSOSMemberId ?? this.activeSOSMemberId),
  );
}

// ────────────────────────────────────────────────────────
//  FamilyNotifier
// ────────────────────────────────────────────────────────
class FamilyNotifier extends Notifier<FamilyState> {
  @override
  FamilyState build() => FamilyState(members: _mockFamily);

  // ── إضافة فرد جديد ──────────────────────────────────
  void addMember(FamilyMember member) {
    state = state.copyWith(members: [...state.members, member]);
  }

  // ── تعديل بيانات فرد ────────────────────────────────
  void updateMember(FamilyMember updated) {
    state = state.copyWith(
      members: state.members.map((m) => m.id == updated.id ? updated : m).toList(),
    );
  }

  // ── حذف فرد ─────────────────────────────────────────
  void removeMember(String id) {
    state = state.copyWith(
      members: state.members.where((m) => m.id != id).toList(),
    );
  }

  // ── تحديث حالة فرد ──────────────────────────────────
  void updateStatus(String id, MemberStatus status) {
    state = state.copyWith(
      members: state.members.map((m) {
        return m.id == id ? m.copyWith(status: status) : m;
      }).toList(),
      activeSOSMemberId: status == MemberStatus.sos ? id : state.activeSOSMemberId,
    );
  }

  // ── إرسال بلاغ طوارئ لفرد ───────────────────────────
  Future<EmergencyReport> sendEmergencyForMember({
    required FamilyMember patient,
    required FamilyMember reporter,
    required String emergencyType,
    required String description,
    String? location,
    double? lat,
    double? lng,
  }) async {
    state = state.copyWith(isLoading: true);

    // محاكاة إرسال للخادم
    await Future.delayed(const Duration(milliseconds: 1200));

    final report = EmergencyReport(
      reportId: 'ER-${DateTime.now().millisecondsSinceEpoch}',
      time: DateTime.now(),
      patient: patient,
      reporter: reporter,
      emergencyType: emergencyType,
      description: description,
      location: location,
      lat: lat,
      lng: lng,
      status: ReportStatus.dispatched,
    );

    // تحديث حالة المريض
    updateStatus(patient.id, MemberStatus.sos);

    state = state.copyWith(
      isLoading: false,
      reports: [report, ...state.reports],
    );

    return report;
  }

  // ── إضافة بلاغ طوارئ (طريقة مبسطة للتوافق) ──────────
  void addEmergencyReport(EmergencyReport report) {
    state = state.copyWith(
      reports: [report, ...state.reports],
      activeSOSMemberId: report.patient.id,
    );
    // تحديث حالة المريض إلى SOS
    updateStatus(report.patient.id, MemberStatus.sos);
  }

  // ── إرسال طلب إسعاف (طريقة مبسطة للتوافق) ───────────
  Future<void> sendEmergencyRequest({
    required String patientId,
    required String reporterId,
    required String emergencyType,
    required String description,
    String? location,
  }) async {
    final patient = state.members.firstWhere((m) => m.id == patientId);
    final reporter = state.members.firstWhere((m) => m.id == reporterId);
    
    await sendEmergencyForMember(
      patient: patient,
      reporter: reporter,
      emergencyType: emergencyType,
      description: description,
      location: location,
    );
  }

  // ── إلغاء الحالة الطارئة ─────────────────────────────
  void resolveEmergency(String memberId) {
    updateStatus(memberId, MemberStatus.safe);
    if (state.activeSOSMemberId == memberId) {
      state = state.copyWith(clearSOS: true);
    }
  }

  // ── الحصول على تقارير فرد ────────────────────────────
  List<EmergencyReport> reportsForMember(String memberId) {
    return state.reports.where((r) => r.patient.id == memberId).toList();
  }

  // ── الحصول على العضو النشط في حالة الطوارئ ──────────
  FamilyMember? get activeSOSMember {
    if (state.activeSOSMemberId == null) return null;
    try {
      return state.members.firstWhere((m) => m.id == state.activeSOSMemberId);
    } catch (e) {
      return null;
    }
  }

  // ── تحديث موقع فرد ───────────────────────────────────
  void updateLocation(String memberId, String location, {double? lat, double? lng}) {
    final updatedMembers = state.members.map((member) {
      if (member.id == memberId) {
        return member.copyWith(
          lastLocation: location,
          lastLat: lat,
          lastLng: lng,
          lastSeen: DateTime.now(),
        );
      }
      return member;
    }).toList();
    
    state = state.copyWith(members: updatedMembers);
  }

  // ── إعادة تعيين جميع البيانات ────────────────────────
  void resetToMockData() {
    state = FamilyState(members: _mockFamily);
  }

  // ── تنظيف التقارير القديمة ───────────────────────────
  void clearOldReports({Duration olderThan = const Duration(days: 30)}) {
    final cutoff = DateTime.now().subtract(olderThan);
    state = state.copyWith(
      reports: state.reports.where((r) => r.time.isAfter(cutoff)).toList(),
    );
  }
}

// ────────────────────────────────────────────────────────
//  Providers
// ────────────────────────────────────────────────────────
final familyProvider = NotifierProvider<FamilyNotifier, FamilyState>(
  FamilyNotifier.new,
);

// Provider مساعد للوصول إلى العضو النشط في الطوارئ
final activeSOSMemberProvider = Provider<FamilyMember?>((ref) {
  return ref.watch(familyProvider).activeSOSMemberId != null
      ? ref.watch(familyProvider).members.firstWhere(
          (m) => m.id == ref.watch(familyProvider).activeSOSMemberId,
          orElse: () => throw Exception('Member not found'),
        )
      : null;
});

// Provider مساعد لإحصائيات العائلة
final familyStatsProvider = Provider<Map<String, int>>((ref) {
  final members = ref.watch(familyProvider).members;
  return {
    'total': members.length,
    'safe': members.where((m) => m.status == MemberStatus.safe).length,
    'danger': members.where((m) => m.status == MemberStatus.danger).length,
    'sos': members.where((m) => m.status == MemberStatus.sos).length,
    'children': members.where((m) => m.isChild).length,
    'adults': members.where((m) => !m.isChild).length,
  };
});
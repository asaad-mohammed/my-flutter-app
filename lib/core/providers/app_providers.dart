// lib/core/providers/app_providers.dart
// ════════════════════════════════════════════════════════
//  core/providers/app_providers.dart
//  ✅ languageProvider — تغيير اللغة
//  ✅ sessionProvider  — إدارة الجلسة + دخول الضيف
//  ✅ authProvider     — تسجيل الدخول بالبيانات
//  ✅ familyProvider   — إدارة العائلة
//  ✅ zoneProvider     — تحليل البيئة الصحية
// ════════════════════════════════════════════════════════
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_users.dart';
import '../models/family_member.dart';
import 'family_provider.dart';
import 'zone_provider.dart';

// ════════════════════════════════════════════════════════
//  1. languageProvider — عربي/إنجليزي
// ════════════════════════════════════════════════════════
class LanguageNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool isArabic) => state = isArabic;
  void toggle() => state = !state;
}

final languageProvider = NotifierProvider<LanguageNotifier, bool>(
  LanguageNotifier.new,
);

// ════════════════════════════════════════════════════════
//  2. sessionProvider — بيانات المستخدم المسجّل
// ════════════════════════════════════════════════════════
class SessionNotifier extends Notifier<MockUser?> {
  @override
  MockUser? build() => null;

  void login(MockUser user) => state = user;
  void loginAsGuest() => state = guestUser;
  void logout() => state = null;
}

final sessionProvider = NotifierProvider<SessionNotifier, MockUser?>(
  SessionNotifier.new,
);

// ════════════════════════════════════════════════════════
//  3. authProvider — حالة تسجيل الدخول
// ════════════════════════════════════════════════════════
enum AuthStatus { idle, loading, success, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  const AuthState({this.status = AuthStatus.idle, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) => AuthState(
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<bool> login({
    required String id,
    required String password,
    required bool isResident,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    await Future.delayed(const Duration(milliseconds: 900));

    final user = mockUsers.where((u) {
      return u.id == id.trim() &&
          u.password == password.trim() &&
          u.isResident == isResident;
    }).firstOrNull;

    if (user != null) {
      ref.read(sessionProvider.notifier).login(user);
      state = state.copyWith(status: AuthStatus.success);
      return true;
    } else {
      final isAr = ref.read(languageProvider);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: isAr
            ? 'بيانات الدخول غير صحيحة. تأكد من المعلومات وحاول مجدداً.'
            : 'Invalid credentials. Please check and try again.',
      );
      return false;
    }
  }

  void resetError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState();
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ════════════════════════════════════════════════════════
//  4. familyProvider — إدارة العائلة
// ════════════════════════════════════════════════════════
final familyProvider = NotifierProvider<FamilyNotifier, FamilyState>(
  FamilyNotifier.new,
);

// ════════════════════════════════════════════════════════
//  5. zoneProvider — تحليل البيئة الصحية
// ════════════════════════════════════════════════════════
final zoneProvider = NotifierProvider<ZoneNotifier, ZoneState>(
  ZoneNotifier.new,
);

// ════════════════════════════════════════════════════════
//  6. activeSOSMemberProvider — العضو النشط في الطوارئ
// ════════════════════════════════════════════════════════
final activeSOSMemberProvider = Provider<FamilyMember?>((ref) {
  final state = ref.watch(familyProvider);
  if (state.activeSOSMemberId == null) return null;
  try {
    return state.members.firstWhere((m) => m.id == state.activeSOSMemberId);
  } catch (_) {
    return null;
  }
});

// ════════════════════════════════════════════════════════
//  7. familyStatsProvider — إحصائيات العائلة
// ════════════════════════════════════════════════════════
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
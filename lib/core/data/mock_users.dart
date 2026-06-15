// ════════════════════════════════════════════════════════
//  core/data/mock_users.dart
//  ✅ بيانات مستخدمين تجريبية + دعم المستخدم الضيف
// ════════════════════════════════════════════════════════

class MockUser {
  final String id;
  final String password;
  final String nameAr;
  final String nameEn;
  final String phone;
  final String bloodType;
  final int age;
  final bool isResident;
  final bool isGuest; 
  final String dateOfBirth;
  final String nationality;
  final String gender;
  final String email;
  final String chronicDiseases;
  final String allergies;
  final String insuranceNumber;
  final String insuranceExpiry;
  final String emergencyContact;
  final String emergencyPhone;
  final String userType; 

  const MockUser({
    required this.id,
    required this.password,
    required this.nameAr,
    required this.nameEn,
    required this.phone,
    required this.bloodType,
    required this.age,
    required this.isResident,
    this.isGuest = false,
    this.dateOfBirth = 'غير محدد',
    this.nationality = 'عراقي',
    this.gender = 'ذكر',
    this.email = '',
    this.chronicDiseases = 'لا يوجد',
    this.allergies = 'لا يوجد',
    this.insuranceNumber = 'غير متوفر',
    this.insuranceExpiry = 'غير متوفر',
    this.emergencyContact = 'لم يتم تحديده',
    this.emergencyPhone = '0',
    this.userType = 'resident',
  });
}

// ────────────────────────────────────────────────────────
//  قائمة المستخدمين التجريبيين
// ────────────────────────────────────────────────────────
final List<MockUser> mockUsers = [
  const MockUser(
    id: '199512345678',
    password: '1',
    nameAr: 'أحمد محمد العلي',
    nameEn: 'Ahmed Mohammed Al-Ali',
    phone: '+9641234567890',
    bloodType: 'O+',
    age: 30,
    isResident: true,
    userType: 'resident',
    dateOfBirth: '15/03/1993',
    nationality: 'عراقي',
    gender: 'ذكر',
    email: 'ahmed@example.com',
    chronicDiseases: 'ارتفاع ضغط الدم',
    allergies: 'البنسلين',
    insuranceNumber: 'INS-199512345',
    insuranceExpiry: '15/12/2025',
    emergencyContact: 'علي محمد (أخ)',
    emergencyPhone: '+9647711111111',
  ),
  const MockUser(
    id: '202001234567',
    password: '123456',
    nameAr: 'فاطمة حسن الزيدي',
    nameEn: 'Fatima Hassan Al-Zaidi',
    phone: '+9649876543210',
    bloodType: 'A+',
    age: 25,
    isResident: true,
    userType: 'resident',
    dateOfBirth: '22/07/1998',
    nationality: 'عراقية',
    gender: 'أنثى',
    email: 'fatima@example.com',
    chronicDiseases: 'لا يوجد',
    allergies: 'الأسبرين',
    insuranceNumber: 'INS-202001234',
    insuranceExpiry: '10/06/2026',
    emergencyContact: 'محمد الزيدي (أب)',
    emergencyPhone: '+9647722222222',
  ),
  const MockUser(
    id: 'V1234567',
    password: '1',
    nameAr: 'جون سميث',
    nameEn: 'John Smith',
    phone: '+11234567890',
    bloodType: 'B+',
    age: 35,
    isResident: false,
    userType: 'visitor',
    dateOfBirth: '10/10/1988',
    nationality: 'أمريكي',
    gender: 'ذكر',
    email: 'john.smith@example.com',
    chronicDiseases: 'لا يوجد',
    allergies: 'لا يوجد',
    insuranceNumber: 'VIS-V1234567',
    insuranceExpiry: '01/12/2025',
    emergencyContact: 'Mary Smith (الزوجة)',
    emergencyPhone: '+11234567891',
  ),
];

// مستخدم الضيف — يظهر بدون بيانات شخصية
final MockUser guestUser = MockUser(
  id: 'GUEST',
  password: '',
  nameAr: 'ضيف',
  nameEn: 'Guest',
  phone: 'غير متوفر',
  bloodType: 'غير معروف',
  age: 0,
  isResident: false,
  isGuest: true,
  userType: 'guest',
  dateOfBirth: 'غير معروف',
  nationality: 'غير محدد',
  gender: 'غير محدد',
  email: 'guest@example.com',
  chronicDiseases: 'غير معروفة',
  allergies: 'غير معروفة',
  insuranceNumber: 'غير متوفر',
  insuranceExpiry: 'غير متوفر',
  emergencyContact: 'لم يتم تحديده',
  emergencyPhone: 'لم يتم تحديده',
);
class AppConstants {
  // App Info
  static const String appName = 'Mahalla Xizmati';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String arizalarCollection = 'arizalar';
  static const String xodimlarCollection = 'xodimlar';
  static const String elonlarCollection = 'elonlar';
  static const String muammolarCollection = 'muammolar';
  static const String navbatlarCollection = 'navbatlar';
  static const String hisobotlarCollection = 'hisobotlar';
  static const String mahallaInfoCollection = 'mahalla_info';
  
  // User Roles
  static const String roleFuqaro = 'fuqaro';
  static const String roleAdmin = 'admin';
  
  // Ariza Status
  static const String arizaStatusYuborildi = 'yuborildi';
  static const String arizaStatusKorilmoqda = 'ko\'rilmoqda';
  static const String arizaStatusBajarildi = 'bajarildi';
  static const String arizaStatusRad = 'rad_etildi';
  
  // Muammo Status
  static const String muammoStatusQabulQilindi = 'qabul_qilindi';
  static const String muammoStatusKorilmoqda = 'ko\'rilmoqda';
  static const String muammoStatusHalQilindi = 'hal_qilindi';
  
  // Muammo Types
  static const String muammoTypeYol = 'yo\'l';
  static const String muammoTypeYoruglik = 'yorug\'lik';
  static const String muammoTypeSuv = 'suv';
  static const String muammoTypeElektr = 'elektr';
  static const String muammoTypeGaz = 'gaz';
  static const String muammoTypeBoshqa = 'boshqa';
  
  // Ariza Categories
  static const List<String> arizaCategories = [
    'Guvohnoma',
    'Ma\'lumotnoma',
    'Yordam so\'rash',
    'Shikoyat',
    'Taklif',
    'Boshqa',
  ];
  
  // Navbat Status
  static const String navbatStatusTasdiqlangan = 'tasdiqlangan';
  static const String navbatStatusBekorQilingan = 'bekor_qilingan';
  static const String navbatStatusTugatilgan = 'tugatilgan';
  
  // Shared Preferences Keys
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  
  // Pagination
  static const int itemsPerPage = 20;
  
  // Image Upload
  static const int maxImageSizeMB = 5;
  static const int imageQuality = 80;
  
  // Date Formats
  static const String dateFormat = 'dd.MM.yyyy';
  static const String dateTimeFormat = 'dd.MM.yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  
  // Validation
  static const int minPhoneLength = 9;
  static const int maxPhoneLength = 12;
  static const int minPasswordLength = 6;
  static const int maxArizaTextLength = 1000;
  
  // Error Messages
  static const String errorNoInternet = 'Internet aloqasi yo\'q';
  static const String errorServerError = 'Server xatosi. Qaytadan urinib ko\'ring';
  static const String errorUnknown = 'Noma\'lum xato yuz berdi';
  static const String errorInvalidPhone = 'Telefon raqam noto\'g\'ri';
  static const String errorInvalidOTP = 'Tasdiqlash kodi noto\'g\'ri';
  
  // Success Messages
  static const String successArizaSent = 'Ariza muvaffaqiyatli yuborildi';
  static const String successMuammoSent = 'Muammo muvaffaqiyatli yuborildi';
  static const String successNavbatBooked = 'Navbat muvaffaqiyatli band qilindi';
  static const String successProfileUpdated = 'Profil yangilandi';
}

# 🔥 Firebase Sozlash - Muhim!

## ⚠️ DIQQAT: Ilova Firebase'siz ishlamaydi!

Hozirda loyihada mock Firebase konfiguratsiyasi mavjud. Ilovani ishga tushirish uchun quyidagi qadamlarni bajaring:

## 1. Firebase Console'da loyiha yaratish

1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. "Add project" tugmasini bosing
3. Loyiha nomini kiriting: `mahalla-app`
4. Google Analytics'ni yoqing (ixtiyoriy)
5. Loyihani yarating

## 2. Android ilovasini qo'shish

### 2.1. Firebase Console'da Android app qo'shish

1. Firebase Console'da Android ikonkasini bosing
2. Android package name kiriting: `com.example.mahalla_app`
3. App nickname: `Mahalla App` (ixtiyoriy)
4. Debug signing certificate SHA-1 (ixtiyoriy, keyinchalik qo'shish mumkin)
5. "Register app" tugmasini bosing

### 2.2. google-services.json yuklab olish

1. `google-services.json` faylini yuklab oling
2. Faylni `android/app/` papkasiga joylashtiring

```
mahalla_app/
└── android/
    └── app/
        └── google-services.json  ← Bu yerga
```

### 2.3. Tekshirish

```bash
# Fayl mavjudligini tekshiring
ls android/app/google-services.json
```

## 3. FlutterFire CLI bilan konfiguratsiya

### 3.1. FlutterFire CLI o'rnatish

```bash
dart pub global activate flutterfire_cli
```

### 3.2. Firebase loyihasini ulash

```bash
# Loyiha papkasida
cd mahalla_app

# Firebase konfiguratsiya
flutterfire configure
```

Bu buyruq:
- Firebase loyihangizni tanlaydi
- Barcha platformalar uchun konfiguratsiya yaratadi
- `lib/firebase_options.dart` faylini avtomatik generatsiya qiladi (hozirgi mock faylni almashtiradi)

### 3.3. Loyihani tanlash

Terminal'da:
1. Firebase account'ingizni tanlang
2. Loyihani tanlang: `mahalla-app`
3. Platformalarni tanlang: Android, iOS (kerak bo'lsa)

## 4. Firebase xizmatlarini yoqish

### 4.1. Authentication (Phone)

1. Firebase Console → Build → Authentication
2. "Get Started" tugmasini bosing
3. Sign-in method → Phone → Enable
4. Save

**Test telefon raqamlari qo'shish (development uchun):**
1. Phone numbers for testing → Add phone number
2. Phone: `+998901234567`
3. Code: `123456`
4. Add

### 4.2. Firestore Database

1. Firebase Console → Build → Firestore Database
2. "Create database" tugmasini bosing
3. Start in **test mode** (development uchun)
4. Location: `asia-south1` (yoki yaqin region)
5. Enable

**Security Rules (keyinchalik):**
- Production'ga chiqishdan oldin security rules yozish kerak
- SETUP_GUIDE.md da to'liq rules mavjud

### 4.3. Storage

1. Firebase Console → Build → Storage
2. "Get Started" tugmasini bosing
3. Start in **test mode**
4. Location: Firestore bilan bir xil
5. Done

### 4.4. Cloud Messaging (FCM)

Avtomatik yoqilgan bo'ladi. Qo'shimcha sozlash kerak emas.

## 5. Ilovani ishga tushirish

```bash
# Clean build
flutter clean
flutter pub get

# Run
flutter run
```

## 6. Xatolarni hal qilish

### Xato: "google-services.json not found"

**Yechim:**
```bash
# Faylni to'g'ri joyga qo'ying
cp ~/Downloads/google-services.json android/app/
```

### Xato: "Firebase project not found"

**Yechim:**
```bash
# FlutterFire CLI ni qayta ishga tushiring
flutterfire configure
```

### Xato: "Default FirebaseApp is not initialized"

**Yechim:**
- `firebase_options.dart` fayli to'g'ri generatsiya qilinganligini tekshiring
- `main.dart` da `Firebase.initializeApp(options: ...)` chaqirilganligini tekshiring

## 7. Production uchun

### Security Rules

Production'ga chiqishdan oldin:
1. Firestore Security Rules yozing (SETUP_GUIDE.md ga qarang)
2. Storage Security Rules yozing
3. Test mode'dan production mode'ga o'ting

### SHA-1 Certificate

Google Sign-In yoki Phone Auth uchun:
```bash
# Debug SHA-1
cd android
./gradlew signingReport

# Release SHA-1 (keystore yaratganingizdan keyin)
keytool -list -v -keystore your-release-key.jks
```

SHA-1 ni Firebase Console → Project Settings → Your apps → Android app → Add fingerprint ga qo'shing.

## 8. Tekshirish

Hammasi to'g'ri sozlanganligini tekshirish:

```bash
# Build qiling
flutter build apk --debug

# Agar xatosiz build bo'lsa, hammasi to'g'ri!
```

## 📞 Yordam

Muammo bo'lsa:
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- SETUP_GUIDE.md faylini o'qing

---

**Eslatma:** Bu qadamlarni bajarmasdan ilova ishlamaydi! Firebase sozlash majburiy.

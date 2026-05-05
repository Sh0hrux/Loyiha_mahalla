# Loyiha Strukturasi

## 📁 Papka tuzilishi

```
mahalla_app/
├── android/                    # Android platform kodlari
├── ios/                        # iOS platform kodlari
├── web/                        # Web platform kodlari
├── assets/                     # Statik fayllar
│   ├── images/                # Rasmlar
│   └── icons/                 # Ikonkalar
├── lib/                       # Asosiy Dart kodlari
│   ├── main.dart             # Kirish nuqtasi
│   ├── app/                  # Ilova konfiguratsiyasi
│   │   ├── router.dart       # GoRouter marshrutlari
│   │   └── theme.dart        # Ilova temalari
│   ├── core/                 # Umumiy resurslar
│   │   ├── constants/        # Konstantalar
│   │   │   └── app_constants.dart
│   │   ├── utils/            # Yordamchi funksiyalar
│   │   └── widgets/          # Umumiy widgetlar
│   │       ├── loading_widget.dart
│   │       ├── empty_state_widget.dart
│   │       ├── error_widget.dart
│   │       └── custom_app_bar.dart
│   ├── features/             # Feature modullari
│   │   ├── auth/            # Autentifikatsiya
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── user_model.dart
│   │   │   │   └── repositories/
│   │   │   │       └── auth_repository.dart
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       │   ├── login_page.dart
│   │   │       │   ├── otp_verification_page.dart
│   │   │       │   └── complete_profile_page.dart
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   │           └── auth_provider.dart
│   │   ├── ariza/           # Arizalar moduli
│   │   │   ├── data/
│   │   │   │   ├── models/
│   │   │   │   │   └── ariza_model.dart
│   │   │   │   └── repositories/
│   │   │   └── presentation/
│   │   │       ├── pages/
│   │   │       ├── widgets/
│   │   │       └── providers/
│   │   ├── mahalla_info/    # Mahalla ma'lumoti
│   │   ├── xodimlar/        # Xodimlar
│   │   ├── hisobotlar/      # Hisobotlar
│   │   ├── elonlar/         # E'lonlar
│   │   ├── muammo/          # Muammo bildirish
│   │   ├── statistika/      # Statistika
│   │   └── navbat/          # Online navbat
│   ├── services/            # Xizmatlar
│   │   ├── firebase_service.dart
│   │   ├── notification_service.dart
│   │   └── pdf_service.dart
│   └── l10n/                # Lokalizatsiya
│       └── app_uz.arb
├── test/                     # Test fayllar
├── pubspec.yaml             # Paket konfiguratsiyasi
├── l10n.yaml                # Lokalizatsiya konfiguratsiyasi
├── README.md                # Loyiha haqida
├── SETUP_GUIDE.md           # O'rnatish qo'llanmasi
└── PROJECT_STRUCTURE.md     # Bu fayl
```

## 🏗️ Arxitektura

Loyiha **Clean Architecture** va **Feature-First** yondashuvidan foydalanadi.

### Feature tuzilishi

Har bir feature quyidagi qatlamlardan iborat:

```
feature_name/
├── data/                    # Ma'lumotlar qatlami
│   ├── models/             # Ma'lumot modellari
│   ├── repositories/       # Repository implementatsiyalari
│   └── datasources/        # Ma'lumot manbalari (API, local DB)
├── domain/                  # Biznes logika qatlami
│   ├── entities/           # Biznes obyektlari
│   ├── repositories/       # Repository interfeyslari
│   └── usecases/           # Biznes logika
└── presentation/            # UI qatlami
    ├── pages/              # Sahifalar
    ├── widgets/            # Feature-specific widgetlar
    └── providers/          # State management (Riverpod)
```

## 📦 Asosiy paketlar

### State Management
- **flutter_riverpod** - State management
- **riverpod_annotation** - Code generation

### Navigation
- **go_router** - Deklarativ routing

### Backend
- **firebase_core** - Firebase asosi
- **firebase_auth** - Autentifikatsiya
- **cloud_firestore** - Database
- **firebase_storage** - Fayl saqlash
- **firebase_messaging** - Push notifications

### UI
- **google_fonts** - Shriftlar
- **fl_chart** - Grafiklar
- **cached_network_image** - Rasm keshlash
- **shimmer** - Loading animatsiyalar

### Utilities
- **shared_preferences** - Local storage
- **image_picker** - Rasm tanlash
- **permission_handler** - Ruxsatlar
- **url_launcher** - URL ochish
- **google_maps_flutter** - Xarita
- **geolocator** - Geolokatsiya
- **pdf** - PDF generatsiya
- **printing** - PDF chop etish
- **excel** - Excel export

## 🔄 Ma'lumot oqimi

```
UI (Widget)
    ↓
Provider (Riverpod)
    ↓
Repository
    ↓
Firebase Service
    ↓
Firebase Backend
```

## 🎨 Tema tizimi

Ilova ikkita temani qo'llab-quvvatlaydi:
- Light Theme (Yorug' rejim)
- Dark Theme (Qorong'u rejim)

Asosiy rang: **Ko'k (#1565C0)**

## 🌐 Lokalizatsiya

Hozircha faqat O'zbek tili qo'llab-quvvatlanadi.

Kelajakda qo'shilishi mumkin:
- Rus tili
- Ingliz tili

## 🔐 Xavfsizlik

### Firestore Security Rules
- Foydalanuvchilar faqat o'z ma'lumotlarini ko'rishi va tahrirlashi mumkin
- Admin rollari maxsus huquqlarga ega
- Barcha operatsiyalar autentifikatsiya talab qiladi

### Storage Security Rules
- Fayllar faqat egasi tomonidan yuklanishi mumkin
- Barcha foydalanuvchilar o'qiy oladi
- Admin barcha fayllarni boshqarishi mumkin

## 📱 Platformalar

Loyiha quyidagi platformalarni qo'llab-quvvatlaydi:
- ✅ Android
- ✅ iOS
- ⏳ Web (qisman)

## 🧪 Test

Test fayllar `test/` papkasida joylashgan.

Test turlari:
- Unit tests
- Widget tests
- Integration tests

## 📝 Kod standartlari

- **Dart Style Guide** ga amal qilish
- **flutter_lints** qoidalariga rioya qilish
- Har bir fayl bitta class yoki funksiyani o'z ichiga olishi kerak
- Nomlar aniq va tushunarli bo'lishi kerak
- Izohlar faqat kerak bo'lganda yoziladi

## 🚀 Build va Deploy

### Development
```bash
flutter run
```

### Production (Android)
```bash
flutter build apk --release
flutter build appbundle --release
```

### Production (iOS)
```bash
flutter build ios --release
```

## 📊 Firestore Collections

| Collection | Tavsif | Maydonlar |
|-----------|--------|-----------|
| users | Foydalanuvchilar | id, phoneNumber, fullName, role, address, passport... |
| arizalar | Arizalar | id, userId, category, description, status, imageUrls... |
| xodimlar | Xodimlar | id, fullName, position, phone, photoUrl... |
| elonlar | E'lonlar | id, title, description, imageUrl, createdAt... |
| muammolar | Muammolar | id, userId, type, description, location, status... |
| navbatlar | Navbatlar | id, userId, date, time, status... |
| hisobotlar | Hisobotlar | id, month, year, data, createdAt... |
| mahalla_info | Mahalla ma'lumoti | name, address, phone, workingHours... |

## 🔄 Git Workflow

1. `main` - Production branch
2. `develop` - Development branch
3. `feature/*` - Feature branches
4. `bugfix/*` - Bug fix branches

## 📞 Yordam

Savollar yoki muammolar bo'lsa:
- GitHub Issues
- Email: support@mahalla.uz
- Telegram: @mahalla_support

---

**Oxirgi yangilanish**: 2026-05-03

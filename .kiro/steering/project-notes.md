# Loyiha eslatmalari (Kiro uchun ichki hujjat)

> Bu fayl Kiro AI uchun yozilgan. Maqsad: loyiha tuzilishini har safar
> noldan tekshirmaslik. Yangi o'zgarish kiritsang, shu faylni ham yangilab bor.

## Umumiy ma'lumot
- **Nomi:** `mahalla_app` ("Mahalla Xizmati")
- **Turi:** Flutter mobil ilova (Android asosiy, iOS/Web qisman)
- **Til:** Interfeys to'liq o'zbekcha (`uz_UZ`)
- **Maqsad:** Mahalla qo'mitasi rasmiy ilovasi — arizalar, muammolar, navbat,
  e'lonlar, eslatmalar, xodimlar va hisobotlarni boshqarish.

## Texnologiyalar (stack)
- **State management:** `flutter_riverpod` (^2.5) + `riverpod_generator`
- **Navigatsiya:** `go_router` (^14) — `lib/app/router.dart`
- **Backend:** Firebase (core, auth, cloud_firestore, storage, messaging)
- **UI:** `google_fonts`, `fl_chart`, `cached_network_image`, `shimmer`, `flutter_svg`
- **Boshqa:** `pdf`/`printing`/`excel` (hisobot), `google_maps_flutter`+`geolocator`,
  `flutter_local_notifications`, `image_picker`, `permission_handler`.

## Arxitektura — Feature-first + qatlamlar
Har bir feature `lib/features/<nom>/` ichida shu tuzilishda:
```
features/<nom>/
  data/
    models/        -> <Nom>Model (fromFirestore / toFirestore / copyWith)
    repositories/  -> Firestore bilan ishlash (CRUD)
  presentation/
    pages/         -> UI ekranlari
    providers/     -> Riverpod providerlari (Repository, Stream, Notifier)
```
Umumiy kod:
- `lib/core/constants/` — `AppConstants` (kollektsiya nomlari, statuslar, xabarlar).
- `lib/core/models/` — `mahalla_model.dart`.
- `lib/core/widgets/` — qayta ishlatiladigan widgetlar (pastga qara).
- `lib/core/services/` — `mahalla_setup_service.dart` (mahallalarni bir marta seed qiladi).
- `lib/services/` — `firebase_service.dart`, `notification_service.dart`, `pdf_service.dart`.
- `lib/app/` — `router.dart`, `theme.dart` (`AppTheme.primaryColor`, `errorColor`, light/dark).

## Mavjud feature'lar
`admin`, `ariza`, `auth`, `elon`, `eslatma`, `home`, `mahalla_info`,
`muammo`, `navbat`, `profile`, `reports`, `splash`, `users`, `xodimlar`.

## Routing (lib/app/router.dart)
- `routerProvider` -> `GoRouter`, `initialLocation: '/splash'`.
- Redirect mantiqi `currentUserProvider` (auth) ga qarab:
  - Yuklanayotganda -> `/splash`
  - Login bo'lmagan -> `/login` (faqat `/login`, `/signup`, `/forgot-password` ruxsat)
  - Profil to'liq emas -> `/complete-profile`
  - Admin -> `/admin/dashboard`, oddiy foydalanuvchi -> `/home`
- Asosiy yo'llar: `/home`, `/arizalar`, `/muammolar`, `/navbatlar`, `/elonlar`,
  `/eslatmalar`, `/xodimlar`, `/profile`, `/admin/dashboard`,
  `/admin/foydalanuvchilar`, `/admin/hisobotlar`.
- Detal sahifalar `:id` param bilan: `/ariza/:id`, `/muammo/:id`, `/navbat/:id`,
  `/elon/:id`, `/eslatma-detail/:id`.

## Foydalanuvchi rollari
- `fuqaro` (oddiy) va `admin`. `AppConstants.roleFuqaro` / `roleAdmin`.
- Rol `users` kollektsiyasidagi `role` maydonida saqlanadi.

## Eslatma (notification) feature — muhim eslatmalar
- Model: `EslatmaModel` (`data/models/eslatma_model.dart`).
  - `EslatmaType` enum: soliq, kommunal, tadbir, yigilish, xizmat, umumiy, muhim
    (har birida `label` va `emoji`). `typeColor` getter HEX rang qaytaradi.
  - Maydonlar: `userId`, `adminId`, `type`, `title`, **`message`** (xabar matni),
    `isRead`, `createdAt`, `expiresAt`, `isUrgent`. Getterlar: `isExpired`, `isNew`.
- Providerlar (`presentation/providers/eslatma_provider.dart`):
  - `userEslatmalarProvider` (stream), `unreadEslatmalarCountProvider` (stream),
    `allEslatmalarProvider` (admin), `eslatmaNotifierProvider` (CRUD action),
    `eslatmaByIdProvider`, `eslatmaStatsProvider`.

## ⚠️ Muhim qoidalar / tez-tez uchraydigan xatolar
1. **`EmptyStateWidget`** (`core/widgets/empty_state_widget.dart`) parametrlari:
   `icon`, `title`, **`subtitle`** (`message` EMAS!), `onActionPressed`, `actionLabel`.
   - Xato qilma: `message:` deb yozsang compile error chiqadi.
2. **`CustomErrorWidget`** (`core/widgets/error_widget.dart`) parametri esa **`message`**
   (`required String message`, `onRetry`). Ya'ni ikki widgetda nomi har xil — adashma.
3. **Firebase:** `lib/firebase_options.dart` Android uchun haqiqiy qiymatlarga ega
   (`google-services.json` ham `android/app/` da mavjud). iOS/Web qiymatlari placeholder.
   - Firebase project: `mahalla-2520d`, senderId `221831090339`.
4. **Test:** `test/widget_test.dart` to'liq ilovani pump qilmaydi (Firebase init
   yo'qligi sabab). Oddiy smoke test. To'liq UI test kerak bo'lsa Firebase mock kerak.
5. **Firestore composite index:** `where(...) + orderBy(boshqa maydon)` birikmasi
   index talab qiladi va `failed-precondition` xatosi beradi. Yechim: `orderBy` ni
   olib tashlab, saralashni Dart'da (`list.sort(...)`) qilish. Misol: `getUserEslatmalar`.
   - Faqat `==` filtrlar (masalan `getUnreadCount`) index talab qilmaydi.
6. **Auth xatolari:** `auth_repository.dart` da `FirebaseAuthException` tutilib,
   `_mapAuthError()` orqali tushunarli o'zbekcha xabarga aylantiriladi (`AuthException`).
   Yangi auth metod yozsang, xom `e.toString()` ni ko'rsatma — shu pattern'dan foydalan.

## Navigatsiya eslatmasi
- Admin login qilsa, router uni `/home` dan **`/admin/dashboard`** ga yo'naltiradi.
  Shuning uchun admin oddiy foydalanuvchi menyusini (home grid) ko'rmaydi.
- Admin uchun bo'lim havolalari `admin_dashboard_page.dart` da ("Tezkor Harakatlar").
  Eslatma kartalari ("Eslatma yuborish", "Eslatmalar") shu yerga qo'shilgan.
- Oddiy foydalanuvchi (fuqaro) menyusi `home_page.dart` da.

## Lint holati (flutter analyze)
- **`No issues found!`** — error, warning va info'lar hammasi tozalangan (0 ta).
- Qo'llangan tuzatishlar:
  - `withOpacity(x)` -> `withValues(alpha: x)` (29 faylda).
  - `print(...)` -> `debugPrint(...)` (router, services, repolar; `foundation` import qo'shilgan).
  - `Table.fromTextArray` -> `TableHelper.fromTextArray` (`pdf_service.dart`).
  - `use_build_context_synchronously`: `if (mounted)` -> `if (context.mounted)`.
  - `dart fix --apply`: const, unused_import, final fields, `value`->`initialValue`,
    `activeColor`->`activeThumbColor` va h.k. (65 ta).
- Yangi kod yozganda shu uslublarga amal qil (print ishlatma, withOpacity ishlatma).

## Build / ishga tushirish
```
flutter pub get
flutter analyze        # error bo'lmasligi kerak
flutter test           # smoke test o'tadi
flutter run            # Firebase to'g'ri sozlangach
```

## Tuzatish tarixi (oxirgi sessiya)
- `eslatmalar_page.dart`: `EmptyStateWidget(message:)` -> `subtitle:` (2 joyda).
- `lib/firebase_options.dart` yaratildi (placeholder qiymatlar bilan).
- `test/widget_test.dart`: yo'q `MyApp`/counter testi -> oddiy smoke testga almashtirildi.
- `assets/images/`, `assets/icons/` papkalari `.gitkeep` bilan yaratildi (pubspec warning).
- **Lint tozalash:** 343 ta muammo -> 0 ga tushirildi (`No issues found!`).
  Ishlatilmagan `_MenuCard`, `_searchQuery`, `_selectedMahallaName` olib tashlandi.
  `withOpacity`->`withValues`, `print`->`debugPrint`, `Table.fromTextArray`->
  `TableHelper.fromTextArray`, `context.mounted` va `dart fix` qo'llanildi.
- Holat: `flutter analyze` toza, `flutter test` o'tadi.

# Mahalla Qo'mitasi - O'rnatish Qo'llanmasi

## 📋 Talablar

- Flutter SDK 3.0 yoki yuqori
- Dart SDK 3.0 yoki yuqori
- Android Studio / VS Code
- Firebase account

## 🚀 Bosqichma-bosqich o'rnatish

### 1. Loyihani klonlash

```bash
git clone <repository-url>
cd mahalla_app
```

### 2. Paketlarni o'rnatish

```bash
flutter pub get
```

### 3. Firebase sozlash

#### 3.1. Firebase Console'da loyiha yaratish

1. [Firebase Console](https://console.firebase.google.com/) ga kiring
2. "Add project" tugmasini bosing
3. Loyiha nomini kiriting: `mahalla-app`
4. Google Analytics'ni yoqing (ixtiyoriy)
5. Loyihani yarating

#### 3.2. Android ilovasini qo'shish

1. Firebase Console'da Android ikonkasini bosing
2. Android package name kiriting: `com.mahalla.app` (yoki o'zingizniki)
3. `google-services.json` faylini yuklab oling
4. Faylni `android/app/` papkasiga joylashtiring

#### 3.3. iOS ilovasini qo'shish

1. Firebase Console'da iOS ikonkasini bosing
2. iOS bundle ID kiriting: `com.mahalla.app` (yoki o'zingizniki)
3. `GoogleService-Info.plist` faylini yuklab oling
4. Faylni `ios/Runner/` papkasiga joylashtiring

#### 3.4. Firebase xizmatlarini yoqish

Firebase Console'da quyidagi xizmatlarni yoqing:

**Authentication:**
1. Build → Authentication → Get Started
2. Sign-in method → Phone → Enable
3. Test phone numbers qo'shing (development uchun)

**Firestore Database:**
1. Build → Firestore Database → Create database
2. Start in test mode (keyinchalik security rules qo'shiladi)
3. Location tanlang: `asia-south1` (yoki yaqin region)

**Storage:**
1. Build → Storage → Get Started
2. Start in test mode
3. Location tanlang

**Cloud Messaging:**
1. Build → Cloud Messaging
2. Avtomatik yoqilgan bo'ladi

### 4. Firebase CLI o'rnatish (ixtiyoriy)

```bash
npm install -g firebase-tools
firebase login
```

### 5. FlutterFire CLI bilan konfiguratsiya

```bash
# FlutterFire CLI o'rnatish
dart pub global activate flutterfire_cli

# Firebase loyihasini ulash
flutterfire configure
```

Bu buyruq avtomatik ravishda:
- Firebase loyihangizni tanlaydi
- Barcha platformalar uchun konfiguratsiya yaratadi
- `firebase_options.dart` faylini generatsiya qiladi

### 6. Android sozlamalari

`android/app/build.gradle` faylida minimum SDK versiyasini tekshiring:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Minimum 21 bo'lishi kerak
        targetSdkVersion 34
    }
}
```

### 7. iOS sozlamalari

`ios/Podfile` faylida platform versiyasini tekshiring:

```ruby
platform :ios, '13.0'  # Minimum 13.0 bo'lishi kerak
```

Keyin:

```bash
cd ios
pod install
cd ..
```

### 8. Firestore Security Rules

Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Arizalar collection
    match /arizalar/{arizaId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Xodimlar collection
    match /xodimlar/{xodimId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // E'lonlar collection
    match /elonlar/{elonId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Muammolar collection
    match /muammolar/{muammoId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Navbatlar collection
    match /navbatlar/{navbatId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.userId || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
    
    // Hisobotlar collection (faqat admin)
    match /hisobotlar/{hisobotId} {
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Mahalla info collection
    match /mahalla_info/{docId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

### 9. Storage Security Rules

Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /arizalar/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /muammolar/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /elonlar/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /xodimlar/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### 10. Test foydalanuvchi yaratish

Firebase Console → Authentication → Users → Add user

Yoki ilovada ro'yxatdan o'ting va Firestore'da `users` collection'ida `role` ni `admin` ga o'zgartiring.

### 11. Ilovani ishga tushirish

```bash
# Android
flutter run

# iOS
flutter run

# Web
flutter run -d chrome
```

## 🔧 Muammolarni hal qilish

### Gradle xatosi (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Pod xatosi (iOS)

```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Firebase xatosi

`firebase_options.dart` faylini qayta generatsiya qiling:

```bash
flutterfire configure
```

## 📱 Test qilish

### Test telefon raqamlari

Firebase Console → Authentication → Sign-in method → Phone → Test phone numbers

Qo'shing:
- Phone: +998901234567
- Code: 123456

## 🎯 Keyingi qadamlar

1. ✅ Firebase sozlandi
2. ⏳ Home page yaratish
3. ⏳ Ariza moduli
4. ⏳ Boshqa modullar

## 📞 Yordam

Muammo yuzaga kelsa:
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

---

**Eslatma**: Bu qo'llanma development muhiti uchun. Production uchun qo'shimcha sozlamalar kerak bo'ladi.

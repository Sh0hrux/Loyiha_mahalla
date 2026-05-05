# 🔥 Tezkor Yechim - Firebase Phone Auth Xatosi

## Xato: "We have blocked all requests from this device due to unusual activity"

Bu xato Firebase'ning himoya mexanizmi. Development paytida test telefon raqamlaridan foydalanish kerak.

## ✅ Yechim - Test Telefon Raqami Qo'shish

### 1. Firebase Console'ga kiring
[https://console.firebase.google.com/](https://console.firebase.google.com/)

### 2. Loyihangizni tanlang
`mahalla-app` yoki qanday nom bergan bo'lsangiz

### 3. Authentication → Sign-in method
1. Chap menyu: **Build** → **Authentication**
2. Yuqorida: **Sign-in method** tab
3. **Phone** ni toping va ustiga bosing

### 4. Test telefon raqamlari qo'shing
1. Pastga scroll qiling
2. **Phone numbers for testing** bo'limini toping
3. **Add phone number** tugmasini bosing

**Qo'shish kerak bo'lgan raqamlar:**

| Telefon raqam | Tasdiqlash kodi |
|---------------|-----------------|
| +998972551112 | 123456 |
| +998901234567 | 123456 |
| +998911111111 | 111111 |

### 5. Saqlash
**Save** tugmasini bosing

## 📱 Ilovada Foydalanish

Endi ilovada test raqamlaridan birini kiriting:

```
Telefon raqam: 972551112
(+998 avtomatik qo'shiladi)

Tasdiqlash kodi: 123456
```

**MUHIM:** Test raqamlar uchun haqiqiy SMS kelmaydi! Siz o'zingiz `123456` ni kiritasiz.

## 🔓 Blokirovkani Olib Tashlash

Agar qurilmangiz bloklangan bo'lsa:

### Variant 1: Kutish
- 1-2 soat kuting
- Firebase avtomatik blokni ochadi

### Variant 2: Boshqa qurilma
- Boshqa telefon yoki emulator ishlatib ko'ring

### Variant 3: Firebase Loyihani Qayta Yaratish
- Yangi Firebase loyiha yarating
- `flutterfire configure` qayta bajaring

## 🧪 Development uchun Eng Yaxshi Amaliyot

### 1. Faqat Test Raqamlardan Foydalaning
Development paytida **FAQAT** test raqamlardan foydalaning:
- ✅ +998972551112 → 123456
- ❌ Haqiqiy telefon raqamlar

### 2. Firebase Quota Limits
Bepul plan:
- **10 SMS/kun** - Juda kam!
- Test raqamlar **limitga kirmaydi** ✅

### 3. Emulator Ishlatish
```bash
# Android emulator
flutter run

# iOS simulator  
flutter run -d "iPhone 15"
```

## 🔧 Qo'shimcha Sozlamalar

### reCAPTCHA sozlash (Web uchun)

Agar web versiyada ishlatmoqchi bo'lsangiz:

1. Firebase Console → Authentication → Settings
2. **App verification** → **reCAPTCHA**
3. Domain qo'shing: `localhost`

### SHA-1 Fingerprint (Android)

Production uchun kerak:

```bash
cd android
./gradlew signingReport
```

SHA-1 ni Firebase Console → Project Settings → Your apps → Android app ga qo'shing.

## ✅ Tekshirish

Test raqam qo'shganingizdan keyin:

1. Ilovani qayta ishga tushiring
2. Test raqamni kiriting: `972551112`
3. "Kirish" tugmasini bosing
4. Tasdiqlash kodi: `123456`
5. Kirish muvaffaqiyatli bo'lishi kerak! ✅

## 🚨 Agar Yana Xato Bo'lsa

### Xato: "Invalid phone number"
- Telefon raqam formati: `+998XXXXXXXXX`
- Kod: `login_page.dart` da `+998` qo'shiladi

### Xato: "Invalid verification code"
- Test raqam uchun to'g'ri kodni kiriting
- Firebase Console'da qo'shgan kod bilan bir xil bo'lishi kerak

### Xato: "Network error"
- Internet aloqangizni tekshiring
- Firebase loyiha faol ekanligini tekshiring

## 📞 Yordam

Yana muammo bo'lsa:
1. Firebase Console'da Phone Auth yoqilganligini tekshiring
2. Test raqamlar to'g'ri qo'shilganligini tekshiring
3. `flutterfire configure` qayta bajaring

---

**Eslatma:** Production'da haqiqiy telefon raqamlar ishlatiladi, lekin development'da FAQAT test raqamlar!

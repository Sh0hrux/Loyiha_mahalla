# 🔥 Firestore Security Rules - Tezkor Tuzatish

## Muammo: "Foydalanuvchi ma'lumotlarini olishda xatolik"

Bu xato Firestore Security Rules tufayli yuzaga keladi. Yangi foydalanuvchi yaratilganda Firestore'ga yozish ruxsati yo'q.

---

## ✅ Yechim: Firestore Rules'ni Yangilash

### 1️⃣ Firebase Console'ga kiring:
👉 **https://console.firebase.google.com/u/0/project/mahalla-2520d/firestore/rules**

### 2️⃣ Quyidagi rules'ni kiriting:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{userId} {
      // Har kim o'z profilini o'qiy oladi
      allow read: if request.auth != null && request.auth.uid == userId;
      
      // Yangi foydalanuvchi o'zini yarata oladi
      allow create: if request.auth != null && request.auth.uid == userId;
      
      // Foydalanuvchi o'z profilini yangilashi mumkin
      allow update: if request.auth != null && request.auth.uid == userId;
      
      // Admin barcha foydalanuvchilarni ko'ra oladi
      allow read: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
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
      allow read, write: if request.auth != null && 
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

### 3️⃣ **Publish** tugmasini bosing

---

## 🚨 Agar Tezkor Test Kerak Bo'lsa (FAQAT DEVELOPMENT!)

Agar darhol test qilmoqchi bo'lsangiz, vaqtincha quyidagi rules'ni ishlating:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**⚠️ DIQQAT:** Bu rules FAQAT development uchun! Production'da yuqoridagi to'liq rules'ni ishlating.

---

## 📱 Ilovani Qayta Sinab Ko'ring

Rules yangilanganidan keyin:

1. Ilovani qayta ishga tushiring
2. Ro'yxatdan o'ting
3. Endi xatolik bo'lmasligi kerak!

---

## 🔍 Xatolikni Tekshirish

Agar yana xatolik bo'lsa, terminal'da quyidagi xabarlarni qidiring:

```
Firebase xatosi: permission-denied
Firebase xatosi: not-found
```

Bu xabarlar Firestore rules muammosini ko'rsatadi.

---

## ✅ To'g'ri Ishlashi Kerak

Rules to'g'ri sozlanganidan keyin:
- ✅ Yangi foydalanuvchi yaratiladi
- ✅ Profil ma'lumotlari saqlanadi
- ✅ Kirish muvaffaqiyatli bo'ladi

---

**Eslatma:** Production'ga chiqishdan oldin to'liq security rules yozish majburiy!

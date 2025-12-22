# CS310 Step 3 - Firebase Setup Guide

Bu rehber, projenizi Firebase ile çalıştırmak için yapmanız gereken adımları içerir.

## 📋 Yapılacak Adımlar

### 1. Firebase Console'da Proje Oluşturma

1. https://console.firebase.google.com adresine gidin
2. "Add Project" (Proje Ekle) butonuna tıklayın
3. Proje adı girin: `sunote-cs310` (veya istediğiniz bir isim)
4. Google Analytics'i devre dışı bırakabilirsiniz (opsiyonel)
5. "Create Project" butonuna tıklayın

### 2. Android Uygulaması Ekleme

1. Firebase Console'da projenizi açın
2. Android simgesine tıklayın (Add app)
3. Android package name: `com.example.cs310sunote`
   - Bu değeri `android/app/build.gradle.kts` dosyasında `namespace` altında bulabilirsiniz
4. App nickname: `SuNote Android`
5. "Register app" butonuna tıklayın
6. `google-services.json` dosyasını indirin
7. Dosyayı `android/app/` klasörüne koyun

### 3. Android Build Dosyalarını Güncelleme

#### `android/build.gradle.kts` dosyasına ekleyin:

```kotlin
plugins {
    // ... mevcut pluginler
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

#### `android/app/build.gradle.kts` dosyasına ekleyin:

```kotlin
plugins {
    // ... mevcut pluginler
    id("com.google.gms.google-services")
}
```

### 4. Firebase Authentication Aktifleştirme

1. Firebase Console → Authentication → Get Started
2. Sign-in method sekmesine gidin
3. "Email/Password" sağlayıcısını aktifleştirin
4. Sadece "Email/Password" seçeneğini ON yapın
5. Save butonuna tıklayın

### 5. Cloud Firestore Veritabanı Oluşturma

1. Firebase Console → Firestore Database → Create Database
2. "Start in test mode" seçeneğini seçin (başlangıç için)
3. Cloud Firestore location seçin (europe-west1 önerilir)
4. "Enable" butonuna tıklayın

### 6. Firestore Security Rules Güncelleme

Firebase Console → Firestore Database → Rules sekmesine gidin ve şu kuralları yapıştırın:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    match /notes/{noteId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() 
                    && request.resource.data.createdBy == request.auth.uid;
      allow update: if isAuthenticated() 
                    && resource.data.createdBy == request.auth.uid;
      allow delete: if isAuthenticated() 
                    && resource.data.createdBy == request.auth.uid;
    }
    
    match /purchases/{purchaseId} {
      allow read: if isAuthenticated() 
                  && resource.data.userId == request.auth.uid;
      allow create: if isAuthenticated() 
                    && request.resource.data.userId == request.auth.uid;
      allow update: if false;
      allow delete: if isAuthenticated() 
                    && resource.data.userId == request.auth.uid;
    }
    
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

"Publish" butonuna tıklayın.

### 7. Flutter Paketlerini Yükleme

Terminal'de proje klasöründe şu komutu çalıştırın:

```bash
flutter pub get
```

### 8. Uygulamayı Çalıştırma

```bash
flutter run
```

## 📁 Proje Yapısı (Step 3 Sonrası)

```
lib/
├── main.dart                    # Firebase init + MultiProvider
├── models/
│   └── note_model.dart          # Güncellenmiş model (toMap/fromMap)
├── providers/
│   ├── auth_provider.dart       # Firebase Auth state
│   ├── notes_provider.dart      # Firestore data state
│   └── theme_provider.dart      # SharedPreferences theme
├── services/
│   ├── auth_service.dart        # (eski, artık kullanılmıyor)
│   ├── firestore_service.dart   # Firestore CRUD işlemleri
│   └── note_repository.dart     # (eski, artık kullanılmıyor)
├── screens/
│   ├── wrapper.dart             # Auth durumuna göre yönlendirme
│   ├── login_screen.dart        # Firebase Auth login
│   ├── signup_screen.dart       # Firebase Auth signup
│   ├── home_screen.dart         # StreamBuilder ile real-time
│   ├── user_profile_screen.dart # Logout + Theme toggle
│   ├── upload_note_screen.dart  # Firestore create
│   ├── uploaded_notes_screen.dart # Firestore read + delete
│   ├── edit_note_screen.dart    # Firestore update
│   └── ... (diğer ekranlar)
├── utils/
│   └── ...
└── widgets/
    └── ...
```

## ✅ Rubrik Kontrol Listesi

| # | Gereksinim | Durum |
|---|------------|-------|
| 1 | Firebase doğru kurulmuş | ✅ |
| 2 | Sign up, login, logout çalışıyor | ✅ |
| 3 | Firestore collection'ları düzenli | ✅ |
| 4 | Model class'ları Firestore'a uygun | ✅ |
| 5 | Firestore işlemleri service layer'da | ✅ |
| 6 | Provider + MultiProvider kurulu | ✅ |
| 7 | Auth state provider ile yönetiliyor | ✅ |
| 8 | StreamBuilder ile loading/success/error | ✅ |
| 9 | Real-time UI güncellemesi | ✅ |
| 10 | Navigation doğru çalışıyor | ✅ |
| 11 | SharedPreferences ile tema kaydediliyor | ✅ |
| 12 | Firestore Security Rules yazıldı | ✅ |

## 🎥 Demo Video İçin Gösterilecekler

1. **Authentication:**
   - Yeni kullanıcı kayıt (Sign up)
   - Giriş yapma (Login)
   - Çıkış yapma (Logout)
   - Hata mesajları (yanlış şifre vb.)

2. **CRUD İşlemleri:**
   - Not oluşturma (Upload Note)
   - Notları listeleme (Home Screen)
   - Not güncelleme (Edit Note)
   - Not silme (Delete Note)

3. **Real-time Güncellemeler:**
   - Bir notu sildiğinizde anında listeden kaybolması
   - Yeni not eklendiğinde anında görünmesi

4. **SharedPreferences:**
   - Tema değiştirme (Dark/Light mode)
   - Uygulamayı kapatıp açtığınızda temanın korunması

## 🔧 Sorun Giderme

### "No Firebase App" Hatası
- `google-services.json` dosyasının doğru yerde olduğundan emin olun
- `flutter clean` ve `flutter pub get` komutlarını çalıştırın

### Firestore Permission Denied
- Security Rules'ın doğru ayarlandığından emin olun
- Kullanıcının giriş yapmış olduğundan emin olun

### Build Hataları
- Android build dosyalarının güncellendiğinden emin olun
- `flutter pub get` komutunu tekrar çalıştırın

---

Başarılar! 🚀

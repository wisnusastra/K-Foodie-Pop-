# K-Foodie Pop! (Flutter iOS Cooking Game)

Game memasak bertema **Korean Fast-Food** dengan karakter hewan menggemaskan (*Chef Kapi* si Capybara, *Tokki-ya* si Kelinci, *Horangi* si Harimau Korea, dan *Daram-i* si Tupai) yang terinspirasi dari mekanik tap-pop & serve seperti *Foodie Pop!*.

## Cara Build `.ipa` untuk iOS
1. Jalankan `flutter create --platforms=ios .` di dalam folder proyek ini untuk men-generate folder `ios/` standar Xcode.
2. Jalankan `flutter pub get`.
3. **Jika menggunakan macOS + Xcode (Signed IPA):**
   ```bash
   flutter build ipa --export-options-plist=ios/ExportOptions.plist
   ```
   File `.ipa` akan tersedia di `build/ios/ipa/*.ipa`.
4. **Jika build otomatis lewat GitHub Actions (tanpa Mac):**
   Push repo ini ke GitHub, jalankan workflow `Build iOS IPA (K-Foodie Pop!)`, dan unduh artefak `KFoodiePop-iOS-IPA`.

# تمرکز (Tamarkuz)

شخصي Android اپ د مطالعې او تمرکز لپاره — په Kotlin او Jetpack Compose لیکل شوی.

## څه کوي

- **د زنګونو سپین لیست:** یوازې هغه شمېرې چې په سپین لیست کې ثبت دي زنګ وهلای شي، نور ټول زنګونه بندېږي.
- **د ټولنیزو رسنیو بندول:** WhatsApp، Facebook، Messenger، Instagram، TikTok، YouTube، Telegram، Snapchat، X، imo، Viber او نور (۲۲ اپونه، د Lite او Business نسخو سره).
  هر اپ یا **مطلق بند** دی، یا **د کوډ سره** د څو دقیقو لپاره خلاصېږي. که دا اپونه وروسته نصب شي، هم بند پاتې کیږي.
- **د ننوتلو ثابت کوډ:** اپ هر ځل د کوډ غوښتنه کوي.
- له Android 10 (API 29) څخه تر Android 17 پورې.

## کوډ

اصلي کوډ `1234` دی. د بدلولو لپاره په GitHub کې:
**Settings → Secrets and variables → Actions → New repository secret**
نوم: `APP_PASSCODE`، ارزښت: ۴ تر ۸ رقمه. بیا نوی بیلډ جوړ کړئ. په APK کې یوازې د کوډ hash ساتل کیږي.

## بیلډ

هر push ته GitHub Actions (`.github/workflows/android.yml`) APK جوړوي، سکرین شاټونه اخلي، او په **Releases** کې یې خپروي.

## له نصب وروسته

په کور پاڼه کې «لومړنی تنظیم» پنځه ګامونه لري:
1. تمرکز د زنګ څارونکی اپ وټاکئ.
2. د تلیفون اجازې ورکړئ (د اړیکو زنګونه هم بندوي).
3. د لاسرسي خدمت (Accessibility) فعال کړئ. که «Restricted setting» ولیدل شو: د اپ معلومات ← ⋮ ← *Allow restricted settings*.
4. خبرتیاوې.
5. د بیټرۍ محدودیت لرې کړئ.

فونټ: [Vazirmatn](https://github.com/rastikerdar/vazirmatn) — SIL Open Font License (`licenses/OFL-Vazirmatn.txt`).

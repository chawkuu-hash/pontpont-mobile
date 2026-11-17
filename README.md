# PontPont Handbag Shop - Flutter Mobile App (Android & iOS)

မန္တလေးမြို့ PontPont Hand-bag shop အတွက် ရေးသားထားသော Flutter Mobile Application ဖြစ်ပါသည်။ လက်ရှိ Next.js Backend (`/api/shop`) နှင့် တိုက်ရိုက် ချိတ်ဆက် အလုပ်လုပ်ပါသည်။

---

## 📱 Features & စွမ်းဆောင်ရည်များ

1. **ပစ္စည်းစာရင်း ကြည့်ရှုခြင်း (Product Catalog):**
   - Next.js Backend SQLite database ထဲမှ ပစ္စည်းများကို Real-time ရယူပြသခြင်း
   - Category အလိုက် စစ်ထုတ်ခြင်း (Pills Filter: All, Tote, Crossbody, Backpack, Shoulder, Clutch)
   - ပစ္စည်းအမည်ဖြင့် အချိန်မရွေး ရှာဖွေနိုင်ခြင်း (Search Bar)
   - စျေးဆိုင်၏ နောက်ဆုံးရ ကြေညာချက်များ (Announcements Banner)
   - လက်ကျန်ပစ္စည်း အခြေအနေ (In Stock / Out of Stock) နှင့် Rating ကြည့်ရှုခြင်း

2. **အသေးစိတ် အချက်အလက်နှင့် အရောင်ရွေးချယ်ခြင်း (Product Details):**
   - ပစ္စည်း အရောင်များ (Color Chips) ရွေးချယ်ခြင်း
   - လက်လီ/လက်ကား စျေးနှုန်းများ တွက်ချက်မှု (၅ ခုနှင့်အထက် ဝယ်ပါက လက်ကားစျေးနှုန်း သတ်မှတ်ပေးခြင်း)
   - Dimension နှင့် Material အချက်အလက်များ ဖော်ပြခြင်း

3. **ခြင်းတောင်းနှင့် အော်ဒါတင်ခြင်း (Cart & Checkout):**
   - ပစ္စည်း အရေအတွက် အတိုး/အလျော့ ပြုလုပ်ခြင်း
   - မြို့နယ်အလိုက် ပို့ဆောင်ခ တွက်ချက်ခြင်း (မန္တလေး၊ ရန်ကုန်၊ နေပြည်တော်၊ နယ်မြို့များ)
   - ၁၀၀,၀၀၀ ကျပ်နှင့်အထက် အော်ဒါများအတွက် ပို့ဆောင်ခ အခမဲ့ (Free Delivery)
   - Payment စနစ်များ: **Cash on Delivery (COD)**, **KBZPay**, **WavePay**
   - Backend သို့ အော်ဒါတိုက်ရိုက်ပေးပို့ပြီး Order ID ပြန်လည်ထုတ်ပေးခြင်း

4. **Dynamic Server Configuration:**
   - App ၏ ညာဘက်အပေါ်ထောင့်ရှိ **Settings (Gear Icon)** ကိုနှိပ်၍ Backend Server IP (10.0.2.2 သို့မဟုတ် Wi-Fi IP) ကို အချိန်မရွေး အလွယ်တကူ ပြောင်းလဲနိုင်ခြင်း

---

## 🚀 App ကို စတင် Run နည်း (How to Run)

### အဆင့် ၁: Next.js Backend Server ကို Run ပါ
Terminal တွင် project root သို့သွား၍ dev server ကို ဖွင့်ထားပါ:
```bash
cd /home/ubuntu/PontPont-Hand-bag-shop
npm run dev
```
*(Server သည် `http://localhost:3000` သို့မဟုတ် `http://0.0.0.0:3000` တွင် စတင်အလုပ်လုပ်ပါမည်)*

### အဆင့် ၂: Flutter App ကို Run ပါ
1. Android Studio သို့မဟုတ် VS Code ဖြင့် `pontpont_mobile` folder ကို ဖွင့်ပါ။
2. Terminal တွင် package များ ဒေါင်းလုဒ်လုပ်ပါ:
   ```bash
   cd pontpont_mobile
   flutter pub get
   ```
3. Device သို့မဟုတ် Emulator ရွေးချယ်ပြီး Run ပါ:
   ```bash
   flutter run
   ```

---

## 🌐 Public Backend ချိတ်ဆက်ခြင်း (Connecting to Public Backend)

Backend သည် Public Domain သို့မဟုတ် Cloud Server (Vercel, Render, Railway, VPS, etc.) တွင် တင်ထားပါက:

1. `lib/config/constants.dart` ဖိုင်ကို ဖွင့်ပြီး သင့် Public Domain ကို ထည့်ပါ:
   ```dart
   class AppConfig {
     static const String publicBaseUrl = 'https://your-public-domain.com';
   }
   ```
2. App ထဲရှိ **Settings (Gear Icon)** မှလည်း အချိန်မရွေး Public URL ကို ရိုက်ထည့်၍ ပြောင်းလဲ စမ်းသပ်နိုင်ပါသည်။
3. Public HTTPS ဖြစ်ပါက မည်သည့် Android ဖုန်း သို့မဟုတ် မည်သည့် ကွန်ရက် (4G/5G/Wi-Fi) မှမဆို တိုက်ရိုက် ချိတ်ဆက် အသုံးပြုနိုင်ပါပြီ။

---

## 📂 Project Structure

```
pontpont_mobile/
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml   <-- INTERNET Permission
├── lib/
│   ├── main.dart                 <-- App Entry & Luxury Gold Theme
│   ├── config/
│   │   └── constants.dart        <-- Public Base URL Config
│   ├── models/
│   │   ├── product.dart          <-- Product & ProductColor Model
│   │   └── shop_data.dart        <-- CategoryItem, ShopData, CartItem
│   ├── services/
│   │   └── api_service.dart      <-- HTTP Client (GET & POST /api/shop)
│   └── screens/
│       ├── home_screen.dart      <-- Boutique Catalog, Search, Categories
│       ├── product_detail_screen.dart <-- Item Specs, Color Select, Add to Cart
│       └── cart_screen.dart      <-- Checkout, Delivery Fee, Payment & Submit
├── pubspec.yaml                  <-- Dependencies (http, flutter sdk)
└── README.md
```

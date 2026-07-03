# 📝 Notes App — Flutter + Supabase

Aad u qurux badan oo dhamaystiran Notes App Flutter iyo Supabase ku dhisan.

## 📱 Shaashadaha (Screens)
- **Login** — Sign In + Social buttons (Google, Apple, Facebook)
- **Sign Up** — Account creation with validation
- **Home** — Stats, Categories, Quick Access, Recent Notes
- **Create Note** — Rich editor + Templates + Drafts
- **Note Detail** — Full view with pin/favorite/edit/delete
- **Favorites** — Filtered favorites by category
- **Categories** — Grid view of all categories
- **Settings** — Profile, Preferences, Data & Backup, Logout
- **Search** — Full-text note search

---

## 🚀 Sida Loo Billaabo (Setup Instructions)

### 1. Supabase Project Samee
1. Tag [supabase.com](https://supabase.com) oo account samee
2. Project cusub samee
3. **Project URL** iyo **Anon Key** koobi (Settings → API)

### 2. Database Schema Run Garee
1. Supabase Dashboard → SQL Editor
2. Faylka `supabase_schema.sql` fur oo dhammaan copy garee
3. Run garee

### 3. Flutter App Configure Garee
Faylka `lib/main.dart` ku furto oo bedel:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',          // ← Supabase URL halkan geli
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // ← Anon Key halkan geli
);
```

### 4. Dependencies Install Garee
```bash
flutter pub get
```

### 5. App Socodsii
```bash
flutter run
```

---

## 📁 Folder Structure
```
lib/
├── main.dart                    # App entry + Auth gate
├── models/
│   └── note_model.dart          # Note data model + Category enum
├── services/
│   ├── supabase_service.dart    # All Supabase API calls
│   └── notes_provider.dart      # State management (Provider)
├── utils/
│   └── app_theme.dart           # Colors, Theme, Typography
├── widgets/
│   └── note_card.dart           # Reusable note list item
└── screens/
    ├── auth/
    │   ├── login_screen.dart
    │   └── signup_screen.dart
    ├── home/
    │   └── home_screen.dart
    ├── notes/
    │   ├── create_note_screen.dart
    │   ├── note_detail_screen.dart
    │   └── search_screen.dart
    ├── favorites/
    │   └── favorites_screen.dart
    ├── settings/
    │   └── settings_screen.dart
    └── navigation/
        └── main_navigation.dart
```

---

## 🛠 Technology Stack
| Layer | Technology |
|-------|-----------|
| Frontend | Flutter / Dart |
| Backend | Supabase (PostgreSQL) |
| Auth | Supabase Auth |
| State | Provider |
| Database | Row Level Security (RLS) |

---

## ✨ Features
- ✅ Authentication (Email + Password)
- ✅ CRUD Notes (Create, Read, Update, Delete)
- ✅ Categories (Personal, Work, Study, Ideas, Other)
- ✅ Pin & Favorite Notes
- ✅ Trash (Soft Delete)
- ✅ Search Notes
- ✅ Draft Notes
- ✅ Note Templates
- ✅ Stats Dashboard
- ✅ Dark/Light Theme Support
- ✅ Row Level Security

---

## 🔐 Security
Dhammaan notes-ku waxay u gaar yihiin user-ka gaarka ah (RLS enabled).
Supabase Auth ayaa handle garaysa session management.

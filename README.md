# Ascendly

**Ascendly** adalah aplikasi mobile modern yang dirancang untuk membantu pengguna melepaskan diri dari kecanduan (Gooning, Smoking, Gaming) melalui pelacakan *streak* hari, motivasi harian, dan dukungan darurat yang menenangkan.

## Fitur Utama
- **Modern Dark UI**: Desain elegan bernuansa gelap yang tenang dan suportif.
- **Supabase Backend**: Integrasi penuh untuk autentikasi dan penyimpanan data pengguna.
- **Goal Personalization**: Pilih target kecanduan yang ingin Anda atasi saat pertama kali mendaftar.
- **Streak Tracker**: Pantau sudah berapa hari Anda bebas dari kecanduan secara visual.
- **Emergency Button**: Fitur khusus saat keinginan (urges) muncul, memberikan pesan dukungan dan opsi reset yang jujur.
- **Statistics**: Visualisasi progres mingguan menggunakan grafik interaktif.
- **Secure Integration**: Semua kunci API disimpan dengan aman menggunakan `.env`.

## Stack Teknologi
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Auth & Database)
- **State Management**: Stateful Widgets & Service Pattern
- **Styling**: Google Fonts (Outfit), Lucide Icons, Animate Do, FL Chart

## Cara Menjalankan Project

### 1. Prasyarat
- Flutter SDK terinstal.
- Akun Supabase (Gratis).

### 2. Konfigurasi Environment
Salin file `.env.example` menjadi `.env` dan masukkan kredensial Supabase Anda:
```env
SUPABASE_URL=https://xyz.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### 3. Setup Database
Jalankan query berikut di SQL Editor Supabase Anda:
```sql
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  nickname text,
  goal text,
  streak_start_date timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

alter table profiles enable row level security;
create policy "Users can view and update own profile." on profiles
  for all using (auth.uid() = id);
```

### 4. Instalasi & Jalankan
```bash
flutter pub get
flutter run
```

## Connect with Me

- **YouTube**: [GexVex](https://youtube.com/@gexvexedit)
- **Pinterest**: [gstra.fx](https://pin.it/o8f9moE93)
- **GitHub**: [Gansputra](https://github.com/gansputra)
- **Instagram**: [gans.putra_](https://instagram.com/gans.putra_)

---

Developed with ❤️ by Gansputra :).

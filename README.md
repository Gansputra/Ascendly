# Ascendly

**Ascendly** is a modern mobile application designed to help users break free from addictions (Gooning, Smoking, Gaming) through streak tracking, daily motivation, and calming emergency support.

## Key Features
- **Modern Dark UI**: Elegant dark-themed design that feels calm and supportive.
- **Supabase Backend**: Full integration for authentication and user data storage.
- **Goal Personalization**: Choose your primary addiction focus during registration.
- **Streak Tracker**: Visually monitor how many days you've stayed committed.
- **Emergency Button**: A dedicated feature for when urges arise, providing supportive messages and honest reset options.
- **Statistics**: Weekly progress visualization using interactive charts.
- **Secure Integration**: All API keys are securely managed using `.env`.

## Tech Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (Auth & Database)
- **State Management**: Stateful Widgets & Service Pattern
- **Styling**: Google Fonts (Outfit), Lucide Icons, Animate Do, FL Chart

## Getting Started

### 1. Prerequisites
- Flutter SDK installed.
- Supabase account (Free tier is sufficient).

### 2. Environment Configuration
Copy `.env.example` to `.env` and enter your Supabase credentials:
```env
SUPABASE_URL=https://xyz.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

### 3. Database Setup
Execute the following query in your Supabase SQL Editor:
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

### 4. Installation & Run
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

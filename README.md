# Ascendly

Ascendly is a modern, privacy-focused application built with Flutter and Supabase, designed to help users overcome addictive behaviors and cultivate discipline through real-time social accountability and advanced progress tracking.

## Core Features

### Real-Time Social Accountability
- **Instant Presence Sync**: Accurate online/offline status tracking using Supabase Realtime and User ID-based synchronization.
- **Peer Chat**: Fluid one-on-one communication with real-time delivery and visual typing indicators.
- **Community List**: Manage friends and monitor their progress to foster mutual support.
- **Dynamic Status**: Intelligent "Last Seen" tracking to show activity without compromising long-term privacy.

### Advanced Progress Monitoring
- **Streak Gauge**: Accurate tracking of your recovery time down to the hour and minute.
- **Statistical Analytics**: Visualize recovery milestones and past relapses using interactive data charts.
- **Global Leaderboards**: Competitive system based on XP and progress relative to the broader community.
- **Calendar Visualization**: Heatmaps and calendar views to track consistency over months.

### Immersive Personalization
- **Dynamic Theming**: Elegant, high-contrast dark UI designed to minimize distractions and maintain focus.
- **Profile Customization**: Personalize your identity with custom nicknames, recovery goals, and avatar uploads managed through Supabase Storage.
- **Gamification**: Level up and earn experience points (XP) as you maintain consistency and complete milestones.

### System Integration
- **Cross-Platform Home Widgets**: Monitor your current streak directly from the home screen on Android and iOS devices.
- **Automated Resilience**: Real-time data persistence ensures your progress is never lost across multiple devices.
- **Emergency Support**: Immediate access to grounding exercises and motivational content during critical moments.

## Technology Stack

- **Frontend Framework**: Flutter (Dart)
- **Real-Time Backend**: Supabase (PostgreSQL, Auth, Realtime)
- **Storage**: Supabase Object Storage for media assets
- **Styling & Assets**: 
  - Google Fonts (Outfit)
  - Lucide Icons for consistent iconography
  - Animate Do for refined micro-interactions
  - FL Chart for high-performance data visualization
- **System Level**: `home_widget` for mobile background updates

## Development Setup

### 1. Prerequisites
- Flutter SDK (Latest Stable)
- Supabase Project

### 2. Environment Variables
Configure the environment by creating a `.env` file in the root directory based on `.env.example`:
```env
SUPABASE_URL=https://your-project-url.supabase.co
SUPABASE_ANON_KEY=your-anonymous-key
```

### 3. Database Schema
Execute the following SQL in your Supabase Editor to initialize the core data structures:

```sql
-- Profiles: Core user identity
create table profiles (
  id uuid references auth.users on delete cascade not null primary key,
  nickname text,
  goal text,
  xp bigint default 0,
  level int default 1,
  avatar_url text,
  streak_start_date timestamp with time zone,
  last_seen timestamp with time zone,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Friendships: Social graph
create table friendships (
  id uuid default gen_random_uuid() primary key,
  user_one_id uuid references profiles(id),
  user_two_id uuid references profiles(id),
  status text check (status in ('pending', 'accepted')) default 'pending',
  created_at timestamp with time zone default now()
);

-- Messages: Real-time communication
create table messages (
  id uuid default gen_random_uuid() primary key,
  sender_id uuid references profiles(id),
  receiver_id uuid references profiles(id),
  content text not null,
  created_at timestamp with time zone default now()
);

-- Relapses: History tracking
create table relapses (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references profiles(id),
  relapse_date timestamp with time zone default now()
);

-- Enable RLS for all tables
alter table profiles enable row level security;
alter table friendships enable row level security;
alter table messages enable row level security;
alter table relapses enable row level security;
```

### 4. Installation
```bash
# Retrieve dependencies
flutter pub get

# Launch application
flutter run
```

---

Developed with absolute discipline and focus. Reach out via GitHub for collaborations.

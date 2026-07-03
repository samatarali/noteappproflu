-- =============================================
-- NOTES APP - SUPABASE DATABASE SCHEMA
-- Run this in your Supabase SQL Editor
-- =============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================
-- NOTES TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.notes (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  title       TEXT NOT NULL DEFAULT '',
  content     TEXT NOT NULL DEFAULT '',
  category    TEXT NOT NULL DEFAULT 'personal'
              CHECK (category IN ('personal', 'work', 'study', 'ideas', 'other')),
  is_pinned   BOOLEAN NOT NULL DEFAULT false,
  is_favorite BOOLEAN NOT NULL DEFAULT false,
  is_draft    BOOLEAN NOT NULL DEFAULT false,
  is_trashed  BOOLEAN NOT NULL DEFAULT false,
  tags        TEXT[] NOT NULL DEFAULT '{}',
  color       TEXT,
  reminder_at TIMESTAMPTZ,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =============================================
-- INDEXES for performance
-- =============================================
CREATE INDEX IF NOT EXISTS idx_notes_user_id       ON public.notes(user_id);
CREATE INDEX IF NOT EXISTS idx_notes_category      ON public.notes(category);
CREATE INDEX IF NOT EXISTS idx_notes_is_trashed    ON public.notes(is_trashed);
CREATE INDEX IF NOT EXISTS idx_notes_is_favorite   ON public.notes(is_favorite);
CREATE INDEX IF NOT EXISTS idx_notes_is_pinned     ON public.notes(is_pinned);
CREATE INDEX IF NOT EXISTS idx_notes_updated_at    ON public.notes(updated_at DESC);

-- Full text search index
CREATE INDEX IF NOT EXISTS idx_notes_fts ON public.notes
  USING GIN (to_tsvector('english', title || ' ' || content));

-- =============================================
-- ROW LEVEL SECURITY (RLS)
-- =============================================
ALTER TABLE public.notes ENABLE ROW LEVEL SECURITY;

-- Users can only see their own notes
CREATE POLICY "Users can view their own notes"
  ON public.notes FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own notes
CREATE POLICY "Users can insert their own notes"
  ON public.notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can update their own notes
CREATE POLICY "Users can update their own notes"
  ON public.notes FOR UPDATE
  USING (auth.uid() = user_id);

-- Users can delete their own notes
CREATE POLICY "Users can delete their own notes"
  ON public.notes FOR DELETE
  USING (auth.uid() = user_id);

-- =============================================
-- AUTO-UPDATE updated_at TRIGGER
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notes_updated_at
  BEFORE UPDATE ON public.notes
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- =============================================
-- USER PROFILES TABLE (optional)
-- =============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id           UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name    TEXT,
  avatar_url   TEXT,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- SAMPLE DATA (optional - for testing)
-- =============================================
-- Uncomment and replace USER_ID_HERE with your actual user ID after signing up
/*
INSERT INTO public.notes (user_id, title, content, category, is_pinned, is_favorite) VALUES
--  ('USER_ID_HERE', 'Flutter Notes App', 'This is a note taking app built with Flutter and Supabase.', 'personal', true, true),
--  ('USER_ID_HERE', 'Project Ideas', 'Some ideas for upcoming projects and features.', 'work', false, true),
--  ('USER_ID_HERE', 'Study Plan', 'Plan for final exams preparation and schedule.', 'study', false, true),
--  ('USER_ID_HERE', 'Daily Tasks', 'Things to do today and important reminders.', 'personal', false, false),
--  ('USER_ID_HERE', 'Motivation', 'Some motivational quotes to keep going.', 'ideas', false, true),
  ('USER_ID_HERE', 'Book Notes', 'Notes from the book Atomic Habits.', 'study', false, true);
*/

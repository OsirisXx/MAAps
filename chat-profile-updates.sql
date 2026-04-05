-- ============================================
-- CHAT & PROFILE SYSTEM UPDATES
-- ============================================
-- Run this in your Supabase SQL Editor to add:
-- 1. Image attachments for chat messages
-- 2. Profile picture support
-- Run this AFTER the main chat-system-schema.sql

-- ============================================
-- UPDATE MESSAGES TABLE - Add image support
-- ============================================
ALTER TABLE public.messages 
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS image_name TEXT,
ADD COLUMN IF NOT EXISTS image_size INTEGER;

-- Make message_text optional since messages can be image-only
ALTER TABLE public.messages 
ALTER COLUMN message_text DROP NOT NULL;

-- Add check constraint to ensure message has either text or image
ALTER TABLE public.messages 
ADD CONSTRAINT message_has_content 
CHECK (message_text IS NOT NULL OR image_url IS NOT NULL);

-- ============================================
-- UPDATE PROFILES TABLE - Add profile picture
-- ============================================
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS profile_picture_url TEXT,
ADD COLUMN IF NOT EXISTS bio TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- ============================================
-- CREATE STORAGE BUCKET FOR CHAT IMAGES
-- ============================================
-- Create storage bucket for chat attachments
INSERT INTO storage.buckets (id, name, public)
VALUES ('chat-images', 'chat-images', true)
ON CONFLICT (id) DO NOTHING;

-- Create storage bucket for profile pictures
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-pictures', 'profile-pictures', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- STORAGE POLICIES FOR CHAT IMAGES
-- ============================================

-- Allow authenticated users to upload chat images
CREATE POLICY "Users can upload chat images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'chat-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to view chat images (since they're in conversations)
CREATE POLICY "Anyone can view chat images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'chat-images');

-- Allow users to delete their own chat images
CREATE POLICY "Users can delete own chat images"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'chat-images' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- STORAGE POLICIES FOR PROFILE PICTURES
-- ============================================

-- Allow authenticated users to upload their profile picture
CREATE POLICY "Users can upload own profile picture"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'profile-pictures' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow anyone to view profile pictures
CREATE POLICY "Anyone can view profile pictures"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile-pictures');

-- Allow users to update their own profile picture
CREATE POLICY "Users can update own profile picture"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'profile-pictures' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- Allow users to delete their own profile picture
CREATE POLICY "Users can delete own profile picture"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'profile-pictures' AND
  (storage.foldername(name))[1] = auth.uid()::text
);

-- ============================================
-- FUNCTION TO UPDATE PROFILE TIMESTAMP
-- ============================================
CREATE OR REPLACE FUNCTION update_profile_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to update profile timestamp
DROP TRIGGER IF EXISTS trigger_update_profile_timestamp ON public.profiles;
CREATE TRIGGER trigger_update_profile_timestamp
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_timestamp();

-- ============================================
-- INDEXES FOR NEW COLUMNS
-- ============================================
CREATE INDEX IF NOT EXISTS idx_messages_image_url ON public.messages(image_url) WHERE image_url IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_updated_at ON public.profiles(updated_at DESC);

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify the updates were applied successfully:
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'messages' AND column_name IN ('image_url', 'image_name', 'image_size');
-- SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'profiles' AND column_name IN ('profile_picture_url', 'bio', 'updated_at');
-- SELECT * FROM storage.buckets WHERE id IN ('chat-images', 'profile-pictures');

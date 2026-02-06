-- ============================================
-- Supabase Storage Setup
-- ============================================

-- 1. Create the salon-assets bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('salon-assets', 'salon-assets', true)
ON CONFLICT (id) DO NOTHING;

-- 2. Storage Policies for salon-assets

-- Allow public read access to all objects in salon-assets
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING ( bucket_id = 'salon-assets' );

-- Allow authenticated users to upload files to salon-assets
CREATE POLICY "Authenticated Upload Access"
ON storage.objects FOR INSERT
WITH CHECK (
    auth.role() = 'authenticated' AND
    bucket_id = 'salon-assets'
);

-- Allow authenticated users to update/delete their own files in salon-assets
CREATE POLICY "Authenticated Manage Access"
ON storage.objects FOR ALL
USING (
    auth.role() = 'authenticated' AND
    bucket_id = 'salon-assets'
);

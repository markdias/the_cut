-- Add is_separate_page to site_page_sections
ALTER TABLE public.site_page_sections 
ADD COLUMN IF NOT EXISTS is_separate_page BOOLEAN DEFAULT false;

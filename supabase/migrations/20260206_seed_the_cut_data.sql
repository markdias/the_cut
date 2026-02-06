-- ============================================
-- Seed data for "The Cut" Barbershop
-- ============================================

-- 0. Fix custom_section_elements check constraint if needed
ALTER TABLE public.custom_section_elements 
DROP CONSTRAINT IF EXISTS custom_section_elements_element_type_check;

ALTER TABLE public.custom_section_elements
ADD CONSTRAINT custom_section_elements_element_type_check 
CHECK (element_type IN ('gallery', 'text_box', 'card', 'image', 'video', 'qr_code', 'list', 'button', 'table', 'image_carousel'));

-- 0.1 Fix missing is_separate_page column in site_page_sections
ALTER TABLE public.site_page_sections 
ADD COLUMN IF NOT EXISTS is_separate_page BOOLEAN DEFAULT false;

-- 1. Theme Settings
INSERT INTO public.site_settings (key, value)
VALUES
    ('business_name', 'The Cut Barbershop'),
    ('theme_primary', '#000000'),
    ('theme_primary_hover', '#333333'),
    ('theme_accent', '#FFFFFF'),
    ('theme_soft_cream', '#F5F5F5'),
    ('theme_text_dark', '#000000'),
    ('theme_text_light', '#FFFFFF'),
    ('hero_title', 'THE CUT'),
    ('hero_subtitle', 'Traditional barbershop with a modern edge in North London.'),
    ('hero_bg_url', 'https://impro.usercontent.one/appid/oneComWsb/domain/thecut.biz/media/thecut.biz/onewebmedia/vFBTCLqsQ665GZV2WDlU+A.jpg?etag=%221b9ee0-5fb560aa%22&sourceContentType=image%2Fjpeg&ignoreAspectRatio&resize=2500,1875&quality=85'),
    ('logo_url', 'https://impro.usercontent.one/appid/oneComWsb/domain/thecut.biz/media/thecut.biz/onewebmedia/fp+eHF1CSK+zSEK2uTEz1Q.jpg?etag=%221c3e73-5fb560bb%22&sourceContentType=image%2Fjpeg&ignoreAspectRatio&resize=2500,1875&quality=85'),
    ('logo_size', '100'),
    ('footer_description', 'Classic and contemporary trends since 2006.'),
    ('opening_hours', 'Mon-Fri: 09:30-18:45 | Sat: 09:30-18:00 | Sun: 09:30-16:30'),
    ('theme_navbar_bg', '#000000'),
    ('theme_navbar_text', '#FFFFFF')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 2. Disable main sections to favor custom ones
UPDATE public.site_page_sections SET enabled = false WHERE id IN ('pricing', 'gallery', 'contact');

-- 3. Gallery Images
TRUNCATE TABLE public.gallery_images;
INSERT INTO public.gallery_images (image_url, sort_order)
VALUES
    ('https://impro.usercontent.one/appid/oneComWsb/domain/thecut.biz/media/thecut.biz/onewebmedia/VnNXoLxYR8SDHyowsWeTEg___serialized1.jpg?etag=%225c3c95-5fb56117%22&sourceContentType=image%2Fjpeg&ignoreAspectRatio&resize=2500,3333&quality=85', 1),
    ('https://impro.usercontent.one/appid/oneComWsb/domain/thecut.biz/media/thecut.biz/onewebmedia/fullsizeoutput_18cb.jpeg?etag=%224a024-5fb557e9%22&sourceContentType=image%2Fjpeg&quality=85&progressive', 2),
    ('https://impro.usercontent.one/appid/oneComWsb/domain/thecut.biz/media/thecut.biz/onewebmedia/WEOaITT7TI27HpF59fDX7g___serialized2.jpg?etag=%223eb89e-5fb56130%22&sourceContentType=image%2Fjpeg&ignoreAspectRatio&resize=2500,2869&quality=85', 3),
    ('https://impro.usercontent.one/appid/oneComWsb/domain/thecut.biz/media/thecut.biz/onewebmedia/aPBHUR4ES+Ofm%25sTWGsBfQ.jpg?etag=%22221f96-5fb560b6%22&sourceContentType=image%2Fjpeg&ignoreAspectRatio&resize=2500,1875&quality=85', 4);

-- 4. Custom Sections for Locations
DO $$
DECLARE
    muswell_hill_id UUID;
    highgate_id UUID;
    east_finchley_id UUID;
BEGIN
    -- Delete existing custom sections to avoid duplication during seed
    DELETE FROM public.custom_sections WHERE menu_name IN ('Muswell Hill', 'Highgate Village', 'East Finchley');

    -- Muswell Hill
    INSERT INTO public.custom_sections (title, menu_name, heading_name, sort_order, background_color, text_color, is_separate_page)
    VALUES ('Muswell Hill Location', 'Muswell Hill', 'Our Muswell Hill Shop', 100, '#000000', '#FFFFFF', true)
    RETURNING id INTO muswell_hill_id;

    -- Highgate Village
    INSERT INTO public.custom_sections (title, menu_name, heading_name, sort_order, background_color, text_color, is_separate_page)
    VALUES ('Highgate Village Location', 'Highgate Village', 'Our Highgate Village Shop', 110, '#000000', '#FFFFFF', true)
    RETURNING id INTO highgate_id;

    -- East Finchley
    INSERT INTO public.custom_sections (title, menu_name, heading_name, sort_order, background_color, text_color, is_separate_page)
    VALUES ('East Finchley Location', 'East Finchley', 'Our East Finchley Shop', 120, '#000000', '#FFFFFF', true)
    RETURNING id INTO east_finchley_id;

    -- Add to site_page_sections to ensure they are tracked
    INSERT INTO public.site_page_sections (id, sort_order, enabled, is_separate_page)
    VALUES 
        (muswell_hill_id::text, 100, true, true),
        (highgate_id::text, 110, true, true),
        (east_finchley_id::text, 120, true, true)
    ON CONFLICT (id) DO UPDATE SET is_separate_page = true, enabled = true;

    -- Elements for Muswell Hill
    INSERT INTO public.custom_section_elements (section_id, element_type, sort_order, config)
    VALUES 
        (muswell_hill_id, 'text_box', 1, '{"content": "494 Muswell Hill Broadway, Muswell Hill, London N10 1BT\nPhone: 020 8365 3469", "alignment": "center"}'),
        (muswell_hill_id, 'table', 2, '{"rows": [["Day", "Hours"], ["Mon-Fri", "09:30 - 18:45"], ["Saturday", "09:30 - 18:00"], ["Sunday", "09:30 - 16:30"]], "hasHeader": true}'),
        (muswell_hill_id, 'table', 3, '{"rows": [["Service", "Price"], ["Haircut", "£20 - £30"], ["Skin Fade", "£25 - £35"], ["Beard Trim", "£15"], ["Wash & Cut", "£30 +"]], "hasHeader": true}');

    -- Elements for Highgate Village
    INSERT INTO public.custom_section_elements (section_id, element_type, sort_order, config)
    VALUES 
        (highgate_id, 'text_box', 1, '{"content": "13 Highgate High St, London N6 5JT\nPhone: 020 8347 6458", "alignment": "center"}'),
        (highgate_id, 'table', 2, '{"rows": [["Day", "Hours"], ["Mon-Fri", "09:30 - 18:45"], ["Saturday", "09:30 - 18:00"], ["Sunday", "09:30 - 16:30"]], "hasHeader": true}'),
        (highgate_id, 'table', 3, '{"rows": [["Service", "Price"], ["Haircut", "£22 - £32"], ["Skin Fade", "£27 - £37"], ["Beard Trim", "£15"], ["Wash & Cut", "£32 +"]], "hasHeader": true}');

    -- Elements for East Finchley
    INSERT INTO public.custom_section_elements (section_id, element_type, sort_order, config)
    VALUES 
        (east_finchley_id, 'text_box', 1, '{"content": "96 High Rd, London N2 9EB\nPhone: 020 3302 8840", "alignment": "center"}'),
        (east_finchley_id, 'table', 2, '{"rows": [["Day", "Hours"], ["Mon-Fri", "09:30 - 18:45"], ["Saturday", "09:30 - 18:00"], ["Sunday", "09:30 - 16:30"]], "hasHeader": true}'),
        (east_finchley_id, 'table', 3, '{"rows": [["Service", "Price"], ["Haircut", "£20 - £30"], ["Skin Fade", "£25 - £35"], ["Beard Trim", "£15"], ["Wash & Cut", "£30 +"]], "hasHeader": true}');
END $$;

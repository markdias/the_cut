-- Fix custom_section_elements check constraint
ALTER TABLE public.custom_section_elements 
DROP CONSTRAINT IF EXISTS custom_section_elements_element_type_check;

ALTER TABLE public.custom_section_elements
ADD CONSTRAINT custom_section_elements_element_type_check 
CHECK (element_type IN ('gallery', 'text_box', 'card', 'image', 'video', 'qr_code', 'list', 'button', 'table', 'image_carousel'));

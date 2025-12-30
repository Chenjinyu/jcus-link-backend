-- Fix profile_data trigger to not set searchable_text (column doesn't exist)
-- Since searchable_text is generated in Python, the trigger should not try to set it

DROP TRIGGER IF EXISTS update_profile_data_searchable_text_trigger ON profile_data;
DROP FUNCTION IF EXISTS update_profile_data_searchable_text();

-- Create a no-op trigger function (does nothing, just returns NEW)
-- This prevents errors while keeping the trigger structure in case we add the column later
CREATE OR REPLACE FUNCTION update_profile_data_searchable_text()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  -- No-op: searchable_text is generated in Python, not by trigger
  -- If you add searchable_text column later, uncomment the logic below
  /*
  DECLARE
    text_parts TEXT[] := '{}';
  BEGIN
    -- Extract searchable fields from JSONB based on common patterns
    IF NEW.data ? 'title' THEN
      text_parts := array_append(text_parts, NEW.data->>'title');
    END IF;
    
    IF NEW.data ? 'company' THEN
      text_parts := array_append(text_parts, NEW.data->>'company');
    END IF;
    
    IF NEW.data ? 'description' THEN
      text_parts := array_append(text_parts, NEW.data->>'description');
    END IF;
    
    -- Join all parts
    NEW.searchable_text := array_to_string(text_parts, '. ');
  */
  
  RETURN NEW;
END;
$$;

-- Recreate trigger (no-op, but keeps structure)
CREATE TRIGGER update_profile_data_searchable_text_trigger
  BEFORE INSERT OR UPDATE ON profile_data
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_data_searchable_text();


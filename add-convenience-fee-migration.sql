-- Migration: Add convenience_fee column to orders table
-- Date: 2026-05-04
-- Description: Adds a new convenience_fee column to support the updated checkout fee structure

-- Add convenience_fee column to orders table
ALTER TABLE public.orders 
ADD COLUMN convenience_fee DECIMAL(10, 2);

-- Add comment to document the column
COMMENT ON COLUMN public.orders.convenience_fee IS 'Convenience fee charged for order processing and handling. NULL for orders placed before this fee was introduced.';

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'orders' 
AND column_name = 'convenience_fee';

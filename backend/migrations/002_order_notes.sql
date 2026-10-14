-- Run this migration ONLY against the Campus Eats TEST Neon branch.
-- Stores optional customer instructions for kitchen/runner visibility.
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS order_notes VARCHAR(300);

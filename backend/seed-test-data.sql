-- Campus Eats test data seed
-- Safe to run more than once: rows are matched by name.
-- Run this in the Neon SQL Editor for the test database before testing orders.

INSERT INTO buildings (name, campus_zone, is_active)
SELECT source.name, source.campus_zone, TRUE
FROM (VALUES
  ('Wits Main Campus', 'Campus'),
  ('Wits Medical School', 'Campus'),
  ('Wits Education Campus', 'Campus'),
  ('West Campus Residences', 'Residences'),
  ('East Campus Residences', 'Residences'),
  ('Matrix Mall', 'Retail'),
  ('Wits Junction', 'Campus'),
  ('Library Lawns', 'Campus')
) AS source(name, campus_zone)
WHERE NOT EXISTS (SELECT 1 FROM buildings b WHERE b.name = source.name);

INSERT INTO menu_items (name, price_cents, is_available)
VALUES
  ('Jumbo Burger', 4200, TRUE),
  ('Chicken Burger', 4200, TRUE),
  ('Jumbo Cheese Burger', 4800, TRUE),
  ('Chillie Cheese Burger', 4800, TRUE),
  ('Bacon and Cheese Burger', 5200, TRUE),
  ('Double Double', 7500, TRUE),
  ('Big Boss Burger', 9000, TRUE),
  ('Chicken Wrap', 4700, TRUE),
  ('Beef Wrap', 4700, TRUE),
  ('Chicken Crunch Wrap', 4700, TRUE),
  ('Base Kota', 3000, TRUE),
  ('Kota Lite', 3800, TRUE),
  ('Loxtion Kota', 4200, TRUE),
  ('Makoya', 4400, TRUE),
  ('Mega Kota', 5000, TRUE),
  ('Egg and Chip Roll', 3500, TRUE),
  ('Egg & Bacon Roll', 3800, TRUE),
  ('Russian and Chip Roll', 3800, TRUE),
  ('Russian and Egg Roll', 3800, TRUE),
  ('Wors and Chip Roll', 3800, TRUE),
  ('Sunshine Breakfast', 4500, TRUE),
  ('Griller''s Choice', 5200, TRUE),
  ('Egg & Tomato', 2800, TRUE),
  ('Cheese & Tomato', 2800, TRUE),
  ('Cheese, Egg & Tomato', 3400, TRUE),
  ('Bacon and Cheese', 3200, TRUE),
  ('Bacon and Egg', 3200, TRUE),
  ('2 x Vianna and Chips', 4000, TRUE),
  ('Russian', 2000, TRUE),
  ('Russian and Chips', 4500, TRUE),
  ('Jumbo Russian', 2500, TRUE),
  ('Jumbo Russian and Chips', 5000, TRUE),
  ('Braai Box', 8500, TRUE),
  ('Mixed Box', 8000, TRUE),
  ('Mega Meal', 8900, TRUE),
  ('Champ Meal', 14000, TRUE),
  ('Giga Meal', 14500, TRUE),
  ('Pap and Beef Stew', 4800, TRUE),
  ('300g', 6000, TRUE),
  ('300g with Chips', 8000, TRUE),
  ('600g', 11500, TRUE),
  ('600g with Chips', 13000, TRUE),
  ('Lamb Chop', 2800, TRUE),
  ('Lamb and Chips', 4500, TRUE),
  ('Brisket', 3500, TRUE),
  ('Brisket & Chips', 5800, TRUE),
  ('Chuck', 4000, TRUE),
  ('Chuck & Chips', 6800, TRUE),
  ('Wings and Chips', 4500, TRUE),
  ('Drum Sticks and Chips', 4800, TRUE),
  ('¼ Chicken', 3900, TRUE),
  ('¼ Chicken and Chips', 5900, TRUE),
  ('½ Chicken', 6800, TRUE),
  ('½ Chicken and Chips', 8800, TRUE),
  ('Full Chicken', 13500, TRUE),
  ('Full Chicken and Chips', 16000, TRUE),
  ('Mini', 2200, TRUE),
  ('Small', 3000, TRUE),
  ('Medium', 4000, TRUE),
  ('Large', 6800, TRUE),
  ('Jumbo', 8000, TRUE),
  ('Wors', 2100, TRUE),
  ('Wors Roll', 3200, TRUE),
  ('Wors and Chip Roll', 3800, TRUE),
  ('Wors and Chips', 4800, TRUE)
ON CONFLICT DO NOTHING;

-- Update prices for existing rows to match the current public menu.
UPDATE menu_items SET price_cents = 4200, is_available = TRUE WHERE name = 'Jumbo Burger';
UPDATE menu_items SET price_cents = 4200, is_available = TRUE WHERE name = 'Chicken Burger';
UPDATE menu_items SET price_cents = 4800, is_available = TRUE WHERE name = 'Jumbo Cheese Burger';
UPDATE menu_items SET price_cents = 4800, is_available = TRUE WHERE name = 'Chillie Cheese Burger';
UPDATE menu_items SET price_cents = 5200, is_available = TRUE WHERE name = 'Bacon and Cheese Burger';
UPDATE menu_items SET price_cents = 7500, is_available = TRUE WHERE name = 'Double Double';
UPDATE menu_items SET price_cents = 9000, is_available = TRUE WHERE name = 'Big Boss Burger';
UPDATE menu_items SET price_cents = 4700, is_available = TRUE WHERE name = 'Chicken Wrap';
UPDATE menu_items SET price_cents = 4700, is_available = TRUE WHERE name = 'Beef Wrap';
UPDATE menu_items SET price_cents = 4700, is_available = TRUE WHERE name = 'Chicken Crunch Wrap';
UPDATE menu_items SET price_cents = 3000, is_available = TRUE WHERE name = 'Base Kota';
UPDATE menu_items SET price_cents = 3800, is_available = TRUE WHERE name = 'Kota Lite';
UPDATE menu_items SET price_cents = 4200, is_available = TRUE WHERE name = 'Loxtion Kota';
UPDATE menu_items SET price_cents = 4400, is_available = TRUE WHERE name = 'Makoya';
UPDATE menu_items SET price_cents = 5000, is_available = TRUE WHERE name = 'Mega Kota';
UPDATE menu_items SET price_cents = 3500, is_available = TRUE WHERE name = 'Egg and Chip Roll';
UPDATE menu_items SET price_cents = 3800, is_available = TRUE WHERE name = 'Egg & Bacon Roll';
UPDATE menu_items SET price_cents = 3800, is_available = TRUE WHERE name = 'Russian and Chip Roll';
UPDATE menu_items SET price_cents = 3800, is_available = TRUE WHERE name = 'Russian and Egg Roll';
UPDATE menu_items SET price_cents = 3800, is_available = TRUE WHERE name = 'Wors and Chip Roll';
UPDATE menu_items SET price_cents = 4500, is_available = TRUE WHERE name = 'Sunshine Breakfast';
UPDATE menu_items SET price_cents = 5200, is_available = TRUE WHERE name = 'Griller''s Choice';
UPDATE menu_items SET price_cents = 2800, is_available = TRUE WHERE name = 'Egg & Tomato';
UPDATE menu_items SET price_cents = 2800, is_available = TRUE WHERE name = 'Cheese & Tomato';
UPDATE menu_items SET price_cents = 3400, is_available = TRUE WHERE name = 'Cheese, Egg & Tomato';
UPDATE menu_items SET price_cents = 3200, is_available = TRUE WHERE name = 'Bacon and Cheese';
UPDATE menu_items SET price_cents = 3200, is_available = TRUE WHERE name = 'Bacon and Egg';
UPDATE menu_items SET price_cents = 4000, is_available = TRUE WHERE name = '2 x Vianna and Chips';
UPDATE menu_items SET price_cents = 2000, is_available = TRUE WHERE name = 'Russian';
UPDATE menu_items SET price_cents = 4500, is_available = TRUE WHERE name = 'Russian and Chips';
UPDATE menu_items SET price_cents = 2500, is_available = TRUE WHERE name = 'Jumbo Russian';
UPDATE menu_items SET price_cents = 5000, is_available = TRUE WHERE name = 'Jumbo Russian and Chips';
UPDATE menu_items SET price_cents = 8500, is_available = TRUE WHERE name = 'Braai Box';
UPDATE menu_items SET price_cents = 8000, is_available = TRUE WHERE name = 'Mixed Box';
UPDATE menu_items SET price_cents = 8900, is_available = TRUE WHERE name = 'Mega Meal';
UPDATE menu_items SET price_cents = 14000, is_available = TRUE WHERE name = 'Champ Meal';
UPDATE menu_items SET price_cents = 14500, is_available = TRUE WHERE name = 'Giga Meal';
UPDATE menu_items SET price_cents = 4800, is_available = TRUE WHERE name = 'Pap and Beef Stew';
UPDATE menu_items SET price_cents = 6000, is_available = TRUE WHERE name = '300g';
UPDATE menu_items SET price_cents = 8000, is_available = TRUE WHERE name = '300g with Chips';
UPDATE menu_items SET price_cents = 11500, is_available = TRUE WHERE name = '600g';
UPDATE menu_items SET price_cents = 13000, is_available = TRUE WHERE name = '600g with Chips';
UPDATE menu_items SET price_cents = 2800, is_available = TRUE WHERE name = 'Lamb Chop';
UPDATE menu_items SET price_cents = 4500, is_available = TRUE WHERE name = 'Lamb and Chips';
UPDATE menu_items SET price_cents = 3500, is_available = TRUE WHERE name = 'Brisket';
UPDATE menu_items SET price_cents = 5800, is_available = TRUE WHERE name = 'Brisket & Chips';
UPDATE menu_items SET price_cents = 4000, is_available = TRUE WHERE name = 'Chuck';
UPDATE menu_items SET price_cents = 6800, is_available = TRUE WHERE name = 'Chuck & Chips';
UPDATE menu_items SET price_cents = 4500, is_available = TRUE WHERE name = 'Wings and Chips';
UPDATE menu_items SET price_cents = 4800, is_available = TRUE WHERE name = 'Drum Sticks and Chips';
UPDATE menu_items SET price_cents = 3900, is_available = TRUE WHERE name = '¼ Chicken';
UPDATE menu_items SET price_cents = 5900, is_available = TRUE WHERE name = '¼ Chicken and Chips';
UPDATE menu_items SET price_cents = 6800, is_available = TRUE WHERE name = '½ Chicken';
UPDATE menu_items SET price_cents = 8800, is_available = TRUE WHERE name = '½ Chicken and Chips';
UPDATE menu_items SET price_cents = 13500, is_available = TRUE WHERE name = 'Full Chicken';
UPDATE menu_items SET price_cents = 16000, is_available = TRUE WHERE name = 'Full Chicken and Chips';
UPDATE menu_items SET price_cents = 2200, is_available = TRUE WHERE name = 'Mini';
UPDATE menu_items SET price_cents = 3000, is_available = TRUE WHERE name = 'Small';
UPDATE menu_items SET price_cents = 4000, is_available = TRUE WHERE name = 'Medium';
UPDATE menu_items SET price_cents = 6800, is_available = TRUE WHERE name = 'Large';
UPDATE menu_items SET price_cents = 8000, is_available = TRUE WHERE name = 'Jumbo';
UPDATE menu_items SET price_cents = 2100, is_available = TRUE WHERE name = 'Wors';
UPDATE menu_items SET price_cents = 3200, is_available = TRUE WHERE name = 'Wors Roll';
UPDATE menu_items SET price_cents = 3800, is_available = TRUE WHERE name = 'Wors and Chip Roll';
UPDATE menu_items SET price_cents = 4800, is_available = TRUE WHERE name = 'Wors and Chips';

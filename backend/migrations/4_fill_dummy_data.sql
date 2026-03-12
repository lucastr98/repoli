INSERT INTO recipes (title, instructions, number_of_servings) VALUES 
    ('Spaghetti Carbonara', '1. Boil pasta.\n2. Cook pancetta.\n3. Mix eggs and cheese.\n4. Combine all with pasta.', 2),
    ('Pancakes', '1. Mix flour, milk, and eggs.\n2. Cook on griddle until golden brown on both sides.', 4),
    ('Guacamole', '1. Mash avocados.\n2. Add lime juice, salt, and diced onions.\n3. Serve with tortilla chips.', 3);

INSERT INTO ingredients (name) VALUES 
    ('Spaghetti'),
    ('Pancetta'),
    ('Eggs'),
    ('Parmesan Cheese'),
    ('Flour'),
    ('Milk'),
    ('Avocados'),
    ('Lime Juice'),
    ('Salt'),
    ('Onions');

INSERT INTO units (name) VALUES 
    ('gram'),
    ('kilogram'),
    ('milliliter'),
    ('liter'),
    ('teaspoon'),
    ('tablespoon'),
    ('cup'),
    ('piece'),
    ('pinch'),
    ('to taste');

INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity, unit_id) VALUES 
    (1, 1, 200, 1), -- Spaghetti Carbonara: 200 grams of Spaghetti
    (1, 2, 100, 1), -- Spaghetti Carbonara: 100 grams of Pancetta
    (1, 3, 2, 8),   -- Spaghetti Carbonara: 2 pieces of Eggs
    (1, 4, 50, 1),  -- Spaghetti Carbonara: 50 grams of Parmesan Cheese
    (2, 5, 150, 1), -- Pancakes: 150 grams of Flour
    (2, 6, 200, 3), -- Pancakes: 200 milliliters of Milk
    (2, 3, 2, 8),   -- Pancakes: 2 pieces of Eggs
    (3, 7, 3, 8),   -- Guacamole: 3 pieces of Avocados
    (3, 8, 30, 3),   -- Guacamole: 30 milliliters of Lime Juice
    (3, 9, null, 10), -- Guacamole: Salt to taste
    (3, 10, null, 10); -- Guacamole: Onions to taste
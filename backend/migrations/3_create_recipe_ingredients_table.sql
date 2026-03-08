create table if not exists recipe_ingredients (
    id integer primary key autoincrement,
    recipe_id integer not null,
    ingredient_id integer not null,
    quantity real,
    unit_id integer not null,
    created_at text not null default (datetime('now')),
    foreign key (recipe_id) references recipes(id),
    foreign key (ingredient_id) references ingredients(id),
    foreign key (unit_id) references units(id)
);

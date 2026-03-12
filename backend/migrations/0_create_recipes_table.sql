create table if not exists recipes (
    id integer primary key autoincrement,
    title text not null,
    instructions text not null,
    number_of_servings integer not null,
    created_at text not null default (datetime('now'))
);

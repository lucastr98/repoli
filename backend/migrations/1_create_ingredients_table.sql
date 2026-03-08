create table if not exists ingredients (
    id integer primary key autoincrement,
    name text not null,
    created_at text not null default (datetime('now'))
);

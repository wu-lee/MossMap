
CREATE TABLE data_set (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    created_on TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE taxa (
    id INTEGER UNIQUE NOT NULL,
    name TEXT PRIMARY KEY
);

CREATE TABLE records (
    id INTEGER PRIMARY KEY,
    data_set_id INTEGER NOT NULL,
    grid_ref TEXT NOT NULL,
    taxon INTEGER NOT NULL REFERENCES taxa(id),
    recorder INTEGER NOT NULL REFERENCES recorders(id),
    recorded_on TEXT NOT NULL
);

CREATE TABLE recorders (
   id INTEGER PRIMARY KEY,
   name TEXT NOT NULL
);

CREATE TABLE users (
   id INTEGER PRIMARY KEY,
   name TEXT NOT NULL,
   email TEXT NOT NULL,
   password TEXT NOT NULL
);

CREATE TABLE meta (
   version INTEGER PRIMARY KEY
);

-- config?
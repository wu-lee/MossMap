
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
    data_set_id INTEGER NOT NULL REFERENCES data_set(id) 
    ON DELETE CASCADE ON UPDATE CASCADE,
    grid_ref TEXT NOT NULL,
    taxon INTEGER NOT NULL REFERENCES taxa(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
    recorder INTEGER NOT NULL REFERENCES recorders(id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
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

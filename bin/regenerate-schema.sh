#!/bin/sh

# Run this to create or update the DBIx::Class schema in
# MossMap::Schema from the contents of a SQLite database
# in ../db/moss-map.db (relative to this file)

basedir="${0%/*}/.."

cd $basedir


dbicdump -o "dump_directory=lib" \
    -o components='["InflateColumn::DateTime"]' \
    MossMap::Schema \
    "dbi:SQLite:db/moss-map.db"

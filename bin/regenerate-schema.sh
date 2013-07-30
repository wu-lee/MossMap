#!/bin/sh

# Run this to create or update the DBIx::Class schema in
# MossMap::Schema from the contents of a SQLite database
# in ../db/moss-map.db (relative to this file)

basedir="${0%/*}/.."

cd $basedir

schema_class MossMap::Schema

lib lib

# FIXME unfinished    
    # connection string
    <connect_info>
        dsn     dbi:mysql:example
        user    root
        pass    secret
    </connect_info>
    
    # dbic loader options
    <loader_options>
        components  InflateColumn::DateTime
        components  TimeStamp
    </loader_options>

dbicdump -o "dump_directory=$basedir/lib" \
    -o components='["InflateColumn::DateTime"]' \
    MossMap::Schema \
    "dbi:SQLite:$basedir/db/moss-map.db"

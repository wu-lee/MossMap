#!/usr/bin/perl
use Mojolicious::Lite;
use DBI;

my $db_path = $ENV{MOSSMAP_DB} || app->home->rel_file('db/moss-map.db');
my $dbh = DBI->connect("dbi:SQLite:$db_path");

# dbh is a database handle already connected to the database
plugin 'SQLiteViewerLite', dbh => $dbh;

# Mojolicious
app->plugin('SQLiteViewerLite', dbh => $dbh);

app->start;

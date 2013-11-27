
use strict;
use warnings;

use Module::Build 0.2808;


my %module_build_args = (
  "build_requires" => {
    "Module::Build" => "0.2808"
  },
  "configure_requires" => {
    "Module::Build" => "0.2808"
  },
  "dist_abstract" => "a map of (bryological) observations",
  "dist_author" => [
    "Nick Stokoe <wulee\@cpan.org>"
  ],
  "dist_name" => "MossMap",
  "dist_version" => "0.1.0",
  "license" => "perl",
  "module_name" => "MossMap",
  "recommends" => {
    "Test::Pod" => "1.14",
    "Test::Pod::Coverage" => "1.04"
  },
  "recursive_test_files" => 1,
  "requires" => {
    "DBIx::Class" => "0.08250",
    "DBIx::Class::Schema::Loader" => "0.07036",
    "JSON::PP" => 0,
    "Module::Build" => "0.2808",
    "Mojolicious" => "4.18",
    "Mojolicious::Plugin::Authentication" => "1.25",
    "Text::CSV" => "1.21"
  },
  "script_files" => [
    "bin/app-env",
    "bin/regenerate-schema.sh"
  ],
  "test_requires" => {
    "IO::String" => 0,
    "Pod::Coverage::TrustPod" => 0,
    "SQL::Translator" => "0.11018",
    "Test::DataDirs" => "0.001000"
  }
);


my %fallback_build_requires = (
  "IO::String" => 0,
  "Module::Build" => "0.2808",
  "Pod::Coverage::TrustPod" => 0,
  "SQL::Translator" => "0.11018",
  "Test::DataDirs" => "0.001000"
);


unless ( eval { Module::Build->VERSION(0.4004) } ) {
  delete $module_build_args{test_requires};
  $module_build_args{build_requires} = \%fallback_build_requires;
}

my $build = Module::Build->new(%module_build_args);

$build->create_build_script;

requires "DBIx::Class" => "0.08250";
requires "DBIx::Class::Schema::Loader" => "0.07036";
requires "JSON::PP" => "0";
requires "Module::Build" => "0.2808";
requires "Mojolicious" => "4.18";
requires "Mojolicious::Plugin::Authentication" => "1.25";
requires "Text::CSV" => "1.21";
recommends "Test::Pod" => "1.14";
recommends "Test::Pod::Coverage" => "1.04";

on 'build' => sub {
  requires "Module::Build" => "0.2808";
};

on 'test' => sub {
  requires "IO::String" => "0";
  requires "Pod::Coverage::TrustPod" => "0";
  requires "SQL::Translator" => "0.11018";
  requires "Test::DataDirs" => "0.001000";
};

on 'configure' => sub {
  requires "Module::Build" => "0.2808";
};

on 'develop' => sub {
  requires "Pod::Coverage::TrustPod" => "0";
  requires "Test::Pod" => "1.41";
  requires "Test::Pod::Coverage" => "1.08";
};

use utf8;
package MossMap::Schema::Result::Meta;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::Meta

=head1 VERSION

version 0.1.0

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<meta>

=cut

__PACKAGE__->table("meta");

=head1 ACCESSORS

=head2 version

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "version",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</version>

=back

=cut

__PACKAGE__->set_primary_key("version");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-07-22 00:19:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Mgj3Z6BiYdfixAbKZpRp+w


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

use utf8;
package MossMap::Schema::Result::CompletedTetrad;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::CompletedTetrad

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

=head1 TABLE: C<completed_tetrads>

=cut

__PACKAGE__->table("completed_tetrads");

=head1 ACCESSORS

=head2 completion_set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 grid_ref

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "completion_set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "grid_ref",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</completion_set_id>

=item * L</grid_ref>

=back

=cut

__PACKAGE__->set_primary_key("completion_set_id", "grid_ref");

=head1 RELATIONS

=head2 completion_set

Type: belongs_to

Related object: L<MossMap::Schema::Result::CompletionSet>

=cut

__PACKAGE__->belongs_to(
  "completion_set",
  "MossMap::Schema::Result::CompletionSet",
  { id => "completion_set_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-15 22:42:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Fz3yZkjbvrQUR9dA/fwmQA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

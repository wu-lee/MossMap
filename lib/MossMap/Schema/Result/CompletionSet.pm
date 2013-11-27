use utf8;
package MossMap::Schema::Result::CompletionSet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::CompletionSet

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

=head1 TABLE: C<completion_set>

=cut

__PACKAGE__->table("completion_set");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 0

=head2 created_on

  data_type: 'text'
  default_value: current_timestamp
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 0 },
  "created_on",
  {
    data_type     => "text",
    default_value => \"current_timestamp",
    is_nullable   => 0,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 completed_tetrads

Type: has_many

Related object: L<MossMap::Schema::Result::CompletedTetrad>

=cut

__PACKAGE__->has_many(
  "completed_tetrads",
  "MossMap::Schema::Result::CompletedTetrad",
  { "foreign.completion_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-15 22:42:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:uC7o35vgmWPzs0P+rLSrzg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

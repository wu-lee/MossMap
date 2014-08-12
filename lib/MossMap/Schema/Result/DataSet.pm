use utf8;
package MossMap::Schema::Result::DataSet;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::DataSet

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

=head1 TABLE: C<data_set>

=cut

__PACKAGE__->table("data_set");

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

=head2 records

Type: has_many

Related object: L<MossMap::Schema::Result::Record>

=cut

__PACKAGE__->has_many(
  "records",
  "MossMap::Schema::Result::Record",
  { "foreign.data_set_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-15 22:42:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1WLTf5Wzmc5+VtqwRNAjSA


# You can replace this text with custom code or comments, and it will be preserved on regeneration

#__PACKAGE__->has_many(
#  "records",
#  "MossMap::Schema::Result::Record",
#  { "foreign.data_set" => "self.id" },
#  { cascade_copy => 1, cascade_delete => 1 },
#);

1;

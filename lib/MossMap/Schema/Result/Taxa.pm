use utf8;
package MossMap::Schema::Result::Taxa;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::Taxa

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

=head1 TABLE: C<taxa>

=cut

__PACKAGE__->table("taxa");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "text", is_nullable => 1 },
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
  { "foreign.taxon" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-10-13 10:48:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gr/I9iJtfSZk676OqCnZdw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

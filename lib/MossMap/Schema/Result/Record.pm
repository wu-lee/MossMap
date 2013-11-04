use utf8;
package MossMap::Schema::Result::Record;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::Record

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

=head1 TABLE: C<records>

=cut

__PACKAGE__->table("records");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 data_set_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 grid_ref

  data_type: 'text'
  is_nullable: 0

=head2 taxon

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 recorded_on

  data_type: 'text'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "data_set_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "grid_ref",
  { data_type => "text", is_nullable => 0 },
  "taxon",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "recorded_on",
  { data_type => "text", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 data_set

Type: belongs_to

Related object: L<MossMap::Schema::Result::DataSet>

=cut

__PACKAGE__->belongs_to(
  "data_set",
  "MossMap::Schema::Result::DataSet",
  { id => "data_set_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 recorder_records

Type: has_many

Related object: L<MossMap::Schema::Result::RecorderRecord>

=cut

__PACKAGE__->has_many(
  "recorder_records",
  "MossMap::Schema::Result::RecorderRecord",
  { "foreign.record_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 taxon

Type: belongs_to

Related object: L<MossMap::Schema::Result::Taxa>

=cut

__PACKAGE__->belongs_to(
  "taxon",
  "MossMap::Schema::Result::Taxa",
  { id => "taxon" },
  { is_deferrable => 0, on_delete => "RESTRICT", on_update => "CASCADE" },
);

=head2 recorders

Type: many_to_many

Composing rels: L</recorder_records> -> recorder

=cut

__PACKAGE__->many_to_many("recorders", "recorder_records", "recorder");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-11-04 21:33:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ZNkIllH/wf0GwQClT9pxqw


# You can replace this text with custom code or comments, and it will be preserved on regeneration


1;

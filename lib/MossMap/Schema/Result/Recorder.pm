use utf8;
package MossMap::Schema::Result::Recorder;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::Recorder

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

=head1 TABLE: C<recorders>

=cut

__PACKAGE__->table("recorders");

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

=head2 recorder_records

Type: has_many

Related object: L<MossMap::Schema::Result::RecorderRecord>

=cut

__PACKAGE__->has_many(
  "recorder_records",
  "MossMap::Schema::Result::RecorderRecord",
  { "foreign.recorder_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 records

Type: many_to_many

Composing rels: L</recorder_records> -> record

=cut

__PACKAGE__->many_to_many("records", "recorder_records", "record");


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-11-04 21:33:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:aVZJarGCuTXzlalOcrgpog


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

use utf8;
package MossMap::Schema::Result::RecorderRecord;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

MossMap::Schema::Result::RecorderRecord

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

=head1 TABLE: C<recorder_records>

=cut

__PACKAGE__->table("recorder_records");

=head1 ACCESSORS

=head2 record_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 recorder_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "record_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "recorder_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</record_id>

=item * L</recorder_id>

=back

=cut

__PACKAGE__->set_primary_key("record_id", "recorder_id");

=head1 RELATIONS

=head2 record

Type: belongs_to

Related object: L<MossMap::Schema::Result::Record>

=cut

__PACKAGE__->belongs_to(
  "record",
  "MossMap::Schema::Result::Record",
  { id => "record_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 recorder

Type: belongs_to

Related object: L<MossMap::Schema::Result::Recorder>

=cut

__PACKAGE__->belongs_to(
  "recorder",
  "MossMap::Schema::Result::Recorder",
  { id => "recorder_id" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "CASCADE" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-11-04 21:33:05
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:oxPcXhUkHitTdq2ukC/tFg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

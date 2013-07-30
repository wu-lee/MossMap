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

=head2 grid_ref

  data_type: 'text'
  is_nullable: 0

=head2 taxon

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 recorder

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
  "grid_ref",
  { data_type => "text", is_nullable => 0 },
  "taxon",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "recorder",
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

=head2 recorder

Type: belongs_to

Related object: L<MossMap::Schema::Result::Recorder>

=cut

__PACKAGE__->belongs_to(
  "recorder",
  "MossMap::Schema::Result::Recorder",
  { id => "recorder" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);

=head2 taxon

Type: belongs_to

Related object: L<MossMap::Schema::Result::Taxa>

=cut

__PACKAGE__->belongs_to(
  "taxon",
  "MossMap::Schema::Result::Taxa",
  { id => "taxon" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);


# Created by DBIx::Class::Schema::Loader v0.07036 @ 2013-07-22 00:19:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:Ix2NNiNnsu90MmobfU+cfA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;

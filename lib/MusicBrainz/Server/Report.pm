package MusicBrainz::Server::Report;
use Moose::Role;

with 'MusicBrainz::Server::Data::Role::Sql';

use MusicBrainz::Server::Data::Utils qw( query_to_list_limited );
use String::CamelCase qw( decamelize );

requires 'run';

sub qualified_table {
    my $self = shift;
    return join('.', 'report', $self->table);
}

sub table {
    my $self = shift;
    my $name = $self->meta->name;
    $name =~ s/MusicBrainz::Server::Report::(.*)$/$1/;
    return decamelize($name);
}

sub template {
    my $self = shift;
    return 'report/' . $self->table . '.tt';
}

sub load {
    my ($self, $limit, $offset) = @_;
    return $self->_load('', $offset, $limit);
}

sub ordering { "row_number" }

sub inflate_rows {
    my ($self, $rows) = @_;
    return $rows;
}

sub _load {
    my ($self, $join_sql, $offset, $limit, @params) = @_;

    my $qualified_table = $self->qualified_table;
    my $ordering = $self->ordering;
    my ($rows, $total) = query_to_list_limited(
        $self->sql, $offset, $limit, sub { shift },
        "SELECT DISTINCT report.* FROM $qualified_table report $join_sql ORDER BY $ordering OFFSET ?",
        @params, $offset
    );

    $rows = $self->inflate_rows($rows);
    return ($rows, $total);
}

1;

=head1 COPYRIGHT

Copyright (C) 2009 Lukas Lalinsky
Copyright (C) 2012 MetaBrainz Foundation

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

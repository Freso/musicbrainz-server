package MusicBrainz::Server::Report::DiscogsLinksWithMultipleLabels;
use Moose;

extends 'MusicBrainz::Server::Report::LabelReport';

sub gather_data
{
    my ($self, $writer) = @_;

    $self->gather_data_from_query($writer, "
        SELECT
            l.gid AS label_gid, ln.name, q.gid AS url_gid, q.url, q.count
        FROM
            (
                SELECT
                    url.id, url.gid, url, COUNT(*) AS count
                FROM
                    url JOIN l_label_url llu ON llu.entity1 = url.id
                WHERE
                    url ~ '^http://www.discogs.com/'
                GROUP BY
                    url.id, url.gid, url HAVING COUNT(url) > 1
            ) AS q
            JOIN l_label_url llu ON llu.entity1 = q.id
            JOIN label l ON l.id = llu.entity0
            JOIN label_name ln ON ln.id = l.name
        ORDER BY q.count DESC, q.url, musicbrainz_collate(ln.name)
    ");
}

sub template
{
    return 'report/discogs_links_with_multiple_labels.tt';
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;

=head1 COPYRIGHT

Copyright (C) 2012 Johannes Weißl
Copyright (C) 2011 MetaBrainz Foundation

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

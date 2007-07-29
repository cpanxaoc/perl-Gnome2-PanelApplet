package Gnome2::PanelApplet;

# $Id$

use 5.008;
use strict;
use warnings;

use Gnome2;

require DynaLoader;

our @ISA = qw(DynaLoader);

our $VERSION = '0.01';

sub import {
  my $self = shift();
  $self -> VERSION(@_);
}

sub dl_load_flags { 0x01 }

Gnome2::PanelApplet -> bootstrap($VERSION);

1;
__END__

=head1 NAME

Gnome2::PanelApplet - Perl interface to GNOME's applet library

=head1 SYNOPSIS

  ...

=head1 ABSTRACT

...

=head1 SEE ALSO

L<Gnome2::PanelApplet::index>, L<Gnome2>, L<Gtk2>, L<Gtk2::api> and
L<http://developer.gnome.org/doc/API/2.0/panel-applet/>.

=head1 AUTHOR

Emmanuele Bassi E<lt>emmanuele.bassi at iol dot itE<gt>
Torsten Schoenfeld E<lt>kaffeetisch at gmx dot deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2003, 2007 by the gtk2-perl team

This library is free software; you can redistribute it and/or modify it under
the terms of the GNU Lesser General Public License as published by the Free
Software Foundation; either version 2.1 of the License, or (at your option) any
later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU Lesser General Public License for more
details.

You should have received a copy of the GNU Lesser General Public License along
with this library; if not, write to the Free Software Foundation, Inc., 51
Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

=cut

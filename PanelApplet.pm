#
# Copyright (c) 2004 by Emmanuele Bassi (see the file AUTHORS)
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# You should have received a copy of the GNU Library General Public
# License along with this library; if not, write to the 
# Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
# Boston, MA  02111-1307  USA.

package Gnome2::PanelApplet;

use 5.008;
use strict;
use warnings;

use Gtk2;

require Exporter;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Gnome2::GConf ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
	
);

our $VERSION = '0.10';

sub dl_load_flags { 0x01 }

require XSLoader;
XSLoader::load('Gnome2::PanelApplet', $VERSION);

# Preloaded methods go here.

1;
__END__

=head1 NAME

Gnome2::PanelApplet - Perl wrappers for libpanelapplet-2.0

=head1 SYNOPSIS

  use Gnome2::PanelApplet;

=head1 ABSTRACT

  Perl bindings to the 2.0 series of the panel applet libraries, for use with
  gtk2-perl.

=head1 DESCRIPTION

This module binds libpanelapplet-2.0, and allows the creation of panel applets
to be used inside GNOME 2.x Panel.

To discuss gtk2-perl, ask questions and flame/praise the authors,
join gtk-perl-list@gnome.org at lists.gnome.org.

Find out more about Gnome at http://www.gnome.org.

=head1 SEE ALSO

perl(1), Glib(3pm), Gtk2(3pm), Gnome2(3pm).

=head1 AUTHOR

Emmanuele Bassi E<lt>emmanuele.bassi@iol.itE<gt>

gtk2-perl created by the gtk2-perl team: http://gtk2-perl.sf.net

=head1 COPYRIGHT AND LICENSE

Copyright 2003 by Emmanuele Bassi

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Library General Public
License as published by the Free Software Foundation; either
version 2 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Library General Public License for more details.

You should have received a copy of the GNU Library General Public
License along with this library; if not, write to the 
Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
Boston, MA  02111-1307  USA.

=cut

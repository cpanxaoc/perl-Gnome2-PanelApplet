/*
 * Copyright (c) 2004 by Emmanuele Bassi (see the file AUTHORS)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the 
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330, 
 * Boston, MA  02111-1307  USA.
 */

#include "panelappletperl.h"


MODULE = Gnome2::PanelApplet	PACKAGE = Gnome2::PanelApplet	PREFIX = panel_applet_


=for object Gnome2::PanelApplet::main
=cut

BOOT:
#include "register.xsh"
#include "boot.xsh"


=for apidoc
=signature (major_version, minor_version, micro_version) = Gnome2::Panel::GET_VERSION_INFO
=cut
void
GET_VERSION_INFO (class)
    PPCODE:
	EXTEND (SP, 3);
	PUSHs (sv_2mortal (newSViv (PANEL_APPLET_MAJOR_VERSION)));
	PUSHs (sv_2mortal (newSViv (PANEL_APPLET_MINOR_VERSION)));
	PUSHs (sv_2mortal (newSViv (PANEL_APPLET_MICRO_VERSION)));

gboolean
CHECK_VERSION (class, major, minor, micro)
	int major
	int minor
	int micro
    CODE:
	RETVAL = PANEL_APPLET_CHECK_VERSION (major, minor, micro);
    OUTPUT:
	RETVAL

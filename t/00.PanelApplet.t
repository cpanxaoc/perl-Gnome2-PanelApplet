use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('Gnome2::PanelApplet') };

my @version = Gnome2::PanelApplet->get_version_info;
is( @version, 3, 'version is three items long' );

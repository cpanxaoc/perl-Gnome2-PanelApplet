use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('Gnome2::Panel') };

my @version = Gnome2::Panel->get_version_info;
is( @version, 3, 'version is three items long' );

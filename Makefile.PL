use 5.008;
use strict;
use warnings;
use Cwd;
use File::Spec;
use ExtUtils::MakeMaker;

# minimum required version of dependancies we need to build
our %build_reqs = (
	'perl-ExtUtils-Depends'   => '0.1',
	'perl-ExtUtils-PkgConfig' => '0.1',
	'perl-Glib'               => '1.012',
	'perl-Gtk2'               => '1.012',
	'PanelApplet'             => '2.0.0',
);

# Writing a fake Makefile ensures that CPAN will pick up the correct
# dependencies and install them.
unless (eval "use ExtUtils::Depends;"
           . "use ExtUtils::PkgConfig;"
	   . "use Gtk2::CodeGen;"
           # just seeing if Glib is available isn't enough, make sure
           # it's recent enough, too 
           . "use Glib '$build_reqs{'perl-Glib'}';"
           . "use Gtk2 '$build_reqs{'perl-Gtk2'}';"
		   . "use Glib::MakeHelper;"
           . "1") {
   warn "$@\n";
   WriteMakefile(
         PREREQ_FATAL => 1,
         PREREQ_PM    => {
            'Glib'                => $build_reqs{'perl-Glib'},
            'Gtk2'                => $build_reqs{'perl-Gtk2'},
            'ExtUtils::Depends'   => $build_reqs{'perl-ExtUtils-Depends'},
            'ExtUtils::PkgConfig' => $build_reqs{'perl-ExtUtils-PkgConfig'},
         },
   );
   exit 1; # not reached
}

mkdir 'build', 0777;

our %pkgcfg = ExtUtils::PkgConfig->find ('libpanelapplet-2.0 >= '
				     .$build_reqs{PanelApplet});

# now we're ready to start creating the makefile.
# we need to use ExtUtils::Depends to get relevant information out of
# the Glib extension, and to save config information for other modules which
# will chain from this one.

our @xs_files = <xs/*.xs>;
our %pm_files = (
    'PanelApplet.pm'		=> '$(INST_LIBDIR)/PanelApplet.pm',
);
our %pod_files = (
    'PanelApplet.pm'		=> '$(INST_MAN3DIR)/Gnome2::PanelApplet.$(MAN3EXT)',
    Glib::MakeHelper->do_pod_files (@xs_files),
);

open VERSION, ">build/panelappletperl-version.h";

my $stem = "PANEL_APPLET";
my @modversion = split /\./, $pkgcfg{ modversion };
print VERSION "#define $stem\_MAJOR_VERSION   ($modversion[0])\n";
print VERSION "#define $stem\_MINOR_VERSION   ($modversion[1])\n";
print VERSION "#define $stem\_MICRO_VERSION   (" . ($modversion[2] || 0) . ")\n";
print VERSION
    "#define $stem\_CHECK_VERSION(major,minor,micro) \\\n"
  . "    ($stem\_MAJOR_VERSION > (major) || \\\n"
  . "     ($stem\_MAJOR_VERSION == (major) && $stem\_MINOR_VERSION > (minor)) || \\\n"
  . "     ($stem\_MAJOR_VERSION == (major) && $stem\_MINOR_VERSION == (minor) && \\\n"
  . "      $stem\_MICRO_VERSION >= (micro)))\n";

close VERSION;

#
# autogeneration
#
Gtk2::CodeGen->parse_maps ('panelappletperl');
Gtk2::CodeGen->write_boot (ignore => '^Gnome2::PanelApplet$');

my $panel = ExtUtils::Depends->new ('Gnome2::PanelApplet', 'Gnome2', 'Gtk2', 'Glib');
$panel->set_inc ($pkgcfg{cflags} . ' -I. -I./build ');
$panel->set_libs ($pkgcfg{libs});
$panel->add_xs (@xs_files);
$panel->add_pm (%pm_files);
my $cwd = cwd();
$panel->add_typemaps (map {File::Spec->catfile($cwd,$_)} 'build/panelappletperl.typemap');
$panel->add_headers ('panelappletperl.h');
$panel->install (qw(panelappletperl.h
		build/panelappletperl-autogen.h
		build/panelappletperl-version.h));
$panel->save_config ('build/IFiles.pm');

WriteMakefile(
    NAME          => 'Gnome2::PanelApplet',
    VERSION_FROM  => 'PanelApplet.pm', # finds $VERSION
    PREREQ_PM     => {}, # e.g., Module::Name => 1.1
    ABSTRACT_FROM => 'PanelApplet.pm', # retrieve abstract from module
    XSPROTOARG    => '-noprototypes',
    MAN3PODS	  => \%pod_files,
    $panel->get_makefile_vars,
);

print"
WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING

   This module does not work, and it should be considered pre-alpha
   code.  If anyone with some understanding of the Bonobo or the
   libpanelapplet-2.0 internals is willing to give a hand in making
   this module functional, should contact the gtk2-perl team on the
   mailing list at gtk-perl-list AT gnome DOT org.

WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING 

";

#
# there's a bug in the MakeMaker output which results in .xs files in a
# subdirectory being turned into .o files in this dir.  the bug is a missing
# -o on the compiler command line.  this is a hackish fix for it.
#
package MY;
use Cwd;

sub const_cccmd {
	my $inherited = shift->SUPER::const_cccmd (@_);
	$inherited .= ' -o $@';
	$inherited;
}

sub postamble
{
	return Glib::MakeHelper->postamble_clean ()
	     . Glib::MakeHelper->postamble_docs (@main::xs_files)
	     . Glib::MakeHelper->postamble_rpms (
		'PANEL_APPLET' => $build_reqs{'PanelApplet'},
		'PERL_EXTUTILS_DEPENDS' => 
			$build_reqs{'perl-ExtUtils-Depends'},
		'PERL_EXTUTILS_PKGCONFIG' => 
			$build_reqs{'perl-ExtUtils-PkgConfig'},
		'PERL_GLIB' => $build_reqs{'perl-Glib'},
		'PERL_GTK' => $build_reqs{'perl-Gtk2'},
	       );
}
package MAIN;

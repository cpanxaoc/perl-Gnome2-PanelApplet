/*
 * Copyright (c) 2003 by Emmanuele Bassi (see the file AUTHORS)
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

/* taken from Gnome2/xs/GnomeProgram.xs */
static void
handle_argv (int *argc, char **argv[])
{
	AV * ARGV;
	SV * ARGV0;
	int len, i;

	*argv = NULL;
	ARGV = get_av ("ARGV", FALSE);
	ARGV0 = get_sv ("0", FALSE);

	/* construct the argv argument... we'll have to prepend @ARGV with $0
	 * to make it look real. */
	len = av_len (ARGV) + 1;
	*argc = len + 1;
	*argv = g_new0 (char*, *argc);
	(*argv)[0] = SvPV_nolen (ARGV0);
#ifdef NOISY
	warn ("argc = %d\n", *argc);
	warn ("argv[0] = %s\n", *argv[0]);
#endif
	for (i = 0 ; i < len ; i++) {
		SV ** sv = av_fetch (ARGV, i, FALSE);
		(*argv)[i+1] = sv ? SvPV_nolen (*sv) : "";
#ifdef NOISY
		warn ("argv[%d] = %s\n", i+1, *argv[i+1]);
#endif
	}
}

static void
add_verb_from_sv (BonoboUIComponent *component, SV *data, SV *extra_data)
{
	HV * h;
	AV * a;
	SV ** s;
	SV * callback;
	gchar * cname;
	GClosure * closure;
	STRLEN len;

	if ((!data) || (!SvOK (data)) || (!SvRV (data)) || 
	    (SvTYPE (SvRV (data)) != SVt_PVHV && SvTYPE (SvRV(data)) != SVt_PVAV))
		croak ("a verb entry must be a reference to a hash "
		       "containing the keys 'name' and 'callback', "
		       "or a reference to a two-element list containing "
		       "the information in the order name and callback");

	if (SvTYPE (SvRV (data)) == SVt_PVHV) {
		h = (HV*) SvRV (data);
		if ((s=hv_fetch (h, "name", 4, 0)) && SvOK (*s))
			cname = SvPV (*s, len);
		if ((s=hv_fetch (h, "callback", 8, 0)) && SvOK (*s))
			callback = *s;
	} else {
		a = (AV*)SvRV (data);
		if ((s=av_fetch (a, 0, 0)) && SvOK (*s))
			cname = SvPV (*s, len);
		if ((s=av_fetch (a, 1, 0)) && SvOK (*s))
			callback = *s;
	}

#ifdef NOISY
	warn ("verb:cname = %s\n", cname);
#endif
	closure = gperl_closure_new (callback, extra_data, FALSE);
	bonobo_ui_component_add_verb_full (component, cname, closure);
}


MODULE = Gnome2::PanelApplet::Applet	PACKAGE = Gnome2::PanelApplet::Applet	PREFIX = panel_applet_

gulong
orient(class)
	SV * class
    ALIAS:
	Gnome2::PanelApplet::OrientUp    = 0
	Gnome2::PanelApplet::OrientDown  = 1
	Gnome2::PanelApplet::OrientLeft  = 2
	Gnome2::PanelApplet::OrientRight = 3
    CODE:
	switch (ix) {
		case 0: RETVAL = PANEL_APPLET_ORIENT_UP;    break;
		case 1: RETVAL = PANEL_APPLET_ORIENT_DOWN;  break;
		case 2: RETVAL = PANEL_APPLET_ORIENT_LEFT;  break;
		case 3: RETVAL = PANEL_APPLET_ORIENT_RIGHT; break;
	}
    OUTPUT:
    	RETVAL

GtkWidget *
panel_applet_new (class)
    C_ARGS:
	/* void */


=for apidoc
=for arg iid the IID string
=for arg type the perl package name (usually, 'Gnome2::PanelApplet')
=for arg name the name of the applet
=for arg version the version of the applet
=for arg func a callback (must return FALSE on failure)
=for arg data optional data to pass to the callback

This is a class method that should be invoked when creating a new applet.  It
should be located at the end of the C< main > package.
=cut
void
panel_applet_bonobo_factory (class, iid, type, name, version, func, data=NULL)
	const gchar *iid
	const gchar *type
	const gchar *name
	const gchar *version
	SV * func
	SV * data
    PREINIT:
	int argc, i;
	char **argv;
	GType real_type;
    CODE:
    	real_type = gperl_type_from_package (type);
	if (0 == real_type)
		croak("type must be a Gnome2::Panel::Applet object");
#ifdef NOISY
	warn("real_type: %d\n", real_type);
	warn("package from real_type: %s\n", gperl_package_from_type (real_type));
	
	warn("iid: %s\n", iid);
#endif
	/* create argv from $0 + @ARGV */
	handle_argv (&argc, &argv);

	/* gnome-python uses GNOME_PARAM_NONE, but in panel-applet.h we have
	 * PANEL_APPLET_BONOBO_FACTORY launching gnome_program_init with the 
	 * (GNOME_CLIENT_PARAM_SM_CONNECT, FALSE) tuple. */
	gnome_program_init (name, version,
			LIBGNOMEUI_MODULE,
			argc, argv,
			GNOME_CLIENT_PARAM_SM_CONNECT, FALSE,
			GNOME_PARAM_NONE);
	
	/* since the panel-applet people kindly gave us the ability to use a
	 * GClosure, let's not turn them down by not using it. */
	panel_applet_factory_main_closure (iid, real_type,
			gperl_closure_new (func, data, FALSE));
	
	/* free the collection: the strings inside it are still held by SV */
	g_free (argv);

###PanelAppletOrient  panel_applet_get_orient           (PanelApplet *applet);
gulong
panel_applet_get_orient (PanelApplet * applet)

###guint              panel_applet_get_size             (PanelApplet *applet);
guint
panel_applet_get_size (PanelApplet * applet)

###PanelAppletBackgroundType
###                   panel_applet_get_background       (PanelApplet *applet,
###						      /* return values */
###						      GdkColor    *color,
###						      GdkPixmap  **pixmap);

###gchar             *panel_applet_get_preferences_key  (PanelApplet *applet);
gchar *
panel_applet_get_preferences_key (PanelApplet * applet)

###void               panel_applet_add_preferences      (PanelApplet  *applet,
###						      const gchar  *schema_dir,
###						      GError      **opt_error);
void
panel_applet_add_preferences (applet, schema_dir)
	PanelApplet * applet
	const gchar * schema_dir
    PREINIT:
	GError *err = NULL;
    CODE:
    	panel_applet_add_preferences (applet, schema_dir, &err);
	if (err)
		gperl_croak_gerror (schema_dir, err);

###PanelAppletFlags   panel_applet_get_flags            (PanelApplet      *applet);
###void      	   panel_applet_set_flags            (PanelApplet      *applet,
###						      PanelAppletFlags  flags);
###

###void      	   panel_applet_set_size_hints       (PanelApplet      *applet,
###						      const int        *size_hints,
###						      int               n_elements,
###						      int               base_size);

### Until we have a bonobo binding, these two methods will not be available.
###BonoboControl     *panel_applet_get_control          (PanelApplet  *applet);
###BonoboUIComponent *panel_applet_get_popup_component  (PanelApplet  *applet);

###void               panel_applet_setup_menu           (PanelApplet        *applet,
###						      const gchar        *xml,
###						      const BonoboUIVerb *verb_list,
###						      gpointer            user_data);
void
panel_applet_setup_menu (applet, xml, verb_list, user_data=NULL)
	PanelApplet * applet
	const gchar * xml
	SV * verb_list
	SV * user_data
    PREINIT:
	BonoboUIComponent * popup_component;
	AV * a;
	int i;
    CODE:
	/* Copied from panel-applet.c */
	popup_component = panel_applet_get_popup_component (PANEL_APPLET (applet));
	bonobo_ui_component_set (popup_component, "/", "<popups/>", NULL);
	bonobo_ui_component_set_translate (popup_component, "/popups", xml, NULL);
	/* end copy */

	if ((!verb_list) || (!SvOK (verb_list)) || (!SvRV (verb_list)) ||
	    (SvTYPE (SvRV(verb_list)) != SVt_PVAV))
		croak ("a verb_list must be an arrayref containing the "
		       "information about the verb");
	
	a = (AV*)SvRV (verb_list);
	for (i = 0; i < av_len (a); i++) {
		SV ** s;
		add_verb_from_sv (popup_component, *s, user_data);
	}

###void               panel_applet_setup_menu_from_file (PanelApplet        *applet,
###						      const gchar        *opt_datadir,
###						      const gchar        *file,
###						      const gchar        *opt_app_name,
###						      const BonoboUIVerb *verb_list,
###						      gpointer            user_data);
###
void
panel_applet_setup_menu_from_file (applet, opt_datadir, file, opt_app_name, verb_list, user_data)
	PanelApplet * applet
	const gchar * opt_datadir
	const gchar * file
	const gchar * opt_app_name
	SV * verb_list
	SV * user_data
    PREINIT:
	BonoboUIComponent * popup_component;
	AV * a;
	int i;
	gchar * app_name = NULL;
    CODE:
	/* Copied from panel-applet.c */
	if (!opt_app_name)
		opt_app_name = app_name = g_strdup_printf ("%d", getpid ());

	popup_component = panel_applet_get_popup_component (PANEL_APPLET (applet));
	bonobo_ui_util_set_ui (popup_component, opt_datadir, file, opt_app_name, NULL);
	/* end copy */

	if ((!verb_list) || (!SvOK (verb_list)) || (!SvRV (verb_list)) ||
	    (SvTYPE (SvRV(verb_list)) != SVt_PVAV))
		croak ("a verb_list must be an arrayref containing the "
		       "information about the verb");
	
	a = (AV*)SvRV (verb_list);
	for (i = 0; i < av_len (a); i++) {
		SV ** s;
		add_verb_from_sv (popup_component, *s, user_data);
	}
	
	if (app_name)
		g_free (app_name);
	

###int                panel_applet_factory_main          (const gchar		  *iid,
###						       GType                       applet_type,
###						       PanelAppletFactoryCallback  callback,
###						       gpointer			   data);

### This also is a class method, although you should never use this directly;
### use Gnome2::PanelApplet->bonobo_factory instead.
###int                panel_applet_factory_main_closure  (const gchar		  *iid,
###						       GType                       applet_type,
###						       GClosure                   *closure);
int
panel_applet_factory_main_closure (class, iid, type, closure)
	const gchar * iid
	const gchar * type
	SV * closure
    PREINIT:
	GClosure * c;
	GType real_type;
    CODE:
    	c = gperl_closure_new (closure, NULL, FALSE);
	real_type = gperl_type_from_package (type);
	RETVAL = panel_applet_factory_main_closure (iid, real_type, c);
    OUTPUT:
    	RETVAL

###Bonobo_Unknown     panel_applet_shlib_factory         (const char                 *iid,
###						       GType                       applet_type,
###						       PortableServer_POA          poa,
###						       gpointer                    impl_ptr,
###						       PanelAppletFactoryCallback  callback,
###						       gpointer                    user_data,
###						       CORBA_Environment          *ev);
###
###Bonobo_Unknown	   panel_applet_shlib_factory_closure (const char                 *iid,
###						       GType                       applet_type,
###						       PortableServer_POA          poa,
###						       gpointer                    impl_ptr,
###						       GClosure                   *closure,
###						       CORBA_Environment          *ev);
###

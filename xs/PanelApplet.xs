/*
 * Copyright (C) 2007 by the gtk2-perl team
 *
 * This library is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as published by the
 * Free Software Foundation; either version 2.1 of the License, or (at your
 * option) any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 * $Id$
 */

#include "libpanelapplet-perl.h"
#include <gperl_marshal.h>

/* ------------------------------------------------------------------------- */

static GPerlCallback *
factory_callback_create (SV *func, SV *data)
{
	GType param_types [] = {
		PANEL_TYPE_APPLET,
		G_TYPE_STRING
	};
	return gperl_callback_new (func, data, G_N_ELEMENTS (param_types),
				   param_types, G_TYPE_BOOLEAN);
}

static gboolean
factory_callback (PanelApplet *applet,
		  const gchar *iid,
		  gpointer     data)
{
	GPerlCallback *callback = (GPerlCallback *) data;
	GValue value = {0,};
	gboolean retval;

	g_value_init (&value, callback->return_type);
	gperl_callback_invoke (callback, &value, applet, iid, data);
	retval = g_value_get_boolean (&value);
	g_value_unset (&value);

	return retval;
}

/* ------------------------------------------------------------------------- */

static GPerlCallback *
verb_func_create (SV *func, SV *data)
{
	return gperl_callback_new (func, data, 0, NULL, 0);
}

static void
verb_func (BonoboUIComponent *component,
	   gpointer           user_data,
	   const char        *cname)
{
	GPerlCallback *callback = user_data;

	dGPERL_CALLBACK_MARSHAL_SP;
	GPERL_CALLBACK_MARSHAL_INIT (callback);

	ENTER;
	SAVETMPS;
	PUSHMARK (SP);

	EXTEND (sp, 3);
	PUSHs (&PL_sv_undef); /* FIXME: Use newSVBonoboUIComponent once we have it. */
	PUSHs (callback->data ? callback->data : &PL_sv_undef);
	PUSHs (sv_2mortal (newSVpv (cname, PL_na)));

	PUTBACK;

	call_sv (callback->func, G_DISCARD);

	FREETMPS;
	LEAVE;
}

/* ------------------------------------------------------------------------- */

static BonoboUIVerb *
SvBonoboUIVerbList (SV *sv, SV *default_data)
{
	HV *hv;
	HE *he;
	int n_keys, i;
	BonoboUIVerb *verb_list;

	if (! (SvOK (sv) && SvRV (sv) && SvTYPE (SvRV (sv)) == SVt_PVHV))
		croak ("the verb list must be a hash reference mapping names to callbacks");

	hv = (HV *) SvRV (sv);

	n_keys = hv_iterinit (hv);
	verb_list = g_new0 (BonoboUIVerb, n_keys + 1);
	i = 0;
	while (NULL != (he = hv_iternext (hv))) {
		char *name;
		I32 length;
		SV *ref, *func, *data;
		GPerlCallback *callback;

		name = hv_iterkey (he, &length);
		ref = hv_iterval (hv, he);

		if (! (SvOK (ref) && SvRV (ref) &&
		      (SvTYPE (SvRV (ref)) == SVt_PVAV || SvTYPE (SvRV (ref)) == SVt_PVCV)))
			croak ("the verbs must either be a code ref or an array ref containing a code ref and user data");

		if (SvTYPE (SvRV (ref)) == SVt_PVAV) {
			AV *av = (AV *) SvRV (ref);
			SV **svp;

			svp = av_fetch (av, 0, 0);
			if (! (svp && SvOK (*svp)))
				croak ("undefined code ref encountered");
			func = *svp;

			svp = av_fetch (av, 1, 0);
			data = (svp && SvOK (*svp)) ? *svp : NULL;
		} else {
			func = ref;
			data = default_data;
		}

		callback = verb_func_create (func, data);
		verb_list[i].cname = name;
		verb_list[i].cb = verb_func;
		verb_list[i].user_data = callback;
		i++;
	}

	return verb_list;
}

/* ------------------------------------------------------------------------- */

MODULE = Gnome2::PanelApplet	PACKAGE = Gnome2::PanelApplet	PREFIX = panel_applet_

BOOT:
#include "register.xsh"
#include "boot.xsh"

=for object Gnome2::PanelApplet::main
=cut

# void panel_applet_setup_menu (PanelApplet *applet, const gchar *xml, const BonoboUIVerb *verb_list, gpointer user_data);
void
panel_applet_setup_menu (PanelApplet *applet, const gchar *xml, SV *verb_list, SV *default_data=NULL)
    PREINIT:
	BonoboUIVerb *real_verb_list;
    CODE:
	real_verb_list = SvBonoboUIVerbList (verb_list, default_data);
	panel_applet_setup_menu (applet, xml, real_verb_list, NULL);
	/* FIXME: Free real_verb_list when applet dies of old age. */

MODULE = Gnome2::PanelApplet	PACKAGE = Gnome2::PanelApplet::Factory	PREFIX = panel_applet_factory_

=for apidoc
=for arg iid the IID string
=for arg applet_type the Perl package name (usually, 'Gnome2::PanelApplet')
=for arg func a callback (must return FALSE on failure)
=for arg data optional data to pass to the callback
=cut
# int panel_applet_factory_main (const gchar *iid, GType applet_type, PanelAppletFactoryCallback callback, gpointer data);
# int panel_applet_factory_main_closure (const gchar *iid, GType applet_type, GClosure *closure);
int
panel_applet_factory_main (class, const gchar *iid, const char *applet_type, SV *func, SV *data=NULL)
    PREINIT:
	GPerlCallback *callback;
    CODE:
	callback = factory_callback_create (func, data);
	RETVAL = panel_applet_factory_main (iid,
					    gperl_type_from_package (applet_type),
					    factory_callback,
					    callback);
	gperl_callback_destroy (callback);
    OUTPUT:
	RETVAL

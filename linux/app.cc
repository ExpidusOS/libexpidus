#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <expidus/app.h>
#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

#include "expidus_plugin_private.h"

struct _ExpidusApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(ExpidusApplication, expidus_application, GTK_TYPE_APPLICATION)

// Implements GApplication::activate.
static void expidus_application_activate(GApplication* application) {
  ExpidusApplication* self = EXPIDUS_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  auto bdw = bitsdojo_window_from(window);
  bdw->setCustomFrame(true);
  gtk_widget_show(GTK_WIDGET(window));

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  ExpidusPlugin* plugin = EXPIDUS_PLUGIN(g_object_get_data(G_OBJECT(view), "ExpidusPlugin"));
  expidus_plugin_set_window(plugin, window);

  GdkRGBA accentColor;
	GtkStyleContext *context = gtk_widget_get_style_context(GTK_WIDGET(view));
	gtk_style_context_lookup_color(context, "theme_selected_fg_color", &accentColor);

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean expidus_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  ExpidusApplication* self = EXPIDUS_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void expidus_application_startup(GApplication* application) {
  //ExpidusApplication* self = EXPIDUS_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(expidus_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void expidus_application_shutdown(GApplication* application) {
  //ExpidusApplication* self = EXPIDUS_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(expidus_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void expidus_application_dispose(GObject* object) {
  ExpidusApplication* self = EXPIDUS_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(expidus_application_parent_class)->dispose(object);
}

static void expidus_application_class_init(ExpidusApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = expidus_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = expidus_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = expidus_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = expidus_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = expidus_application_dispose;
}

static void expidus_application_init(ExpidusApplication* self) {}

ExpidusApplication* expidus_application_new(const gchar* app_id) {
  return EXPIDUS_APPLICATION(g_object_new(expidus_application_get_type(),
                                     "application-id", app_id,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}

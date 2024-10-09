#include <expidus/app.h>
#include <expidus/win.h>
#include <flutter_linux/flutter_linux.h>

#include "flutter/generated_plugin_registrant.h"

struct _ExpidusApplication {
  FlApplication parent_instance;
};

G_DEFINE_TYPE(ExpidusApplication, expidus_application, fl_application_get_type())

static void expidus_application_register_plugins(FlApplication* app, FlPluginRegistry* registry) {
  (void)app;

  fl_register_plugins(registry);
}

static GtkWindow* expidus_application_create_window(FlApplication* app, FlView* view) {
  return expidus_window_new(GTK_APPLICATION(app), view);
}

static void expidus_application_class_init(ExpidusApplicationClass* klass) {
  FL_APPLICATION_CLASS(klass)->register_plugins = expidus_application_register_plugins;
  FL_APPLICATION_CLASS(klass)->create_window = expidus_application_create_window;
}

static void expidus_application_init(ExpidusApplication* self) {}

ExpidusApplication* expidus_application_new(const gchar* app_id) {
  return EXPIDUS_APPLICATION(g_object_new(expidus_application_get_type(),
                                     "application-id", app_id,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}

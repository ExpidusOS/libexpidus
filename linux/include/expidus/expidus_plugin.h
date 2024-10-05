#ifndef FLUTTER_PLUGIN_EXPIDUS_PLUGIN_H_
#define FLUTTER_PLUGIN_EXPIDUS_PLUGIN_H_

#include <flutter_linux/flutter_linux.h>

G_BEGIN_DECLS

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __attribute__((visibility("default")))
#else
#define FLUTTER_PLUGIN_EXPORT
#endif

typedef struct _ExpidusPlugin ExpidusPlugin;
typedef struct {
  GObjectClass parent_class;
} ExpidusPluginClass;

FLUTTER_PLUGIN_EXPORT GType expidus_plugin_get_type();

FLUTTER_PLUGIN_EXPORT void expidus_plugin_register_with_registrar(
    FlPluginRegistrar* registrar);

FLUTTER_PLUGIN_EXPORT void expidus_plugin_set_window(ExpidusPlugin* self, GtkWindow* window);

G_END_DECLS

#endif  // FLUTTER_PLUGIN_EXPIDUS_PLUGIN_H_

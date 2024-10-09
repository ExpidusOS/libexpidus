#include <flutter_linux/flutter_linux.h>

#include "include/expidus/expidus_plugin.h"

// This file exposes some plugin internals for unit testing. See
// https://github.com/flutter/flutter/issues/88724 for current limitations
// in the unit-testable API.

struct _ExpidusPlugin {
  GObject parent_instance;
  gboolean has_layer;
  GList* monitors;
  FlPluginRegistrar* registrar;
};

#define EXPIDUS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), expidus_plugin_get_type(), \
                              ExpidusPlugin))

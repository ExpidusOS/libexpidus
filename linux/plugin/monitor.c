#include "../include/expidus/monitor.h"
#include "monitor-private.h"

G_DEFINE_TYPE(ExpidusMonitor, expidus_monitor, g_object_get_type())

static void expidus_monitor_dispose(GObject* object) {
  ExpidusMonitor* self = EXPIDUS_MONITOR(object);

  g_clear_pointer((gpointer*)&self->name, g_free);

  G_OBJECT_CLASS(expidus_monitor_parent_class)->dispose(object);
}

static void expidus_monitor_class_init(ExpidusMonitorClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = expidus_monitor_dispose;
}

static void expidus_monitor_init(ExpidusMonitor* self) {
  self->scale = 1;
  self->name = NULL;
}

ExpidusMonitor* expidus_monitor_new() {
  return EXPIDUS_MONITOR(g_object_new(expidus_monitor_get_type(), NULL));
}

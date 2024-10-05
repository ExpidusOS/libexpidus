#pragma once

#include "../include/expidus/monitor.h"

struct _ExpidusMonitor {
  GObject parent_instance;
  int x;
  int y;
  int width;
  int height;
  int scale;
  const gchar* name;
};

#define EXPIDUS_MONITOR(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), expidus_monitor_get_type(), \
                              ExpidusMonitor))

ExpidusMonitor* expidus_monitor_new();

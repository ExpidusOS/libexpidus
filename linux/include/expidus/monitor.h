#pragma once

#include <glib-object.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _ExpidusMonitor ExpidusMonitor;
typedef struct {
  GObjectClass parent_class;
} ExpidusMonitorClass;

GType expidus_monitor_get_type();

#ifdef __cplusplus
}
#endif

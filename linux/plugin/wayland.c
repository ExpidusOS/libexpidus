#include <gdk/gdkwayland.h>
#include <wayland-client.h>
#include "../include/expidus/monitor.h"
#include "../expidus_plugin_private.h"
#include "monitor-private.h"
#include "wayland.h"

static void wl_output_geometry(void* data, struct wl_output* wl_output, int32_t x, int32_t y, int32_t phys_width, int32_t phys_height, int32_t subpixel, const char* make, const char* model, int32_t transform) {
  ExpidusMonitor* monitor = EXPIDUS_MONITOR(data);

  (void)wl_output;
  (void)phys_width;
  (void)phys_height;
  (void)subpixel;
  (void)transform;

  monitor->x = x;
  monitor->y = y;
}

static void wl_output_mode(void* data, struct wl_output* wl_output, uint32_t flags, int32_t width, int32_t height, int32_t refresh) {
  ExpidusMonitor* monitor = EXPIDUS_MONITOR(data);

  (void)wl_output;
  (void)flags;
  (void)refresh;

  monitor->width = width;
  monitor->height = height;
}

static void wl_output_done(void* data, struct wl_output* wl_output) {
  (void)data;
  (void)wl_output;
}

static void wl_output_scale(void* data, struct wl_output* wl_output, int32_t factor) {
  ExpidusMonitor* monitor = EXPIDUS_MONITOR(data);

  (void)data;
  (void)wl_output;

  monitor->scale = factor;
}

static void wl_output_name(void* data, struct wl_output* wl_output, const char* name) {
  ExpidusMonitor* monitor = EXPIDUS_MONITOR(data);

  (void)wl_output;

  monitor->name = g_strdup(name);
}

static void wl_output_desc(void* data, struct wl_output* wl_output, const char* desc) {
  (void)data;
  (void)wl_output;
  (void)desc;
}

static struct wl_output_listener output_listener = {
  wl_output_geometry,
  wl_output_mode,
  wl_output_done,
  wl_output_scale,
  wl_output_name,
  wl_output_desc,
};

static void handle_global(void* data, struct wl_registry* registry, uint32_t id, const char* iface, uint32_t ver) {
  ExpidusPlugin* plugin = EXPIDUS_PLUGIN(data);

  if (g_strcmp0(iface, "wl_output") == 0) {
    ExpidusMonitor* monitor = expidus_monitor_new();

    struct wl_output* wl_output = (struct wl_output*)wl_registry_bind(registry, id, &wl_output_interface, ver);
    wl_output_add_listener(wl_output, &output_listener, monitor);

    FlView* view = fl_plugin_registrar_get_view(plugin->registrar);
    GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(view));

    struct wl_display* wl_display = gdk_wayland_display_get_wl_display(display);
    wl_display_roundtrip(wl_display);

    plugin->monitors = g_list_append(plugin->monitors, monitor);
  }
}

static void handle_global_remove(void* data, struct wl_registry* registry, uint32_t id) {
  (void)data;
  (void)registry;
  (void)id;
}

static struct wl_registry_listener registry_listener = {
  handle_global,
  handle_global_remove,
};

void expidus_plugin_wayland_init(ExpidusPlugin* plugin) {
  FlView* view = fl_plugin_registrar_get_view(plugin->registrar);
  GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(view));

  struct wl_display* wl_display = gdk_wayland_display_get_wl_display(display);
  struct wl_registry* wl_registry = wl_display_get_registry(wl_display);

  wl_registry_add_listener(wl_registry, &registry_listener, g_object_ref(plugin));
  wl_display_roundtrip(wl_display);
}

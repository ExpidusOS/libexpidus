#include "include/expidus/expidus_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <gdk/gdkwayland.h>

#include "plugin/monitor-private.h"
#include "plugin/wayland.h"

#ifdef GTK_LAYER_SHELL_FOUND
#include <gtk-layer-shell.h>
#endif

#include "expidus_plugin_private.h"

G_DEFINE_TYPE(ExpidusPlugin, expidus_plugin, g_object_get_type())

#ifdef GTK_LAYER_SHELL_FOUND
static void set_layer_anchor(GtkWindow* window, FlValue* arg, GtkLayerShellEdge edge) {
  gboolean to_edge = fl_value_get_bool(fl_value_lookup_string(arg, "toEdge"));
  int64_t margin = fl_value_get_int(fl_value_lookup_string(arg, "margin"));

  gtk_layer_set_anchor(window, edge, to_edge);
  gtk_layer_set_margin(window, edge, margin);
}
#endif

// Called when a method call is received from Flutter.
static void expidus_plugin_handle_method_call(
    ExpidusPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "getHeaderBarLayout") == 0) {
    FlView* view = fl_plugin_registrar_get_view(self->registrar);

    GtkSettings* settings = gtk_settings_get_for_screen(gtk_widget_get_screen(GTK_WIDGET(view)));

    gchar* decor_layout = nullptr;
    g_object_get(G_OBJECT(settings), "gtk-decoration-layout", &decor_layout, nullptr);

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(decor_layout)));
  } else if (strcmp(method, "setInputShapeRegions") == 0) {
    FlValue* regions = fl_method_call_get_args(method_call);

    size_t n_regions = fl_value_get_length(regions);

    cairo_rectangle_int_t* rects = (cairo_rectangle_int_t*)g_malloc0(sizeof (cairo_rectangle_int_t) * n_regions);
    for (size_t i = 0; i < n_regions; i++) {
      FlValue* region = fl_value_get_list_value(regions, i);

      rects[i] = {
        .x = (int)fl_value_get_int(fl_value_lookup_string(region, "x")),
        .y = (int)fl_value_get_int(fl_value_lookup_string(region, "y")),
        .width = (int)fl_value_get_int(fl_value_lookup_string(region, "width")),
        .height = (int)fl_value_get_int(fl_value_lookup_string(region, "height")),
      };
    }

    FlView* view = fl_plugin_registrar_get_view(self->registrar);
    GtkWindow* window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));

    gtk_widget_input_shape_combine_region(GTK_WIDGET(window), cairo_region_create_rectangles(rects, n_regions));

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
#ifdef GTK_LAYER_SHELL_FOUND
  } else if (strcmp(method, "setLayering") == 0) {
    FlView* view = fl_plugin_registrar_get_view(self->registrar);
    GtkWindow* window = GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));

    if (gtk_layer_is_supported()) {
      FlValue* args = fl_method_call_get_args(method_call);

      gint width = 0;
      gint height = 0;

      FlValue* arg_width = fl_value_lookup_string(args, "width");
      if (fl_value_get_type(arg_width) == FL_VALUE_TYPE_INT) {
        width = fl_value_get_int(arg_width);
      }

      FlValue* arg_height = fl_value_lookup_string(args, "height");
      if (fl_value_get_type(arg_height) == FL_VALUE_TYPE_INT) {
        height = fl_value_get_int(arg_height);
      }

      gint temp_width, temp_height;
      gtk_window_get_size(window, &temp_width, &temp_height);

      if (height == 0) temp_height = height;
      if (width == 0) temp_width = width;

      if (!self->has_layer) {
        gtk_widget_hide(GTK_WIDGET(window));

        gtk_layer_init_for_window(window);
        self->has_layer = true;
      }

      FlValue* arg_monitor = fl_value_lookup_string(args, "monitor");
      GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(window));
      GdkMonitor* found_monitor = nullptr;

      if (fl_value_get_type(arg_monitor) == FL_VALUE_TYPE_STRING) {
        const gchar* monitor_name = fl_value_get_string(arg_monitor);

        int n_monitors = gdk_display_get_n_monitors(display);
        for (int i = 0; i < n_monitors; i++) {
          GdkMonitor* monitor = gdk_display_get_monitor(display, i);

          GdkRectangle geom;
          gdk_monitor_get_geometry(monitor, &geom);

          for (GList* emon = self->monitors; emon != nullptr; emon = emon->next) {
            ExpidusMonitor* emon_value = EXPIDUS_MONITOR(emon->data);

            if (geom.x == (emon_value->x / emon_value->scale) && geom.y == (emon_value->y / emon_value->scale) && geom.width == (emon_value->width / emon_value->scale) && geom.height == (emon_value->height / emon_value->scale)) {
              if (g_strcmp0(emon_value->name, monitor_name) == 0) {
                found_monitor = monitor;
                break;
              }
            }
          }

          if (found_monitor != nullptr) {
            gtk_layer_set_monitor(window, monitor);
            break;
          }
        }
      } else {
        found_monitor = gdk_display_get_monitor_at_window(display, gtk_widget_get_window(GTK_WIDGET(window)));
      }

      if (found_monitor != nullptr) {
        GdkRectangle geom;
        gdk_monitor_get_geometry(found_monitor, &geom);

        if (fl_value_get_bool(fl_value_lookup_string(fl_value_lookup_string(args, "top"), "toEdge")) && fl_value_get_bool(fl_value_lookup_string(fl_value_lookup_string(args, "bottom"), "toEdge"))) {
          height = geom.height - (fl_value_get_int(fl_value_lookup_string(fl_value_lookup_string(args, "top"), "margin")) + fl_value_get_int(fl_value_lookup_string(fl_value_lookup_string(args, "bottom"), "margin")));
        } else if (height == 0) {
          height = geom.height;
        }

        if (fl_value_get_bool(fl_value_lookup_string(fl_value_lookup_string(args, "left"), "toEdge")) && fl_value_get_bool(fl_value_lookup_string(fl_value_lookup_string(args, "right"), "toEdge"))) {
          width = geom.width - (fl_value_get_int(fl_value_lookup_string(fl_value_lookup_string(args, "left"), "margin")) + fl_value_get_int(fl_value_lookup_string(fl_value_lookup_string(args, "right"), "margin")));
        } else if (width == 0) {
          width = geom.width;
        }
      }

      gboolean auto_exclusive_zone = fl_value_get_bool(fl_value_lookup_string(args, "autoExclusiveZone"));

      if (auto_exclusive_zone) {
        gtk_layer_auto_exclusive_zone_enable(window);
      } else {
        gint exclusive_zone = fl_value_get_int(fl_value_lookup_string(args, "exclusiveZone"));
        gtk_layer_set_exclusive_zone(window, exclusive_zone);
      }

      gboolean fixed_size = fl_value_get_bool(fl_value_lookup_string(args, "fixedSize"));

      if (!fixed_size) {
        width = -1;
        height = -1;
      }

      const gchar* layer_name = fl_value_get_string(fl_value_lookup_string(args, "layer"));

      if (g_strcmp0(layer_name, "background") == 0) {
        gtk_layer_set_layer(window, GTK_LAYER_SHELL_LAYER_BACKGROUND);
      } else if (g_strcmp0(layer_name, "bottom") == 0) {
        gtk_layer_set_layer(window, GTK_LAYER_SHELL_LAYER_BOTTOM);
      } else if (g_strcmp0(layer_name, "top") == 0) {
        gtk_layer_set_layer(window, GTK_LAYER_SHELL_LAYER_TOP);
      } else if (g_strcmp0(layer_name, "overlay") == 0) {
        gtk_layer_set_layer(window, GTK_LAYER_SHELL_LAYER_OVERLAY);
      }

      const gchar* keyboard_mode_name = fl_value_get_string(fl_value_lookup_string(args, "keyboardMode"));

      if (g_strcmp0(keyboard_mode_name, "none") == 0) {
        gtk_layer_set_keyboard_mode(window, GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
      } else if (g_strcmp0(keyboard_mode_name, "exclusive") == 0) {
        gtk_layer_set_keyboard_mode(window, GTK_LAYER_SHELL_KEYBOARD_MODE_EXCLUSIVE);
      } else if (g_strcmp0(keyboard_mode_name, "demand") == 0) {
        gtk_layer_set_keyboard_mode(window, GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);
      }

      set_layer_anchor(window, fl_value_lookup_string(args, "top"), GTK_LAYER_SHELL_EDGE_TOP);
      set_layer_anchor(window, fl_value_lookup_string(args, "bottom"), GTK_LAYER_SHELL_EDGE_BOTTOM);
      set_layer_anchor(window, fl_value_lookup_string(args, "left"), GTK_LAYER_SHELL_EDGE_LEFT);
      set_layer_anchor(window, fl_value_lookup_string(args, "right"), GTK_LAYER_SHELL_EDGE_RIGHT);

      gtk_widget_set_size_request(GTK_WIDGET(window), width, height);

      if (gtk_widget_is_visible(GTK_WIDGET(window))) {
        gtk_window_resize(window, width, height);
      } else {
        gtk_widget_show_all(GTK_WIDGET(window));
      }

      FlValue* value = fl_value_new_map();
      fl_value_set_string_take(value, "width", fl_value_new_int(width));
      fl_value_set_string_take(value, "height", fl_value_new_int(height));

      response = FL_METHOD_RESPONSE(fl_method_success_response_new(value));
    } else {
      response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
    }
} else {
#else
} else {
#endif
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void expidus_plugin_dispose(GObject* object) {
  ExpidusPlugin* self = EXPIDUS_PLUGIN(object);

  g_list_free_full(self->monitors, g_object_unref);

  G_OBJECT_CLASS(expidus_plugin_parent_class)->dispose(object);
}

static void expidus_plugin_class_init(ExpidusPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = expidus_plugin_dispose;
}

static void expidus_plugin_init(ExpidusPlugin* self) {
  self->has_layer = false;
  self->monitors = nullptr;
}

static void method_call_cb(FlMethodChannel* channel, FlMethodCall* method_call,
                           gpointer user_data) {
  ExpidusPlugin* plugin = EXPIDUS_PLUGIN(user_data);
  expidus_plugin_handle_method_call(plugin, method_call);
}

void expidus_plugin_register_with_registrar(FlPluginRegistrar* registrar) {
  ExpidusPlugin* plugin = EXPIDUS_PLUGIN(g_object_new(expidus_plugin_get_type(), nullptr));
  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "expidus",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  FlView* view = fl_plugin_registrar_get_view(plugin->registrar);

  GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(view));

  if (GDK_IS_WAYLAND_DISPLAY(display)) {
    expidus_plugin_wayland_init(plugin);
  }
  g_object_unref(plugin);
}

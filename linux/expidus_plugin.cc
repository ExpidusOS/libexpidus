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

static FlValue* get_style_color(GtkStyleContext* context, const gchar* color_name) {
  GdkRGBA color;
	gtk_style_context_lookup_color(context, color_name, &color);

  FlValue* map = fl_value_new_map();

	fl_value_set_string_take(map, "R", fl_value_new_int((int) (color.red * 255)));
	fl_value_set_string_take(map, "G", fl_value_new_int((int) (color.green * 255)));
	fl_value_set_string_take(map, "B", fl_value_new_int((int) (color.blue * 255)));
	fl_value_set_string_take(map, "A", fl_value_new_int((int) (color.alpha * 255)));

  return map;
}

static FlValue* get_color_theme(GtkStyleContext* context) {
  FlValue* colors = fl_value_new_map();

  fl_value_set_string_take(colors, "accent", get_style_color(context, "accent_bg_color"));
  fl_value_set_string_take(colors, "onAccent", get_style_color(context, "accent_fg_color"));

  fl_value_set_string_take(colors, "outline", get_style_color(context, "borders"));

  fl_value_set_string_take(colors, "primary", get_style_color(context, "theme_bg_color"));
  fl_value_set_string_take(colors, "onPrimary", get_style_color(context, "theme_fg_color"));

  fl_value_set_string_take(colors, "secondary", get_style_color(context, "warning_bg_color"));
  fl_value_set_string_take(colors, "onSecondary", get_style_color(context, "warning_fg_color"));

  fl_value_set_string_take(colors, "error", get_style_color(context, "error_bg_color"));
  fl_value_set_string_take(colors, "onError", get_style_color(context, "error_fg_color"));

  fl_value_set_string_take(colors, "surface", get_style_color(context, "window_bg_color"));
  fl_value_set_string_take(colors, "onSurface", get_style_color(context, "window_fg_color"));

  return colors;
}

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

  if (strcmp(method, "getSystemTheme") == 0) {
    FlValue* arg_is_dark = fl_method_call_get_args(method_call);
    bool is_dark = fl_value_get_bool(arg_is_dark);

    FlView* view = fl_plugin_registrar_get_view(self->registrar);

    GtkSettings* settings = gtk_settings_get_for_screen(gtk_widget_get_screen(GTK_WIDGET(view)));

    gchar* theme_name = nullptr;
    gchar* font_name = nullptr;
    g_object_get(G_OBJECT(settings), "gtk-theme-name", &theme_name, "gtk-font-name", &font_name, nullptr);

    GtkCssProvider* provider = gtk_css_provider_get_named(theme_name, is_dark ? "dark" : nullptr);

	  GtkStyleContext* context = gtk_style_context_new();
    gtk_style_context_add_provider(context, GTK_STYLE_PROVIDER(provider), GTK_STYLE_PROVIDER_PRIORITY_THEME);

    g_autoptr(FlValue) theme = fl_value_new_map();

    {
      FlValue* theme_text = fl_value_new_map();

      fl_value_set_string_take(theme_text, "font", fl_value_new_string(font_name));
      fl_value_set_string_take(theme_text, "color", get_style_color(context, "theme_text_color"));

      fl_value_set_string_take(theme, "text", theme_text);
    }

    {
      FlValue* theme_appbar = fl_value_new_map();

      fl_value_set_string_take(theme_appbar, "background", get_style_color(context, "headerbar_bg_color"));
      fl_value_set_string_take(theme_appbar, "foreground", get_style_color(context, "headerbar_fg_color"));
      fl_value_set_string_take(theme_appbar, "border", get_style_color(context, "headerbar_border_color"));
      fl_value_set_string_take(theme_appbar, "shadow", get_style_color(context, "headerbar_shade_color"));

      fl_value_set_string_take(theme, "appBar", theme_appbar);
    }

    fl_value_set_string_take(theme, "colorScheme", get_color_theme(context));

    g_object_unref(context);

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(theme));
  } else if (strcmp(method, "getHeaderBarLayout") == 0) {
    FlView* view = fl_plugin_registrar_get_view(self->registrar);

    GtkSettings* settings = gtk_settings_get_for_screen(gtk_widget_get_screen(GTK_WIDGET(view)));

    gchar* decor_layout = nullptr;
    g_object_get(G_OBJECT(settings), "gtk-decoration-layout", &decor_layout, nullptr);

    response = FL_METHOD_RESPONSE(fl_method_success_response_new(fl_value_new_string(decor_layout)));
#ifdef GTK_LAYER_SHELL_FOUND
  } else if (strcmp(method, "setLayering") == 0) {
    if (gtk_layer_is_supported()) {
      gboolean was_mapped = gtk_widget_get_mapped(GTK_WIDGET(self->window));
      gtk_widget_set_visible(GTK_WIDGET(self->window), false);

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

      if (was_mapped && width == 0 && height == 0) {
        gtk_window_get_size(self->window, &width, &height);
      }

      if (!self->has_layer) {
        gtk_layer_init_for_window(self->window);
        self->has_layer = true;
      }

      FlValue* arg_monitor = fl_value_lookup_string(args, "monitor");
      if (fl_value_get_type(arg_monitor) == FL_VALUE_TYPE_STRING) {
        const gchar* monitor_name = fl_value_get_string(arg_monitor);

        GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(self->window));
        GdkMonitor* found_monitor = nullptr;

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
            gtk_layer_set_monitor(self->window, monitor);
            break;
          }
        }
      }

      const gchar* layer_name = fl_value_get_string(fl_value_lookup_string(args, "layer"));

      if (g_strcmp0(layer_name, "background") == 0) {
        gtk_layer_set_layer(self->window, GTK_LAYER_SHELL_LAYER_BACKGROUND);
      } else if (g_strcmp0(layer_name, "bottom") == 0) {
        gtk_layer_set_layer(self->window, GTK_LAYER_SHELL_LAYER_BOTTOM);
      } else if (g_strcmp0(layer_name, "top") == 0) {
        gtk_layer_set_layer(self->window, GTK_LAYER_SHELL_LAYER_TOP);
      } else if (g_strcmp0(layer_name, "overlay") == 0) {
        gtk_layer_set_layer(self->window, GTK_LAYER_SHELL_LAYER_OVERLAY);
      }

      const gchar* keyboard_mode_name = fl_value_get_string(fl_value_lookup_string(args, "keyboardMode"));

      if (g_strcmp0(keyboard_mode_name, "none") == 0) {
        gtk_layer_set_keyboard_mode(self->window, GTK_LAYER_SHELL_KEYBOARD_MODE_NONE);
      } else if (g_strcmp0(keyboard_mode_name, "exclusive") == 0) {
        gtk_layer_set_keyboard_mode(self->window, GTK_LAYER_SHELL_KEYBOARD_MODE_EXCLUSIVE);
      } else if (g_strcmp0(keyboard_mode_name, "demand") == 0) {
        gtk_layer_set_keyboard_mode(self->window, GTK_LAYER_SHELL_KEYBOARD_MODE_ON_DEMAND);
      }

      set_layer_anchor(self->window, fl_value_lookup_string(args, "top"), GTK_LAYER_SHELL_EDGE_TOP);
      set_layer_anchor(self->window, fl_value_lookup_string(args, "bottom"), GTK_LAYER_SHELL_EDGE_BOTTOM);
      set_layer_anchor(self->window, fl_value_lookup_string(args, "left"), GTK_LAYER_SHELL_EDGE_LEFT);
      set_layer_anchor(self->window, fl_value_lookup_string(args, "right"), GTK_LAYER_SHELL_EDGE_RIGHT);

      gtk_widget_set_visible(GTK_WIDGET(self->window), was_mapped);
      if (was_mapped) {
        gtk_widget_set_size_request(GTK_WIDGET(self->window), width, height);
        gtk_window_resize(self->window, 1, 1);
      }

      response = FL_METHOD_RESPONSE(fl_method_success_response_new(nullptr));
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

  g_object_unref(self->window);
  g_list_free_full(self->monitors, g_object_unref);

  G_OBJECT_CLASS(expidus_plugin_parent_class)->dispose(object);
}

static void expidus_plugin_class_init(ExpidusPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = expidus_plugin_dispose;
}

static void expidus_plugin_init(ExpidusPlugin* self) {
  self->window = nullptr;
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
  g_object_set_data(G_OBJECT(view), "ExpidusPlugin", g_object_ref(plugin));

  GdkDisplay* display = gtk_widget_get_display(GTK_WIDGET(view));

  if (GDK_IS_WAYLAND_DISPLAY(display)) {
    expidus_plugin_wayland_init(plugin);
  }
  g_object_unref(plugin);
}

void expidus_plugin_set_window(ExpidusPlugin* self, GtkWindow* window) {
  g_assert(self->window == nullptr);
  self->window = GTK_WINDOW(g_object_ref(G_OBJECT(window)));
}

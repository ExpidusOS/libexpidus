#include "include/expidus/expidus_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#include "expidus_plugin_private.h"

#define EXPIDUS_PLUGIN(obj) \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), expidus_plugin_get_type(), \
                              ExpidusPlugin))

struct _ExpidusPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
};

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
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void expidus_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(expidus_plugin_parent_class)->dispose(object);
}

static void expidus_plugin_class_init(ExpidusPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = expidus_plugin_dispose;
}

static void expidus_plugin_init(ExpidusPlugin* self) {}

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

  g_object_unref(plugin);
}

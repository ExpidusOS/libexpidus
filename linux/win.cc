#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <expidus/win.h>
#include <flutter_linux/flutter_linux.h>

struct _ExpidusWindow {
  GtkApplicationWindow parent_instance;
  gboolean supports_alpha;
  FlView* view;
};

G_DEFINE_TYPE(ExpidusWindow, expidus_window, GTK_TYPE_APPLICATION_WINDOW)

enum {
  PROP_0,
  PROP_VIEW,
  N_PROPS,
};

static GParamSpec* obj_props[N_PROPS] = { nullptr };

static gboolean expidus_window_draw(GtkWidget* widget, cairo_t* cr, gpointer userdata) {
  ExpidusWindow* self = EXPIDUS_WINDOW(userdata);

  cairo_save(cr);

  if (self->supports_alpha) cairo_set_source_rgba(cr, 0.0, 0.0, 0.0, 0.0);
  else cairo_set_source_rgb(cr, 1.0, 1.0, 1.0);

  cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
  cairo_paint(cr);

  cairo_restore(cr);
  return false;
}

static void expidus_window_set_property(GObject* object, guint prop_id, const GValue* value, GParamSpec* pspec) {
  ExpidusWindow* self = EXPIDUS_WINDOW(object);

  switch (prop_id) {
    case PROP_VIEW:
      self->view = FL_VIEW(g_value_dup_object(value));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(object, prop_id, pspec);
      break;
  }
}

static void expidus_window_get_property(GObject* object, guint prop_id, GValue* value, GParamSpec* pspec) {
  ExpidusWindow* self = EXPIDUS_WINDOW(object);

  switch (prop_id) {
    case PROP_VIEW:
      g_value_set_object(value, G_OBJECT(self->view));
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID(object, prop_id, pspec);
      break;
  }
}

static void expidus_window_constructed(GObject* object) {
  G_OBJECT_CLASS(expidus_window_parent_class)->constructed(object);

  ExpidusWindow* self = EXPIDUS_WINDOW(object);

  auto bdw = bitsdojo_window_from(GTK_WINDOW(self));
  bdw->setCustomFrame(true);

  gtk_widget_show(GTK_WIDGET(self->view));
  gtk_container_add(GTK_CONTAINER(self), GTK_WIDGET(self->view));

  gtk_widget_set_app_paintable(GTK_WIDGET(self), true);
  g_signal_connect(G_OBJECT(self), "draw", G_CALLBACK(expidus_window_draw), self);

  GdkRGBA background_color;
  gdk_rgba_parse(&background_color, "#00000000");
  fl_view_set_background_color(self->view, &background_color);

  GdkScreen* screen = gdk_screen_get_default();
  GdkVisual* visual = gdk_screen_get_rgba_visual(screen);

  if (visual != nullptr && gdk_screen_is_composited(screen)) {
    gtk_widget_set_visual(GTK_WIDGET(self), visual);
    self->supports_alpha = true;
  } else {
    self->supports_alpha = false;
  }

  gtk_widget_map(GTK_WIDGET(self->view));
  gtk_widget_grab_focus(GTK_WIDGET(self->view));
}

static void expidus_window_dispose(GObject* object) {
  ExpidusWindow* self = EXPIDUS_WINDOW(object);

  g_clear_object(&self->view);

  G_OBJECT_CLASS(expidus_window_parent_class)->dispose(object);
}

static void expidus_window_class_init(ExpidusWindowClass* klass) {
  GObjectClass* object_class = G_OBJECT_CLASS(klass);

  object_class->set_property = expidus_window_set_property;
  object_class->get_property = expidus_window_get_property;
  object_class->constructed = expidus_window_constructed;
  object_class->dispose = expidus_window_dispose;

  obj_props[PROP_VIEW] = g_param_spec_object(
    "view",
    "View",
    "The Flutter view which this window uses.",
    fl_view_get_type(),
    (GParamFlags)(G_PARAM_CONSTRUCT_ONLY | G_PARAM_READWRITE)
  );

  g_object_class_install_properties(object_class, N_PROPS, obj_props);
}

static void expidus_window_init(ExpidusWindow* self) {}

GtkWindow* expidus_window_new(GtkApplication* app, FlView* view) {
  return GTK_WINDOW(g_object_new(expidus_window_get_type(), "application", app, "view", view, nullptr));
}

#pragma once

#include <gtk/gtk.h>
#include <flutter_linux/flutter_linux.h>

G_DECLARE_FINAL_TYPE(ExpidusWindow, expidus_window, EXPIDUS, WINDOW, GtkApplicationWindow);

GtkWindow* expidus_window_new(GtkApplication* app, FlView* view);

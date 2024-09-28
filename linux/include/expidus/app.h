#pragma once

#include <gtk/gtk.h>

G_DECLARE_FINAL_TYPE(ExpidusApplication, expidus_application, EXPIDUS, APPLICATION, GtkApplication)

/**
 * expidus_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #ExpidusApplication.
 */
ExpidusApplication* expidus_application_new(const gchar* app_id);

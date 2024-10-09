#pragma once

#include <flutter_linux/flutter_linux.h>

G_DECLARE_FINAL_TYPE(ExpidusApplication, expidus_application, EXPIDUS, APPLICATION, FlApplication)

/**
 * expidus_application_new:
 *
 * Creates a new Flutter-based application.
 *
 * Returns: a new #ExpidusApplication.
 */
ExpidusApplication* expidus_application_new(const gchar* app_id);

#include "include/expidus/expidus_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "expidus_plugin.h"

void ExpidusPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  expidus::ExpidusPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}

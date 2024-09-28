#ifndef FLUTTER_PLUGIN_EXPIDUS_PLUGIN_H_
#define FLUTTER_PLUGIN_EXPIDUS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace expidus {

class ExpidusPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  ExpidusPlugin();

  virtual ~ExpidusPlugin();

  // Disallow copy and assign.
  ExpidusPlugin(const ExpidusPlugin&) = delete;
  ExpidusPlugin& operator=(const ExpidusPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace expidus

#endif  // FLUTTER_PLUGIN_EXPIDUS_PLUGIN_H_

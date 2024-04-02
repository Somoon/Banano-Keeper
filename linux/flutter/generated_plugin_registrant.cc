//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <biometric_storage/biometric_storage_plugin.h>
#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>
#include <smart_auth/smart_auth_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) biometric_storage_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BiometricStoragePlugin");
  biometric_storage_plugin_register_with_registrar(biometric_storage_registrar);
  g_autoptr(FlPluginRegistrar) bitsdojo_window_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "BitsdojoWindowPlugin");
  bitsdojo_window_plugin_register_with_registrar(bitsdojo_window_linux_registrar);
  g_autoptr(FlPluginRegistrar) smart_auth_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "SmartAuthPlugin");
  smart_auth_plugin_register_with_registrar(smart_auth_registrar);
}

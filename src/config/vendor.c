#include <expidus/vendor-config.h>
#include <assert.h>
#include <libexpidus-build.h>

ExpidusConfigParser* expidus_vendor_config_parser_new() {
  ExpidusConfigParser* self = expidus_config_parser_new();
  assert(self != NULL);

  expidus_config_parser_set_properties(self, (ExpidusConfigProperty[]){
    { NT_TYPE_ARGUMENT_KEY(Services, enabled), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, NULL) },
    { NT_TYPE_ARGUMENT_KEY(Services, disabled), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, NULL) },
  
    { NT_TYPE_ARGUMENT_KEY(System, nix_daemon), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(System, nix_store), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(System, tty_switch), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(System, bootsplash), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, true) },

    { NT_TYPE_ARGUMENT_KEY(Graphics, backend), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, "auto") },
    { NT_TYPE_ARGUMENT_KEY(Graphics, driver), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, "auto") },
    { NT_TYPE_ARGUMENT_KEY(Graphics, reboot_after_upgrade), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, true) },

    { NT_TYPE_ARGUMENT_KEY(VendorConfig, datafs), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(VendorConfig, gui), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(VendorConfig, gui_blacklist), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, NULL) },
  
    { NT_TYPE_ARGUMENT_KEY(Launcher, id), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, "com.expidus.GenesisShell") },
    { NT_TYPE_ARGUMENT_KEY(Devident, id), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, NULL) },
  
    { NT_TYPE_ARGUMENT_KEY(Security, tamper_check), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, "local") },
    { NT_TYPE_ARGUMENT_KEY(Security, require_tpm), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(Security, require_secureboot), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NT_TYPE_ARGUMENT_KEY(Security, enforcer), NT_VALUE_TYPE_STRING, NT_VALUE_DATA_INIT(string, "selinux") },
  
    { NT_TYPE_ARGUMENT_KEY(PrivilegedApplications, check_signs), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, true) },
    { NT_TYPE_ARGUMENT_KEY(PrivilegedApplications, allow_datafs), NT_VALUE_TYPE_BOOL, NT_VALUE_DATA_INIT(boolean, false) },
    { NULL }
  });
  return self;
}

const char* expidus_vendor_config_get_path(ExpidusVendorConfigType type) {
  assert(type >= EXPIDUS_VENDOR_CONFIG_SYSTEM && type <= EXPIDUS_VENDOR_CONFIG_DATA_BACKUP);

  switch (type) {
    case EXPIDUS_VENDOR_CONFIG_SYSTEM:
      return SYSCONFDIR "/expidus/vendor.conf";
    case EXPIDUS_VENDOR_CONFIG_DATA:
      return LOCALSTATEDIR "/expidus/data/vendor.conf";
    case EXPIDUS_VENDOR_CONFIG_DATA_BACKUP:
      return LOCALSTATEDIR "/expidus/data/vendor.orig.conf";
  }
  return NULL;
}

NtTypeArgument* expidus_vendor_config_load(NtBacktrace* backtrace, NtError** error) {
  assert(backtrace != NULL && NT_IS_BACKTRACE(backtrace));
  assert(error != NULL && *error == NULL);

  nt_backtrace_push(backtrace, expidus_vendor_config_load);

  ExpidusConfigParser* parser = expidus_config_parser_new();
  assert(parser != NULL);

  const char* loc = expidus_vendor_config_get_path(EXPIDUS_VENDOR_CONFIG_SYSTEM);

  NtTypeArgument* vendor_config = expidus_config_parser_read_file(parser, loc, backtrace, error);
  if (vendor_config == NULL) {
    nt_type_instance_unref((NtTypeInstance*)parser);
    nt_backtrace_pop(backtrace);
    return NULL;
  }

  NtValue value = expidus_config_parser_get(parser, vendor_config, NT_TYPE_ARGUMENT_KEY(VendorConfig, datafs), backtrace, error);
  if (*error != NULL) {
    for (size_t i = 0; vendor_config[i].name != NULL; i++) {
      free((char*)vendor_config[i].name);
      if (vendor_config[i].value.type == NT_VALUE_TYPE_STRING) free(vendor_config[i].value.data.string);
    }

    free(vendor_config);

    nt_type_instance_unref((NtTypeInstance*)parser);
    nt_backtrace_pop(backtrace);
    return NULL;
  }

  assert(value.type == NT_VALUE_TYPE_BOOL);
  if (value.data.boolean) {
    const char* loc = expidus_vendor_config_get_path(EXPIDUS_VENDOR_CONFIG_DATA);
    NtTypeArgument* datafs_vendor_config = expidus_config_parser_read_file(parser, loc, backtrace, error);
    if (datafs_vendor_config == NULL) {
      for (size_t i = 0; vendor_config[i].name != NULL; i++) {
        free((char*)vendor_config[i].name);
        if (vendor_config[i].value.type == NT_VALUE_TYPE_STRING) free(vendor_config[i].value.data.string);
      }

      free(vendor_config);

      nt_type_instance_unref((NtTypeInstance*)parser);
      nt_backtrace_pop(backtrace);
      return NULL;
    }

    size_t count = 1;
    for (size_t i = 0; vendor_config[i].name != NULL; i++) count++;
    for (size_t i = 0; datafs_vendor_config[i].name != NULL; i++) count++;

    NtTypeArgument* arguments = malloc(sizeof (NtTypeArgument) * count);
    assert(arguments != NULL);

    count = 0;
    for (size_t i = 0; vendor_config[i].name != NULL; i++) {
      arguments[count].name = vendor_config[i].name;
      arguments[count++].value = vendor_config[i].value;
    }

    for (size_t i = 0; datafs_vendor_config[i].name != NULL; i++) {
      arguments[count].name = datafs_vendor_config[i].name;
      arguments[count++].value = datafs_vendor_config[i].value;
    }

    arguments[count].name = NULL;

    free(datafs_vendor_config);
    free(vendor_config);

    nt_type_instance_unref((NtTypeInstance*)parser);
    nt_backtrace_pop(backtrace);
    return arguments;
  }

  nt_type_instance_unref((NtTypeInstance*)parser);
  nt_backtrace_pop(backtrace);
  return vendor_config;
}

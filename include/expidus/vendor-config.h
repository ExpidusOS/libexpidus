#pragma once

#include <expidus/config-parser.h>

NT_BEGIN_DECLS

/**
 * SECTION: vendor-config
 * @title: Vendor Config
 * @short_description: Handling of vendor config files
 */

#if defined(__GNUC__)
#pragma GCC visibility push(default)
#elif defined(__clang__)
#pragma clang visibility push(default)
#endif

/**
 * ExpidusVendorConfigType:
 * @EXPIDUS_VENDOR_CONFIG_SYSTEM: The system-wide vendor config file.
 * @EXPIDUS_VENDOR_CONFIG_DATA: The data filesystem vendor config file.
 * @EXPIDUS_VENDOR_CONFIG_DATA_BACKUP: Backup of the data filesystem's vendor config file.
 *
 * Enum of the different types of vendor config files.
 */
typedef enum _ExpidusVendorConfigType {
  EXPIDUS_VENDOR_CONFIG_SYSTEM = 0,
  EXPIDUS_VENDOR_CONFIG_DATA,
  EXPIDUS_VENDOR_CONFIG_DATA_BACKUP
} ExpidusVendorConfigType;

/**
 * expidus_vendor_config_parser_new:
 *
 * Creates a new config parser for handling the vendor config.
 *
 * Returns: A config parser set up for reading vendor config.
 */
ExpidusConfigParser* expidus_vendor_config_parser_new();

/**
 * expidus_vendor_config_get_path:
 * @type: The type of path to get
 *
 * Gets the path of one of the vendor config files.
 *
 * Returns: A static string for the path.
 */
const char* expidus_vendor_config_get_path(ExpidusVendorConfigType type);

/**
 * expidus_vendor_config_load:
 * @backtrace: The backtrace to append to in case of an error
 * @error: Pointer to store the error in
 *
 * Does everything needed to load all of the properties from the different vendor config files.
 *
 * Returns: A list of %NtTypeArgument's which are keyed based on %ExpidusVendorConfigProperty. %NULL is returned if failure.
 */
NtTypeArgument* expidus_vendor_config_load(NtBacktrace* backtrace, NtError** error);

#if defined(__GNUC__)
#pragma GCC visibility pop
#elif defined(__clang__)
#pragma clang visibility pop
#endif

NT_END_DECLS

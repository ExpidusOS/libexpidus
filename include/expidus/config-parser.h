#pragma once

#include <neutron/elemental.h>

NT_BEGIN_DECLS

/**
 * SECTION: config-parser
 * @title: Config Parser
 * @short_description: Parsing of ExpidusOS configuration files
 */

#if defined(__GNUC__)
#pragma GCC visibility push(default)
#elif defined(__clang__)
#pragma clang visibility push(default)
#endif

/**
 * ExpidusConfigParser:
 * @instance: The %NtTypeInstance associated
 * @priv: Private data
 *
 * Type for parsing ExpidusOS configuration files
 */
typedef struct _ExpidusConfigParser {
  NtTypeInstance instance;

  /*< private >*/
  struct _ExpidusConfigParserPrivate* priv;
} ExpidusConfigParser;

/**
 * ExpidusConfigProperty:
 * @name: Name of the property
 * @type: The type of property this should be
 * @default_value: The default value data to use
 *
 * Structure for defining properties for %ExpidusConfigParser
 */
typedef struct _ExpidusConfigProperty {
  const char* name;
  NtValueType type;
  NtValueData default_value;
} ExpidusConfigProperty;

/**
 * EXPIDUS_TYPE_CONFIG_PARSER:
 *
 * The %NtType ID of %ExpidusConfigParser
 */
#define EXPIDUS_TYPE_CONFIG_PARSER expidus_config_parser_get_type()
NT_DECLARE_TYPE(EXPIDUS, CONFIG_PARSER, ExpidusConfigParser, expidus_config_parser);

/**
 * expidus_config_parser_new:
 *
 * Creates a new empty configuration parser
 *
 * Returns: A new instance
 */
ExpidusConfigParser* expidus_config_parser_new();

/**
 * expidus_config_parser_remove_property:
 * @self: Instance
 * @name: Name of the property
 *
 * Removes the property by its name
 */
void expidus_config_parser_remove_property(ExpidusConfigParser* self, const char* name);

/**
 * expidus_config_parser_add_property:
 * @self: Instance
 * @name: Name of the property
 * @type: The type of property this should be
 * @default_value: The default value data to use
 *
 * Adds the new property
 */
void expidus_config_parser_add_property(ExpidusConfigParser* self, const char* name, NtValueType type, NtValueData default_value);

/**
 * expidus_config_parser_set_properties:
 * @self: Instance
 * @props: An array of properties with the last one having name set to %NULL
 *
 * Fills the configuration parser with all the properties at one go.
 */
void expidus_config_parser_set_properties(ExpidusConfigParser* self, ExpidusConfigProperty* props);

/**
 * expidus_config_parser_read_line:
 * @self: Instance
 * @str: The string to read as a single line
 * @length: The length of @str
 * @backtrace: The backtrace to append to in case of an error
 * @error: Pointer to store the error in
 *
 * Parses the string as a single line with a determined length.
 * If it failed to parse the line, then an error is pushed through @error.
 * If the property doesn't exist then name in %NtTypeArgument will be %NULL.
 *
 * Returns: The property name and value represented as a type argument. If it doesn't exist, then name will be %NULL.
 */
NtTypeArgument expidus_config_parser_read_line(ExpidusConfigParser* self, const char* str, size_t length, NtBacktrace* backtrace, NtError** error);

/**
 * expidus_config_parser_read:
 * @self: Instance
 * @str: The configuration to parse
 * @backtrace: The backtrace to append to in case of an error
 * @error: Pointer to store the error in
 *
 * Parse the configuration line by line
 *
 * Returns: A list of %NtTypeArgument's which are keyed based on %ExpidusVendorConfigProperty. %NULL is returned if failure.
 */
NtTypeArgument* expidus_config_parser_read(ExpidusConfigParser* self, const char* str, NtBacktrace* backtrace, NtError** error);

/**
 * expidus_config_parser_read_file:
 * @self: Instance
 * @path: The path to the file
 * @backtrace: The backtrace to append to in case of an error
 * @error: Pointer to store the error in
 *
 * Parses the configuration from a file
 *
 * Returns: A list of %NtTypeArgument's which are keyed based on %ExpidusVendorConfigProperty. %NULL is returned if failure.
 */
NtTypeArgument* expidus_config_parser_read_file(ExpidusConfigParser* self, const char* path, NtBacktrace* backtrace, NtError** error);

#if defined(__GNUC__)
#pragma GCC visibility pop
#elif defined(__clang__)
#pragma clang visibility pop
#endif

NT_END_DECLS

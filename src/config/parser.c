#include <expidus/config-parser.h>
#include "parser-priv.h"
#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

NT_DEFINE_TYPE(EXPIDUS, CONFIG_PARSER, ExpidusConfigParser, expidus_config_parser, NT_TYPE_FLAG_STATIC, NT_TYPE_NONE);

static void expidus_config_parser_construct(NtTypeInstance* instance, NtTypeArgument* arguments) {
  ExpidusConfigParser* self = EXPIDUS_CONFIG_PARSER(instance);
  assert(self != NULL);

  self->priv = malloc(sizeof (ExpidusConfigParserPrivate));
  assert(self->priv != NULL);
  memset(self->priv, 0, sizeof (ExpidusConfigParserPrivate));
}

static void expidus_config_parser_destroy(NtTypeInstance* instance) {
  ExpidusConfigParser* self = EXPIDUS_CONFIG_PARSER(instance);
  assert(self != NULL);

  NtList* head = self->priv->list;
  while (head != NULL) {
    assert(head->value.type == NT_VALUE_TYPE_POINTER);
    free(head->value.data.pointer);

    NtList* next = head->next;
    nt_type_instance_unref((NtTypeInstance*)head);
    head = next;
  }
}

ExpidusConfigParser* expidus_config_parser_new() {
  return EXPIDUS_CONFIG_PARSER(nt_type_instance_new(EXPIDUS_TYPE_CONFIG_PARSER, NULL));
}

void expidus_config_parser_remove_property(ExpidusConfigParser* self, const char* name) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(name != NULL);

  NtList* head = self->priv->list;
  while (head != NULL) {
    assert(head->value.type == NT_VALUE_TYPE_POINTER);

    ExpidusConfigProperty* prop = head->value.data.pointer;
    assert(prop != NULL);

    if (strcmp(prop->name, name) == 0) {
      free((char*)prop->name);
      free(prop);

      if (self->priv->list == head) self->priv->list = head->next;
      nt_type_instance_unref((NtTypeInstance*)head);
      break;
    }

    head = head->next;
  }
}

void expidus_config_parser_add_property(ExpidusConfigParser* self, const char* name, NtValueType type, NtValueData default_value) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(name != NULL);

  ExpidusConfigProperty* prop = malloc(sizeof (ExpidusConfigProperty));
  assert(prop != NULL);
  memset(prop, 0, sizeof (ExpidusConfigProperty));

  prop->name = strdup(name);
  assert(prop->name != NULL);

  prop->type = type;
  prop->default_value = default_value;

  self->priv->list = nt_list_append(self->priv->list, NT_VALUE_POINTER(prop));
}

void expidus_config_parser_set_properties(ExpidusConfigParser* self, ExpidusConfigProperty* props) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));

  NtList* head = self->priv->list;
  while (head != NULL) {
    assert(head->value.type == NT_VALUE_TYPE_POINTER);
    free(head->value.data.pointer);

    NtList* next = head->next;
    nt_type_instance_unref((NtTypeInstance*)head);
    head = next;
  }

  self->priv->list = NULL;

  if (props != NULL) {
    size_t i = 0;
    while (props[i].name != NULL) {
      ExpidusConfigProperty* prop = &props[i++];
      expidus_config_parser_add_property(self, prop->name, prop->type, prop->default_value);
    }
  }
}

NtValue expidus_config_parser_get(ExpidusConfigParser* self, NtTypeArgument* arguments, const char* name, NtBacktrace* backtrace, NtError** error) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(backtrace != NULL);
  assert(error != NULL && *error == NULL);

  nt_backtrace_push(backtrace, expidus_config_parser_get);

  NtValue default_value = expidus_config_parser_get_default(self, name, backtrace, error);
  if (*error != NULL) {
    nt_backtrace_pop(backtrace);
    return NT_VALUE_POINTER(NULL);
  }

  NtValue value = nt_type_argument_get(arguments, name, default_value);
  nt_backtrace_pop(backtrace);
  return value;
}

NtValue expidus_config_parser_get_default(ExpidusConfigParser* self, const char* name, NtBacktrace* backtrace, NtError** error) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(backtrace != NULL);
  assert(error != NULL && *error == NULL);

  nt_backtrace_push(backtrace, expidus_config_parser_get_default);

  for (NtList* head = self->priv->list; head != NULL; head = head->next) {
    assert(head->value.type == NT_VALUE_TYPE_POINTER);

    ExpidusConfigProperty* prop = head->value.data.pointer;
    assert(prop != NULL);

    if (strcmp(prop->name, name) == 0) {
      nt_backtrace_pop(backtrace);

      NtValue value = {};
      value.type = prop->type;
      value.data = prop->default_value;
      return value;
    }
  }

  NtString* str = nt_string_new(NULL);
  assert(str != NULL);
  nt_string_dynamic_printf(str, "Property \"%s\" does not exist", name);
  const char* msg = nt_string_get_value(str, NULL);
  nt_type_instance_unref((NtTypeInstance*)str);

  *error = nt_error_new(msg, backtrace);
  free((char*)msg);
  nt_backtrace_pop(backtrace);
  return NT_VALUE_POINTER(NULL);
}

NtTypeArgument expidus_config_parser_read_line(ExpidusConfigParser* self, const char* str, size_t length, NtBacktrace* backtrace, NtError** error) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(str != NULL && length > -1);
  assert(backtrace != NULL);
  assert(error != NULL && *error == NULL);

  nt_backtrace_push(backtrace, expidus_config_parser_read_line);

  for (NtList* head = self->priv->list; head != NULL; head = head->next) {
    assert(head->value.type == NT_VALUE_TYPE_POINTER);

    ExpidusConfigProperty* prop = head->value.data.pointer;
    assert(prop != NULL);

    size_t idx_of_split = strlen(prop->name) + 1;
    if (length < idx_of_split) continue;

    if (str[idx_of_split] != '=') continue;
    if (strncmp(str, prop->name, idx_of_split - 1) != 0) continue;

    size_t value_start = idx_of_split + 1;
    char* value = strndup(str + value_start, value_start - length);
    if (value == NULL) continue;

    NtTypeArgument arg = {};
    arg.name = strdup(prop->name);

    char* tmp = NULL;
    switch (prop->type) {
      case NT_VALUE_TYPE_POINTER:
        arg.value = NT_VALUE_POINTER(NULL);
        free(value);
        break;
      case NT_VALUE_TYPE_STRING:
        arg.value = NT_VALUE_STRING(value);
        break;
      case NT_VALUE_TYPE_NUMBER:
        arg.value = NT_VALUE_NUMBER(strtoul(value, &tmp, 10));
        free(value);
        break;
      case NT_VALUE_TYPE_BOOL:
        if (strcmp(value, "true") == 0) arg.value = NT_VALUE_BOOL(true);
        else if (strcmp(value, "false") == 0) arg.value = NT_VALUE_BOOL(false);
        else {
          NtString* str = nt_string_new(NULL);
          assert(str != NULL);
          nt_string_dynamic_printf(str, "Invalid boolean value \"%s\" for property \"%s\"", value, prop->name);
          const char* msg = nt_string_get_value(str, NULL);
          nt_type_instance_unref((NtTypeInstance*)str);

          *error = nt_error_new(msg, backtrace);
          free((char*)msg);
          nt_backtrace_pop(backtrace);
          free(value);
          return (NtTypeArgument){ NULL };
        }
        break;
      case NT_VALUE_TYPE_INSTANCE:
        arg.value = NT_VALUE_INSTANCE(NULL);
        break;
    }
    return arg;
  }

  nt_backtrace_pop(backtrace);
  return (NtTypeArgument){ NULL, NT_VALUE_POINTER(NULL) };
}

NtTypeArgument* expidus_config_parser_read(ExpidusConfigParser* self, const char* str, NtBacktrace* backtrace, NtError** error) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(str != NULL);
  assert(backtrace != NULL);
  assert(error != NULL && *error == NULL);

  char* curr = (char*)str;
  size_t count = 1;

  nt_backtrace_push(backtrace, expidus_config_parser_read);

  while (curr != NULL) {
    char* next = strchr(curr, '\n');
    int curr_len = next ? (next - curr) : strlen(curr);

    char* tmp = malloc(curr_len + 1);
    assert(tmp != NULL);

    memcpy(tmp, curr, curr_len);
    tmp[curr_len] = '\0';

    NtTypeArgument arg = expidus_config_parser_read_line(self, tmp, curr_len, backtrace, error);
    if (arg.name == NULL) {
      if (*error == NULL) {
        NtString* str = nt_string_new(NULL);
        assert(str != NULL);
        nt_string_dynamic_printf(str, "Invalid configuration on line %zu", count);
        const char* msg = nt_string_get_value(str, NULL);
        nt_type_instance_unref((NtTypeInstance*)str);

        *error = nt_error_new(msg, backtrace);
        free((char*)msg);
      }

      nt_backtrace_pop(backtrace);
      free(tmp);
      return NULL;
    }

    if (arg.value.type == NT_VALUE_TYPE_STRING) free(arg.value.data.string);
    count++;

    free(tmp);
    curr = next ? (next + 1) : NULL;
  }

  NtTypeArgument* arguments = malloc(sizeof (NtTypeArgument) * count);
  assert(arguments != NULL);
  memset(arguments, 0, sizeof (NtTypeArgument) * count);

  curr = (char*)str;
  count = 0;

  while (curr != NULL) {
    char* next = strchr(curr, '\n');
    int curr_len = next ? (next - curr) : strlen(curr);

    char* tmp = malloc(curr_len + 1);
    assert(tmp != NULL);

    memcpy(tmp, curr, curr_len);
    tmp[curr_len] = '\0';

    NtTypeArgument arg = expidus_config_parser_read_line(self, tmp, curr_len, backtrace, error);
    if (arg.name == NULL) {
      if (*error == NULL) {
        NtString* str = nt_string_new(NULL);
        assert(str != NULL);
        nt_string_dynamic_printf(str, "Invalid configuration on line %zu", count);
        const char* msg = nt_string_get_value(str, NULL);
        nt_type_instance_unref((NtTypeInstance*)str);

        *error = nt_error_new(msg, backtrace);
        free((char*)msg);
      }

      nt_backtrace_pop(backtrace);
      free(tmp);
      return NULL;
    }

    arguments[count].name = arg.name;
    arguments[count].value = arg.value;
    count++;

    free(tmp);
    curr = next ? (next + 1) : NULL;
  }

  arguments[count].name = NULL;
  nt_backtrace_pop(backtrace);
  return arguments;
}

NtTypeArgument* expidus_config_parser_read_file(ExpidusConfigParser* self, const char* path, NtBacktrace* backtrace, NtError** error) {
  assert(EXPIDUS_IS_CONFIG_PARSER(self));
  assert(path != NULL);
  assert(backtrace != NULL);
  assert(error != NULL && *error == NULL);

  nt_backtrace_push(backtrace, expidus_config_parser_read_file);

  FILE* fp = fopen(path, "rb");
  if (fp == NULL) {
    NtString* str = nt_string_new(NULL);
    assert(str != NULL);

    int e = errno;
    nt_string_dynamic_printf(str, "Failed to open \"%s\" for reading: (%d) %s", path, e, strerror(e));
    const char* msg = nt_string_get_value(str, NULL);
    nt_type_instance_unref((NtTypeInstance*)str);

    *error = nt_error_new(msg, backtrace);
    free((char*)msg);
    nt_backtrace_pop(backtrace);
    return NULL;
  }

  fseek(fp, 0, SEEK_END);
  size_t length = ftell(fp);
  fseek(fp, 0, SEEK_SET);

  char* buff = malloc(length);
  assert(buff != NULL);

  assert(fread(buff, 1, length, fp) == length);
  fclose(fp);

  NtTypeArgument* arguments = expidus_config_parser_read(self, buff, backtrace, error);
  free(buff);
  nt_backtrace_pop(backtrace);
  return arguments;
}

/* quickfix-filter  < qf.json  > qf2.json
   ENV vars:  SEVERITY=E|W|I   BUFFER=path */
#include <jansson.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
  json_error_t err;
  json_t *root = json_loadf(stdin, 0, &err);
  if (!root)
    return 1;
  const char *want_sev = getenv("SEVERITY");
  const char *want_buf = getenv("BUFFER");

  json_t *out = json_array();
  size_t idx;
  json_t *item;
  json_array_foreach(root, idx, item) {
    const char *type = json_string_value(json_object_get(item, "type"));
    const char *fname = json_string_value(json_object_get(item, "filename"));
    if (want_sev && type && *want_sev != *type)
      continue;
    if (want_buf && fname && strcmp(want_buf, fname) != 0)
      continue;
    json_array_append(out, item);
  }
  json_dumpf(out, stdout, JSON_COMPACT);
  json_decref(root);
  json_decref(out);
  return 0;
}

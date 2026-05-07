#ifndef TOON_FORMAT_H
#define TOON_FORMAT_H

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum { TOON_NULL, TOON_STRING, TOON_OBJECT, TOON_ARRAY } ToonType;

typedef struct ToonValue ToonValue;

typedef struct {
  char *key;
  ToonValue *value;
} ToonEntry;

struct ToonValue {
  ToonType type;
  union {
    char *str_val;
    struct {
      ToonValue **items;
      size_t count;
    } array;
    struct {
      ToonEntry *entries;
      size_t count;
    } object;
  } data;
};

ToonValue *toon_parse(const char *input);
void toon_free(ToonValue *value);
void toon_print(ToonValue *value, int indent);

#ifdef TOON_IMPLEMENTATION

// --- Helpers ---

static char *my_strdup(const char *s) {
  if (!s)
    return NULL;
  size_t len = strlen(s);
  char *d = malloc(len + 1);
  if (d)
    strcpy(d, s);
  return d;
}

static char *my_strndup(const char *s, size_t n) {
  if (!s)
    return NULL;
  char *d = malloc(n + 1);
  if (d) {
    strncpy(d, s, n);
    d[n] = '\0';
  }
  return d;
}

static ToonValue *tv_new(ToonType t) {
  ToonValue *v = calloc(1, sizeof(ToonValue));
  v->type = t;
  return v;
}

static ToonValue *tv_str(char *s) {
  ToonValue *v = tv_new(TOON_STRING);
  v->data.str_val = s;
  return v;
}

static void tv_obj_add(ToonValue *obj, const char *key, ToonValue *val) {
  if (obj->type != TOON_OBJECT)
    return;
  obj->data.object.entries =
      realloc(obj->data.object.entries,
              (obj->data.object.count + 1) * sizeof(ToonEntry));
  obj->data.object.entries[obj->data.object.count].key = my_strdup(key);
  obj->data.object.entries[obj->data.object.count].value = val;
  obj->data.object.count++;
}

static void tv_arr_push(ToonValue *arr, ToonValue *val) {
  if (arr->type != TOON_ARRAY)
    return;
  arr->data.array.items = realloc(
      arr->data.array.items, (arr->data.array.count + 1) * sizeof(ToonValue *));
  arr->data.array.items[arr->data.array.count++] = val;
}

void toon_free(ToonValue *v) {
  if (!v)
    return;
  if (v->type == TOON_STRING)
    free(v->data.str_val);
  if (v->type == TOON_ARRAY) {
    for (size_t i = 0; i < v->data.array.count; i++)
      toon_free(v->data.array.items[i]);
    free(v->data.array.items);
  }
  if (v->type == TOON_OBJECT) {
    for (size_t i = 0; i < v->data.object.count; i++) {
      free(v->data.object.entries[i].key);
      toon_free(v->data.object.entries[i].value);
    }
    free(v->data.object.entries);
  }
  free(v);
}

void toon_print(ToonValue *v, int indent) {
  if (!v)
    return;
  for (int i = 0; i < indent; i++)
    printf("  ");
  if (v->type == TOON_STRING) {
    printf("%s\n", v->data.str_val);
  } else if (v->type == TOON_ARRAY) {
    printf("[\n");
    for (size_t i = 0; i < v->data.array.count; i++) {
      toon_print(v->data.array.items[i], indent + 1);
    }
    for (int i = 0; i < indent; i++)
      printf("  ");
    printf("]\n");
  } else if (v->type == TOON_OBJECT) {
    printf("{\n");
    for (size_t i = 0; i < v->data.object.count; i++) {
      for (int j = 0; j < indent + 1; j++)
        printf("  ");
      printf("%s: ", v->data.object.entries[i].key);
      if (v->data.object.entries[i].value->type == TOON_STRING) {
        printf("%s\n", v->data.object.entries[i].value->data.str_val);
      } else {
        printf("\n");
        toon_print(v->data.object.entries[i].value, indent + 1);
      }
    }
    for (int i = 0; i < indent; i++)
      printf("  ");
    printf("}\n");
  }
}

// --- Parser ---

typedef struct {
  const char *src;
  size_t pos;
} Parser;

static void skip_ws(Parser *p) {
  while (p->src[p->pos] && (p->src[p->pos] == ' ' || p->src[p->pos] == '\t'))
    p->pos++;
}

static void skip_line(Parser *p) {
  while (p->src[p->pos] && p->src[p->pos] != '\n')
    p->pos++;
  if (p->src[p->pos] == '\n')
    p->pos++;
}

static char *parse_until(Parser *p, const char *delims) {
  size_t start = p->pos;
  while (p->src[p->pos] && !strchr(delims, p->src[p->pos]))
    p->pos++;
  return my_strndup(p->src + start, p->pos - start);
}

static char *trim(char *s) {
  if (!s)
    return NULL;
  char *end = s + strlen(s) - 1;
  while (end > s && isspace(*end))
    *end-- = '\0';
  char *start = s;
  while (*start && isspace(*start))
    start++;
  return start;
}

// Recursive parser that consumes lines at >= min_indent
static ToonValue *parse_block(Parser *p, int min_indent) {
  ToonValue *obj = tv_new(TOON_OBJECT);

  while (p->src[p->pos]) {
    // Check indentation
    size_t line_start = p->pos;
    int indent = 0;
    while (p->src[p->pos] == ' ') {
      p->pos++;
      indent++;
    }

    if (p->src[p->pos] == '\n' || p->src[p->pos] == '\0') { // Empty line
      p->pos++;
      continue;
    }

    if (indent < min_indent) {
      p->pos = line_start; // Backtrack
      break;
    }

    // Parse Key
    char *key_part = parse_until(p, ":[");
    char *key = my_strdup(trim(key_part));
    free(key_part);

    if (p->src[p->pos] == '[') {
      // Array or Table: key[n]...
      p->pos++; // skip [
      char *count_str = parse_until(p, "]");
      int count = atoi(count_str);
      free(count_str);
      if (p->src[p->pos] == ']')
        p->pos++;

      if (p->src[p->pos] == '{') {
        // Table: key[n]{col1,col2}:
        p->pos++; // skip {
        char *cols_str = parse_until(p, "}");
        if (p->src[p->pos] == '}')
          p->pos++;
        if (p->src[p->pos] == ':')
          p->pos++;
        skip_line(p); // Move to next line for data

        ToonValue *arr = tv_new(TOON_ARRAY);

        // Parse columns
        int col_count = 0;
        char **cols = malloc(32 * sizeof(char *)); // simplistic
        char *c_ptr = cols_str;
        char *tok = strtok(c_ptr, ",");
        while (tok) {
          cols[col_count++] = my_strdup(trim(tok));
          tok = strtok(NULL, ",");
        }

        // Parse rows
        for (int i = 0; i < count; i++) {
          // Check indent
          size_t r_start = p->pos;
          int r_indent = 0;
          while (p->src[p->pos] == ' ') {
            p->pos++;
            r_indent++;
          }
          if (r_indent <= indent) { // Should be indented
            p->pos = r_start;
            break;
          }

          ToonValue *row_obj = tv_new(TOON_OBJECT);
          char *line = parse_until(p, "\n");
          if (p->src[p->pos] == '\n')
            p->pos++;

          char *l_ptr = line;
          char *val_tok = strtok(l_ptr, ",");
          int c_idx = 0;
          while (val_tok && c_idx < col_count) {
            tv_obj_add(row_obj, cols[c_idx], tv_str(my_strdup(trim(val_tok))));
            val_tok = strtok(NULL, ",");
            c_idx++;
          }
          tv_arr_push(arr, row_obj);
          free(line);
        }

        tv_obj_add(obj, key, arr);
        for (int k = 0; k < col_count; k++)
          free(cols[k]);
        free(cols);
        free(cols_str);

      } else {
        // Simple Array: key[n]: val1,val2...
        if (p->src[p->pos] == ':')
          p->pos++;
        char *vals_str = parse_until(p, "\n");
        if (p->src[p->pos] == '\n')
          p->pos++;

        ToonValue *arr = tv_new(TOON_ARRAY);
        char *v_ptr = vals_str;
        char *tok = strtok(v_ptr, ",");
        while (tok) {
          tv_arr_push(arr, tv_str(my_strdup(trim(tok))));
          tok = strtok(NULL, ",");
        }
        tv_obj_add(obj, key, arr);
        free(vals_str);
      }

    } else if (p->src[p->pos] == ':') {
      p->pos++; // skip :
      // Check if value is on same line or next block
      size_t val_start = p->pos;
      char *inline_val = parse_until(p, "\n");
      char *trimmed_val = trim(inline_val);

      if (strlen(trimmed_val) > 0) {
        // Inline value
        tv_obj_add(obj, key, tv_str(my_strdup(trimmed_val)));
        if (p->src[p->pos] == '\n')
          p->pos++;
      } else {
        // Nested block
        if (p->src[p->pos] == '\n')
          p->pos++;
        ToonValue *child = parse_block(p, indent + 1);
        tv_obj_add(obj, key, child);
      }
      free(inline_val);
    } else {
      // Unknown, skip line
      skip_line(p);
    }
    free(key);
  }
  return obj;
}

ToonValue *toon_parse(const char *input) {
  Parser p = {input, 0};
  return parse_block(&p, 0);
}

#endif // TOON_IMPLEMENTATION
#endif // TOON_FORMAT_H

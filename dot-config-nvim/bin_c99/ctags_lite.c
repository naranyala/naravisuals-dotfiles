
// build: cc ctags-lite.c -O2 -o ctags-lite
// ctags-lite.c : simple symbol extractor for C-like & Lua files
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int is_ident_char(int c) { return isalnum(c) || c == '_'; }

void process_file(const char *path) {
  FILE *f = fopen(path, "r");
  if (!f)
    return;
  char buf[4096];
  int lineno = 0;
  while (fgets(buf, sizeof buf, f)) {
    lineno++;
    // Trim leading spaces
    char *s = buf;
    while (*s && isspace((unsigned char)*s))
      s++;
    if (*s == '\0')
      continue;

    // Lua: function name or local function
    if (strncmp(s, "function ", 9) == 0) {
      char *p = s + 9;
      while (*p && isspace((unsigned char)*p))
        p++;
      char name[512] = {0};
      int i = 0;
      while (*p && (is_ident_char(*p) || *p == '.' || *p == ':') && i < 500)
        name[i++] = *p++;
      if (i)
        printf("%s\tfunction\t%s\t%d\n", name, path, lineno);
      continue;
    }
    if (strncmp(s, "local function ", 15) == 0) {
      char *p = s + 15;
      char name[512] = {0};
      int i = 0;
      while (*p && (is_ident_char(*p)) && i < 500)
        name[i++] = *p++;
      if (i)
        printf("%s\tfunction\t%s\t%d\n", name, path, lineno);
      continue;
    }

    // C-like: try to catch "type name(...){"
    // naive: look for '(' then preceding token is name, tokens before are type
    char *paren = strchr(s, '(');
    if (paren) {
      // back-scan to find identifier before '('
      char *q = paren - 1;
      while (q > s && isspace((unsigned char)*q))
        q--;
      // collect identifier backwards
      char name[512] = {0};
      int ni = 0;
      char *end = q;
      while (q >= s && is_ident_char((unsigned char)*q))
        q--;
      q++;
      while (q <= end && ni < 500) {
        name[ni++] = *q++;
      }
      if (ni > 0) {
        // don't report lines that are "if (", "for (" etc.
        if (strcmp(name, "if") && strcmp(name, "for") &&
            strcmp(name, "while") && strcmp(name, "switch")) {
          printf("%s\tfunction\t%s\t%d\n", name, path, lineno);
        }
      }
    }

    // Simple constant/define detection
    if (strncmp(s, "#define ", 8) == 0) {
      char *p = s + 8;
      while (*p && isspace((unsigned char)*p))
        p++;
      char name[512] = {0};
      int i = 0;
      while (*p && (is_ident_char(*p)) && i < 500)
        name[i++] = *p++;
      if (i)
        printf("%s\tdefine\t%s\t%d\n", name, path, lineno);
    }
  }
  fclose(f);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    // read paths from stdin
    char path[4096];
    while (fgets(path, sizeof path, stdin)) {
      // strip newline
      char *nl = strchr(path, '\n');
      if (nl)
        *nl = 0;
      process_file(path);
    }
    return 0;
  }
  for (int i = 1; i < argc; i++)
    process_file(argv[i]);
  return 0;
}

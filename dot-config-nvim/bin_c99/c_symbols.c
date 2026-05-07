// c_symbols.c
// Scan C files in current dir (non-recursively) and extract function signatures
// Output: JSON lines: {"name":"foo","file":"test.c","line":10}

#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int is_c_file(const char *name) {
  const char *ext = strrchr(name, '.');
  return ext && (strcmp(ext, ".c") == 0 || strcmp(ext, ".h") == 0);
}

void scan_file(const char *filepath) {
  FILE *fp = fopen(filepath, "r");
  if (!fp)
    return;

  char line[1024];
  int lnum = 0;
  while (fgets(line, sizeof(line), fp)) {
    lnum++;
    char *p = line;
    // Skip whitespace
    while (*p && isspace(*p))
      p++;
    if (!*p || *p == '/' || *p == '*' || *p == '#')
      continue;

    // Very basic function detection: name followed by '('
    char name[256];
    if (sscanf(p, "%*[a-zA-Z_ ][a-zA-Z0-9_]%[a-zA-Z0-9_]", name) == 1) {
      char *paren = strchr(p, '(');
      if (paren && paren > p) {
        // Ensure there's a return type-like word before
        char *start = p;
        while (start < paren && !isalpha(*start))
          start++;
        if (start < paren) {
          *paren = '\0';
          char *func_name = start;
          while (*func_name && !isalpha(*func_name))
            func_name++;
          if (*func_name) {
            printf("{\"name\":\"%s\",\"file\":\"%s\",\"line\":%d}\n", func_name,
                   filepath, lnum);
          }
        }
      }
    }
  }
  fclose(fp);
}

int main(int argc, char *argv[]) {
  const char *dir = ".";
  if (argc > 1)
    dir = argv[1];

  DIR *d = opendir(dir);
  if (!d) {
    perror("opendir");
    return 1;
  }

  struct dirent *ent;
  while ((ent = readdir(d)) != NULL) {
    if (is_c_file(ent->d_name)) {
      char path[1024];
      snprintf(path, sizeof(path), "%s/%s", dir, ent->d_name);
      scan_file(path);
    }
  }
  closedir(d);
  return 0;
}

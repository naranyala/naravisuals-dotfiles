// c_grep.c
// Usage: ./c_grep "error" *.c
// Output: JSON lines: {"file":"main.c","line":24,"snippet":"int foo() {\n  if
// (error) ... \n}\n"}

#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void json_str(const char *s) {
  putchar('"');
  for (; *s; s++) {
    if (*s == '"' || *s == '\\')
      putchar('\\');
    if (*s == '\n') {
      putchar('\\');
      putchar('n');
      continue;
    }
    if (*s == '\r') {
      putchar('\\');
      putchar('r');
      continue;
    }
    putchar(*s);
  }
  putchar('"');
}

// Very simple: is this line a function start? (heuristic)
int is_func_start(const char *line) {
  // Skip whitespace
  while (*line && isspace(*line))
    line++;
  if (!*line || *line == '/' || *line == '*' || *line == '#')
    return 0;

  // Look for '(' after a word, and no ';' before it
  const char *p = line;
  while (*p && (isalnum(*p) || *p == '_' || *p == '*' || *p == ' '))
    p++;
  if (*p != '(')
    return 0;

  // Ensure no ';' between start and '('
  const char *semi = strchr(line, ';');
  const char *paren = strchr(line, '(');
  if (semi && semi < paren)
    return 0;

  return 1;
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Usage: %s <pattern> <file1> [file2 ...]\n", argv[0]);
    return 1;
  }

  const char *pattern = argv[1];

  for (int i = 2; i < argc; i++) {
    const char *filepath = argv[i];
    FILE *fp = fopen(filepath, "r");
    if (!fp)
      continue;

    char *lines[10000] = {0}; // store lines (simplified; assume <10k lines)
    int line_count = 0;
    char buf[1024];

    while (fgets(buf, sizeof(buf), fp)) {
      // Store copy
      size_t len = strlen(buf);
      char *copy = malloc(len + 1);
      memcpy(copy, buf, len + 1);
      lines[line_count++] = copy;
    }
    fclose(fp);

    // Scan for matches
    for (int j = 0; j < line_count; j++) {
      if (strstr(lines[j], pattern)) {
        // Find start of function
        int start = j;
        while (start > 0 && !is_func_start(lines[start]))
          start--;

        // Find end: balance braces
        int depth = 0;
        int end = j;
        for (int k = start; k < line_count; k++) {
          for (char *p = lines[k]; *p; p++) {
            if (*p == '{')
              depth++;
            else if (*p == '}')
              depth--;
          }
          if (depth == 0 && k > start) {
            end = k;
            break;
          }
        }

        // Build snippet
        printf("{");
        printf("\"file\":");
        json_str(filepath);
        printf(",\"line\":%d", j + 1);
        printf(",\"snippet\":");
        putchar('"');
        for (int k = start; k <= end; k++) {
          char *p = lines[k];
          while (*p) {
            if (*p == '"' || *p == '\\')
              putchar('\\');
            putchar(*p++);
          }
        }
        printf("\"}\n");
        break; // one match per file
      }
    }

    // Free lines
    for (int j = 0; j < line_count; j++)
      free(lines[j]);
  }
  return 0;
}

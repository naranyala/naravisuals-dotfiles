#include <ctype.h>
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_SYMBOLS 1000
#define MAX_NAME 256
#define MAX_LINE 1024

typedef struct {
  char name[MAX_NAME];
  char type[32]; // e.g., "function", "variable"
  int line;
  int col;
} Symbol;

void parse_symbols(FILE *f, Symbol *symbols, int *count, const char *filter) {
  char line[MAX_LINE];
  int lineno = 1;
  while (fgets(line, sizeof(line), f)) {
    char *p = line;
    while (*p) {
      if (isspace(*p)) {
        p++;
        continue;
      }

      // Simple heuristic: look for "type name(" for funcs, "type name;" for
      // vars
      char type[MAX_NAME] = {0}, name[MAX_NAME] = {0};
      if (sscanf(p, "%s %s", type, name) == 2) {
        if (strstr(name, "(")) { // Function
          if (!filter || strcmp(filter, "functions") == 0) {
            strncpy(symbols[*count].name, name, MAX_NAME - 1);
            strcpy(symbols[*count].type, "function");
            symbols[*count].line = lineno;
            symbols[*count].col = p - line + strlen(type) + 1;
            (*count)++;
          }
        } else if (strstr(p, ";")) { // Variable (basic)
          if (!filter || strcmp(filter, "variables") == 0) {
            strncpy(symbols[*count].name, name, MAX_NAME - 1);
            strcpy(symbols[*count].type, "variable");
            symbols[*count].line = lineno;
            symbols[*count].col = p - line + strlen(type) + 1;
            (*count)++;
          }
        }
      }
      while (*p && !isspace(*p))
        p++; // Skip word
    }
    lineno++;
    if (*count >= MAX_SYMBOLS)
      break;
  }
}

int main(int argc, char **argv) {
  char *file = NULL;
  char *lang = "c"; // Default
  char *filter = NULL;
  int json = 0;

  static struct option long_options[] = {{"lang", required_argument, 0, 'l'},
                                         {"filter", required_argument, 0, 'f'},
                                         {"json", no_argument, 0, 'j'},
                                         {0, 0, 0, 0}};

  int opt;
  while ((opt = getopt_long(argc, argv, "l:f:j", long_options, NULL)) != -1) {
    switch (opt) {
    case 'l':
      lang = optarg;
      break;
    case 'f':
      filter = optarg;
      break;
    case 'j':
      json = 1;
      break;
    default:
      fprintf(stderr, "Usage: %s <file> --lang=c --filter=functions --json\n",
              argv[0]);
      exit(1);
    }
  }
  if (optind < argc)
    file = argv[optind];
  if (!file) {
    fprintf(stderr, "Need file\n");
    exit(1);
  }

  FILE *f = fopen(file, "r");
  if (!f) {
    perror("fopen");
    exit(1);
  }

  Symbol symbols[MAX_SYMBOLS];
  int count = 0;
  parse_symbols(f, symbols, &count, filter);
  fclose(f);

  if (json) {
    printf("[\n");
    for (int i = 0; i < count; i++) {
      printf("{\"name\":\"%s\",\"type\":\"%s\",\"line\":%d,\"col\":%d}%s\n",
             symbols[i].name, symbols[i].type, symbols[i].line, symbols[i].col,
             i < count - 1 ? "," : "");
    }
    printf("]\n");
  }

  return 0;
}

#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_TOKENS 10000
#define MAX_LINE 1024

typedef struct {
  int start;
  int end;
  char type[32]; // e.g., "header", "bold"
} Token;

void highlight_md(FILE *f, Token *tokens, int *count) {
  char line[MAX_LINE];
  int pos = 0;
  while (fgets(line, sizeof(line), f)) {
    char *p = line;
    if (*p == '#') { // Header
      tokens[*count].start = pos;
      tokens[*count].end = pos + strlen(line);
      strcpy(tokens[*count].type, "header");
      (*count)++;
    } else {
      // Basic bold: **text**
      while ((p = strstr(p, "**"))) {
        char *end = strstr(p + 2, "**");
        if (end) {
          tokens[*count].start = pos + (p - line);
          tokens[*count].end = pos + (end - line + 2);
          strcpy(tokens[*count].type, "bold");
          (*count)++;
          p = end + 2;
        } else
          break;
      }
    }
    pos += strlen(line);
  }
}

int main(int argc, char **argv) {
  char *file = NULL;
  char *lang = "markdown";
  char *format = "json";

  static struct option long_options[] = {{"lang", required_argument, 0, 'l'},
                                         {"format", required_argument, 0, 'f'},
                                         {0, 0, 0, 0}};

  int opt;
  while ((opt = getopt_long(argc, argv, "l:f:", long_options, NULL)) != -1) {
    switch (opt) {
    case 'l':
      lang = optarg;
      break;
    case 'f':
      format = optarg;
      break;
    default:
      fprintf(stderr, "Usage: %s <file> --lang=md --format=json\n", argv[0]);
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

  Token tokens[MAX_TOKENS];
  int count = 0;
  if (strcmp(lang, "markdown") == 0) {
    highlight_md(f, tokens, &count);
  } // Add more langs here

  fclose(f);

  if (strcmp(format, "json") == 0) {
    printf("[\n");
    for (int i = 0; i < count; i++) {
      printf("{\"start\":%d,\"end\":%d,\"type\":\"%s\"}%s\n", tokens[i].start,
             tokens[i].end, tokens[i].type, i < count - 1 ? "," : "");
    }
    printf("]\n");
  }

  return 0;
}

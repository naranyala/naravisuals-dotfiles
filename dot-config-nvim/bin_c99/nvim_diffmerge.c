#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_LINES 10000 // Adjustable
#define LINE_LEN 1024

char *read_file(const char *path, int *line_count) {
  FILE *f = fopen(path, "r");
  if (!f) {
    perror("fopen");
    exit(1);
  }

  char *lines = malloc(MAX_LINES * LINE_LEN);
  if (!lines) {
    perror("malloc");
    exit(1);
  }

  *line_count = 0;
  char buf[LINE_LEN];
  char *ptr = lines;
  while (fgets(buf, sizeof(buf), f)) {
    strcpy(ptr, buf);
    ptr += LINE_LEN;
    (*line_count)++;
  }
  fclose(f);
  return lines;
}

void print_diff(const char *file1, const char *file2, int ignore_ws) {
  int lc1, lc2;
  char *lines1 = read_file(file1, &lc1);
  char *lines2 = read_file(file2, &lc2);

  // Simple line-by-line diff (expand for better algo)
  printf("--- %s\n+++ %s\n", file1, file2);
  int i = 0, j = 0;
  while (i < lc1 || j < lc2) {
    char *l1 = i < lc1 ? lines1 + i * LINE_LEN : NULL;
    char *l2 = j < lc2 ? lines2 + j * LINE_LEN : NULL;

    if (ignore_ws) { // Trim whitespace (basic)
      if (l1)
        while (*l1 == ' ' || *l1 == '\t')
          l1++;
      if (l2)
        while (*l2 == ' ' || *l2 == '\t')
          l2++;
    }

    if (l1 && l2 && strcmp(l1, l2) == 0) {
      printf(" %s", l1);
      i++;
      j++;
    } else if (l1) {
      printf("-%s", l1);
      i++;
    } else if (l2) {
      printf("+%s", l2);
      j++;
    } else {
      break;
    }
  }

  free(lines1);
  free(lines2);
}

int main(int argc, char **argv) {
  int ignore_ws = 0;
  char *format = "unified"; // Default

  static struct option long_options[] = {
      {"ignore-whitespace", no_argument, 0, 'w'},
      {"format", required_argument, 0, 'f'},
      {0, 0, 0, 0}};

  int opt;
  while ((opt = getopt_long(argc, argv, "wf:", long_options, NULL)) != -1) {
    switch (opt) {
    case 'w':
      ignore_ws = 1;
      break;
    case 'f':
      format = optarg;
      break;
    default:
      fprintf(
          stderr,
          "Usage: %s file1 file2 [--ignore-whitespace] [--format=unified]\n",
          argv[0]);
      exit(1);
    }
  }

  if (optind + 2 != argc) {
    fprintf(stderr, "Need two files\n");
    exit(1);
  }

  // Only unified for now
  if (strcmp(format, "unified") == 0) {
    print_diff(argv[optind], argv[optind + 1], ignore_ws);
  } else {
    fprintf(stderr, "Unsupported format\n");
    exit(1);
  }

  return 0;
}

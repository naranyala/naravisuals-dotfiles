/* bufgrep.c  –  usage: bufgrep PATTERN file1 file2 …
   prints  file:line:col:text   (col is byte-offset, 1-based) */
#include <regex.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void grep_file(regex_t *re, const char *fname) {
  FILE *f = fopen(fname, "r");
  if (!f) {
    perror(fname);
    return;
  }
  char *line = NULL;
  size_t cap = 0;
  ssize_t len;
  long lnum = 0;
  while ((len = getline(&line, &cap, f)) != -1) {
    ++lnum;
    regmatch_t m;
    char *p = line;
    while (regexec(re, p, 1, &m, 0) == 0) {
      long col = (p - line) + m.rm_so + 1;
      /* temporary NUL to print match only */
      char save = p[m.rm_eo];
      p[m.rm_eo] = '\0';
      printf("%s:%ld:%ld:%s\n", fname, lnum, col, p + m.rm_so);
      p[m.rm_eo] = save;
      p += m.rm_eo;
    }
  }
  free(line);
  fclose(f);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: bufgrep PATTERN file…\n");
    return 1;
  }
  regex_t re;
  if (regcomp(&re, argv[1], REG_EXTENDED)) {
    fprintf(stderr, "invalid regex\n");
    return 1;
  }
  for (int i = 2; i < argc; ++i)
    grep_file(&re, argv[i]);
  regfree(&re);
  return 0;
}

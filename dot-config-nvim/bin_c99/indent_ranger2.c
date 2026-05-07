/* indent-ranger [FILE]
   prints:  space<TAB>4   or   tab<TAB>8  (style<TAB>width) */
#include <ctype.h>
#include <stdio.h>

int main(int argc, char **argv) {
  FILE *f = stdin;
  if (argc > 1) {
    f = fopen(argv[1], "r");
    if (!f)
      return 1;
  }
  int space_hist[17] = {0}, tab_cnt = 0;
  char *line = NULL;
  size_t cap = 0;
  ssize_t len;
  while ((len = getline(&line, &cap, f)) != -1) {
    int sp = 0;
    for (char *p = line; *p == ' ' || *p == '\t'; p++)
      if (*p == ' ')
        sp++;
      else
        tab_cnt++;
    if (sp && sp <= 16)
      space_hist[sp]++;
  }
  free(line);
  if (argc > 1)
    fclose(f);

  int best_sp = 0, best_n = 0;
  for (int i = 1; i <= 16; ++i)
    if (space_hist[i] > best_n) {
      best_n = space_hist[i];
      best_sp = i;
    }

  if (tab_cnt > best_n)
    printf("tab\t8\n");
  else
    printf("space\t%d\n", best_sp);
  return 0;
}

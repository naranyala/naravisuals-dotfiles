/* indent-ranger.c  –  prints:  width  style  (tab|space) */
#include <ctype.h>
#include <stdio.h>

#define MAX_DEPTH 1000
static int spaces[MAX_DEPTH], tabs[MAX_DEPTH], total = 0;

int main(int argc, char **argv) {
  FILE *f = stdin;
  if (argc > 1) {
    f = fopen(argv[1], "r");
    if (!f) {
      perror(argv[1]);
      return 1;
    }
  }
  char *line = NULL;
  size_t cap = 0;
  ssize_t len;
  while ((len = getline(&line, &cap, f)) != -1) {
    int indent = 0, sp = 0, tb = 0;
    for (char *p = line; *p == ' ' || *p == '\t'; ++p)
      if (*p == ' ')
        sp++;
      else
        tb++;
    if (tb)
      tabs[tb]++;
    else if (sp)
      spaces[sp]++;
    total++;
  }
  free(line);
  if (argc > 1)
    fclose(f);

  /* pick most common */
  int bestsp = 0, bestsb = 0, besttb = 0;
  for (int i = 1; i < MAX_DEPTH; i++) {
    if (spaces[i] > bestsb) {
      bestsb = spaces[i];
      bestsp = i;
    }
    if (tabs[i] > besttb)
      besttb = tabs[i];
  }
  if (besttb > bestsb)
    printf("tab\t%d\n", besttb);
  else
    printf("space\t%d\n", bestsp);
  return 0;
}

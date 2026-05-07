/* tag-jump TAGSFILE TAGNAME
   prints:  file<TAB>line   (or nothing if not found) */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc != 3)
    return 1;
  FILE *f = fopen(argv[1], "r");
  if (!f)
    return 1;
  char *line = NULL;
  size_t cap = 0;
  while (getline(&line, &cap, f) != -1) {
    if (line[0] == '!')
      continue; /* comment */
    char *tag = strtok(line, "\t");
    if (!tag || strcmp(tag, argv[2]))
      continue;
    char *file = strtok(NULL, "\t");
    char *addr = strtok(NULL, "\t");
    long lnum = 0;
    if (addr[0] == '/' || addr[0] == '?') { /* ex cmd */
      char *p = addr + 1;
      while (*p && *p != '$')
        if (*p++ == ':')
          lnum = strtol(p, NULL, 10);
    } else
      lnum = strtol(addr, NULL, 10);
    printf("%s\t%ld\n", file, lnum);
    free(line);
    fclose(f);
    return 0;
  }
  free(line);
  fclose(f);
  return 1;
}

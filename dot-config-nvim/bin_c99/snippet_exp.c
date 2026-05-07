/* snippet-exp FILE.snippet TRIGGER
   prints expanded text with $1, $2 placeholders */
#include <stdio.h>
#include <string.h>

static char buf[64 * 1024];
int main(int argc, char **argv) {
  if (argc != 3)
    return 1;
  FILE *f = fopen(argv[1], "r");
  if (!f)
    return 1;
  char *p, *start = NULL;
  while (fgets(buf, sizeof(buf), f)) {
    if ((p = strstr(buf, "snippet ")) &&
        !strncmp(p + 8, argv[2], strlen(argv[2]))) {
      start = fgets(buf, sizeof(buf), f); /* next line is body */
      break;
    }
  }
  if (!start) {
    fclose(f);
    return 1;
  }
  /* very naive: stop at next empty line */
  do {
    if (*buf == '\n')
      break;
    fputs(buf, stdout);
  } while (fgets(buf, sizeof(buf), f) && *buf != '\n');
  fclose(f);
  return 0;
}

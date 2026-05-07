
// grep-lite.c : simple literal grep
// build: cc grep-lite.c -O2 -o grep-lite

#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: grep-lite <pattern> [files...]\n");
    return 1;
  }

  const char *pat = argv[1];
  char buf[4096];

  if (argc == 2) {
    int line = 1;
    while (fgets(buf, sizeof buf, stdin)) {
      if (strstr(buf, pat))
        printf("stdin:%d:%s", line, buf);
      line++;
    }
    return 0;
  }

  for (int i = 2; i < argc; i++) {
    FILE *fp = fopen(argv[i], "r");
    if (!fp)
      continue;

    int line = 1;
    while (fgets(buf, sizeof buf, fp)) {
      if (strstr(buf, pat))
        printf("%s:%d:%s", argv[i], line, buf);
      line++;
    }

    fclose(fp);
  }

  return 0;
}

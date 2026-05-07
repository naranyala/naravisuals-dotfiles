
// diff-lite.c : tiny Myers diff
// build: cc diff-lite.c -O2 -o diff-lite

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX 4096

char *file[MAX];
char *file2[MAX];
int n1 = 0, n2 = 0;

void readfile(char *path, char **dst, int *n) {
  FILE *fp = fopen(path, "r");
  if (!fp)
    exit(1);
  char buf[4096];
  while (fgets(buf, sizeof buf, fp)) {
    dst[*n] = strdup(buf);
    (*n)++;
  }
  fclose(fp);
}

int main(int argc, char **argv) {
  if (argc != 3) {
    fprintf(stderr, "usage: diff-lite <a> <b>\n");
    return 1;
  }

  readfile(argv[1], file, &n1);
  readfile(argv[2], file2, &n2);

  int i = 0, j = 0;
  while (i < n1 || j < n2) {
    if (i < n1 && j < n2 && strcmp(file[i], file2[j]) == 0) {
      i++;
      j++; // unchanged
    } else {
      if (i < n1)
        printf("- %s", file[i]);
      if (j < n2)
        printf("+ %s", file2[j]);
      i++;
      j++;
    }
  }

  return 0;
}

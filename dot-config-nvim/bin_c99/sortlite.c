
// sort-lite.c : stable sorter
// build: cc sort-lite.c -O2 -o sort-lite

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
  char *line;
  int index;
} Item;

int cmp(const void *a, const void *b) {
  const Item *x = a, *y = b;
  return strcmp(x->line, y->line);
}

int main() {
  Item *items = NULL;
  size_t cap = 0, len = 0;
  char buf[4096];

  while (fgets(buf, sizeof buf, stdin)) {
    if (len == cap) {
      cap = cap ? cap * 2 : 128;
      items = realloc(items, cap * sizeof(Item));
    }
    items[len].line = strdup(buf);
    items[len].index = len;
    len++;
  }

  qsort(items, len, sizeof(Item), cmp);

  for (size_t i = 0; i < len; i++) {
    printf("%s", items[i].line);
    free(items[i].line);
  }

  free(items);
  return 0;
}

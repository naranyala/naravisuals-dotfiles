
// fzf-lite.c : simple fuzzy match CLI
// build: cc fzf-lite.c -O2 -o fzf-lite

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int score(const char *q, const char *s) {
  int sc = 0, streak = 0;
  for (; *s; s++) {
    if (*q && tolower(*q) == tolower(*s)) {
      sc += 5 + streak;
      streak++;
      q++;
    } else {
      streak = 0;
    }
  }
  return *q ? -1 : sc; // -1 = not matched
}

typedef struct {
  char *line;
  int score;
} Item;

int cmp_item(const void *a, const void *b) {
  const Item *x = a, *y = b;
  return y->score - x->score;
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: fzf-lite <query>\n");
    return 1;
  }

  char *query = argv[1];
  Item *items = NULL;
  size_t cap = 0, len = 0;
  char buf[4096];

  while (fgets(buf, sizeof(buf), stdin)) {
    if (len == cap) {
      cap = cap ? cap * 2 : 128;
      items = realloc(items, cap * sizeof(Item));
    }
    items[len].line = strdup(buf);
    items[len].score = score(query, buf);
    len++;
  }

  qsort(items, len, sizeof(Item), cmp_item);

  for (size_t i = 0; i < len; i++) {
    if (items[i].score >= 0)
      printf("%d\t%s", items[i].score, items[i].line);
    free(items[i].line);
  }

  free(items);
  return 0;
}

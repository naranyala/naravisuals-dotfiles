#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// --- Data Structures ---

typedef struct {
  char *item;
  int score;
} ResultItem;

// --- Fuzzy Matching Core (Simplified) ---

// A very basic score: just counts character matches in order.
// In a real implementation, you'd use a more sophisticated algorithm (like
// fzf's).
int calculate_score(const char *text, const char *query) {
  if (!query || !*query)
    return 1000; // Empty query gets high score
  if (!text)
    return 0;

  int score = 0;
  const char *t = text;
  const char *q = query;

  while (*t && *q) {
    if (tolower(*t) == tolower(*q)) {
      score += 10;
      q++; // Matched a query char, move to the next
    }
    score++; // Give a small bonus for shorter text
    t++;
  }
  // Penalize if not all query characters were consumed
  if (*q)
    return 0;
  return score;
}

// Comparison function for qsort (descending score)
int compare_results(const void *a, const void *b) {
  return ((ResultItem *)b)->score - ((ResultItem *)a)->score;
}

// --- Main Execution ---

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <query>\n", argv[0]);
    return 1;
  }
  const char *query = argv[1];

  ResultItem *results = NULL;
  size_t count = 0;
  size_t capacity = 0;
  char *line = NULL;
  size_t len = 0;
  ssize_t read;

  // 1. Read input items from stdin (e.g., file list)
  while ((read = getline(&line, &len, stdin)) != -1) {
    // Remove trailing newline
    if (read > 0 && line[read - 1] == '\n') {
      line[read - 1] = '\0';
    }

    int score = calculate_score(line, query);

    if (score > 0) {
      // Reallocate list if capacity is reached
      if (count >= capacity) {
        capacity = capacity == 0 ? 100 : capacity * 2;
        results = realloc(results, capacity * sizeof(ResultItem));
        if (!results) {
          perror("realloc failed");
          break;
        }
      }

      results[count].item = strdup(line); // Copy the line
      results[count].score = score;
      count++;
    }
  }
  free(line);

  // 2. Sort the results
  qsort(results, count, sizeof(ResultItem), compare_results);

  // 3. Print top results to stdout (Neovim reads this)
  for (size_t i = 0; i < count; i++) {
    printf("%s\n", results[i].item);
    free(results[i].item);
  }
  free(results);

  return 0;
}

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Represents a file path and its calculated score.
typedef struct {
  char *item;
  int score;
} ResultItem;

// Comparison for qsort (Descending score)
int compare_results(const void *a, const void *b) {
  return ((ResultItem *)b)->score - ((ResultItem *)a)->score;
}

// Optimized Fuzzy Score function (FZF-style logic)
int calculate_score(const char *text, const char *query) {
  if (!query || *query == '\0')
    return 1000;
  if (!text)
    return 0;

  int score = 0;
  const char *t = text;
  const char *q = query;
  const char *last_match = NULL;
  int consecutive_bonus = 0;

  while (*t && *q) {
    if (tolower(*t) == tolower(*q)) {
      // Base match score
      score += 10;

      // CONSECUTIVE MATCH BONUS
      consecutive_bonus += 1;
      score += consecutive_bonus * 5;

      // BOUNDARY BONUS (e.g., match after '/')
      if (last_match && (*t == '/' || *(t - 1) == '/')) {
        score += 50;
      }
      // CAMELCASE BONUS
      else if (last_match && islower(*(t - 1)) && isupper(*t)) {
        score += 30;
      }

      last_match = t;
      q++; // Move to the next query character
    } else {
      // Reset consecutive bonus if mismatch
      consecutive_bonus = 0;
    }
    t++; // Always move through the text
  }

  // Penalize if not all query characters were found
  if (*q)
    return 0;

  // Small bonus for shorter strings
  score -= (int)(t - text);

  // Ensure score is non-negative
  return (score > 0) ? score : 1;
}

// ... main function (reading from stdin, sorting, printing to stdout) remains
// similar to the previous example.

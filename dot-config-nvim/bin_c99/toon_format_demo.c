#include <stdio.h>
#include <stdlib.h>

#define TOON_IMPLEMENTATION
#include "toon_format.h"

int main() {
  const char *toon_source =
      "context:\n"
      "  task: Our favorite hikes together\n"
      "  location: Boulder\n"
      "  season: spring_2025\n"
      "friends[3]: ana,luis,sam\n"
      "hikes[3]{id,name,distanceKm,elevationGain,companion,wasSunny}:\n"
      "  1,Blue Lake Trail,7.5,320,ana,true\n"
      "  2,Ridge Overlook,9.2,540,luis,false\n"
      "  3,Wildflower Loop,5.1,180,sam,true\n";

  printf("Parsing Toon Source:\n%s\n", toon_source);

  ToonValue *root = toon_parse(toon_source);

  if (root) {
    printf("Parsed successfully!\n");
    toon_print(root, 0);
    toon_free(root);
  } else {
    printf("Failed to parse.\n");
  }

  return 0;
}

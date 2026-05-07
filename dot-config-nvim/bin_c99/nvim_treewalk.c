#include <dirent.h>
#include <fnmatch.h> // For pattern matching
#include <getopt.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define MAX_DEPTH 10 // Adjustable
#define MAX_PATH 1024

void walk_dir(const char *dir, int depth, const char *filter, int max_depth,
              int *first) {
  if (depth > max_depth)
    return;

  DIR *d = opendir(dir);
  if (!d) {
    perror("opendir");
    return;
  }

  struct dirent *entry;
  while ((entry = readdir(d))) {
    if (strcmp(entry->d_name, ".") == 0 || strcmp(entry->d_name, "..") == 0)
      continue;

    char path[MAX_PATH];
    snprintf(path, sizeof(path), "%s/%s", dir, entry->d_name);

    struct stat st;
    if (stat(path, &st) == -1)
      continue;

    if (filter && fnmatch(filter, entry->d_name, 0) != 0)
      continue; // Skip if no match

    if (*first) {
      *first = 0;
    } else {
      printf(",\n");
    }
    printf("{\"path\":\"%s\",\"size\":%ld,\"mtime\":%ld}", path, st.st_size,
           st.st_mtime);

    if (S_ISDIR(st.st_mode)) {
      walk_dir(path, depth + 1, filter, max_depth, first);
    }
  }
  closedir(d);
}

int main(int argc, char **argv) {
  char *dir = ".";
  char *filter = NULL;
  int max_depth = MAX_DEPTH;
  int json = 0;

  static struct option long_options[] = {{"filter", required_argument, 0, 'f'},
                                         {"depth", required_argument, 0, 'd'},
                                         {"json", no_argument, 0, 'j'},
                                         {0, 0, 0, 0}};

  int opt;
  while ((opt = getopt_long(argc, argv, "f:d:j", long_options, NULL)) != -1) {
    switch (opt) {
    case 'f':
      filter = optarg;
      break;
    case 'd':
      max_depth = atoi(optarg);
      break;
    case 'j':
      json = 1;
      break;
    default:
      fprintf(stderr, "Usage: %s [dir] --filter=pat --depth=N --json\n",
              argv[0]);
      exit(1);
    }
  }
  if (optind < argc)
    dir = argv[optind];

  if (json)
    printf("[\n");
  int first = 1;
  walk_dir(dir, 0, filter, max_depth, &first);
  if (json)
    printf("\n]\n");

  return 0;
}

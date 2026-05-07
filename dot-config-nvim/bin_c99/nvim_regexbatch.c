#include <dirent.h>
#include <getopt.h>
#include <pcre2.h> // Need libpcre2-dev
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>

#define MAX_PATH 1024
#define BUFFER_SIZE 4096

void process_file(const char *path, pcre2_code *re, const char *replace,
                  int dry_run) {
  FILE *f = fopen(path, dry_run ? "r" : "r+");
  if (!f) {
    perror("fopen");
    return;
  }

  char buf[BUFFER_SIZE];
  size_t len;
  int changes = 0;
  while ((len = fread(buf, 1, sizeof(buf), f)) > 0) {
    // Simple replace (expand for full PCRE2 matching)
    pcre2_match_data *match_data =
        pcre2_match_data_create_from_pattern(re, NULL);
    int rc = pcre2_match(re, (PCRE2_SPTR)buf, len, 0, 0, match_data, NULL);
    if (rc > 0) {
      changes++;
      // For demo, just print; in real, rewrite file
      if (!dry_run) {
        // Implement replace logic here (use pcre2_substitute)
        printf("Would replace in %s\n", path);
      } else {
        printf("Match in %s\n", path);
      }
    }
    pcre2_match_data_free(match_data);
  }
  fclose(f);
  if (changes)
    printf("%d changes in %s\n", changes, path);
}

void walk_and_process(const char *dir, pcre2_code *re, const char *replace,
                      int recursive, int dry_run) {
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

    if (S_ISREG(st.st_mode)) {
      process_file(path, re, replace, dry_run);
    } else if (recursive && S_ISDIR(st.st_mode)) {
      walk_and_process(path, re, replace, recursive, dry_run);
    }
  }
  closedir(d);
}

int main(int argc, char **argv) {
  char *dir = ".";
  char *pattern = NULL;
  char *replace = NULL;
  int recursive = 0;
  int dry_run = 0;

  static struct option long_options[] = {{"pattern", required_argument, 0, 'p'},
                                         {"replace", required_argument, 0, 'r'},
                                         {"recursive", no_argument, 0, 'R'},
                                         {"dry-run", no_argument, 0, 'd'},
                                         {0, 0, 0, 0}};

  int opt;
  while ((opt = getopt_long(argc, argv, "p:r:Rd", long_options, NULL)) != -1) {
    switch (opt) {
    case 'p':
      pattern = optarg;
      break;
    case 'r':
      replace = optarg;
      break;
    case 'R':
      recursive = 1;
      break;
    case 'd':
      dry_run = 1;
      break;
    default:
      fprintf(stderr,
              "Usage: %s [dir] --pattern=regex --replace=str [--recursive] "
              "[--dry-run]\n",
              argv[0]);
      exit(1);
    }
  }
  if (optind < argc)
    dir = argv[optind];
  if (!pattern || !replace) {
    fprintf(stderr, "Need pattern and replace\n");
    exit(1);
  }

  pcre2_code *re;
  PCRE2_SIZE erroffset;
  int errorcode;
  re = pcre2_compile((PCRE2_SPTR)pattern, PCRE2_ZERO_TERMINATED, 0, &errorcode,
                     &erroffset, NULL);
  if (!re) {
    fprintf(stderr, "Regex compile failed\n");
    exit(1);
  }

  walk_and_process(dir, re, replace, recursive, dry_run);

  pcre2_code_free(re);
  return 0;
}

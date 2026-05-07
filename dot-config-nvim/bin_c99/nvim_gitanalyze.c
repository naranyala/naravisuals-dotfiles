#include <getopt.h>
#include <git2.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  char *repo_dir = ".";
  char *file = NULL;
  int blame_mode = 1; // Default to blame
  int json = 1;       // Always JSON for plugin

  static struct option long_options[] = {{"file", required_argument, 0, 'f'},
                                         {"blame", no_argument, 0, 'b'},
                                         {"json", no_argument, 0, 'j'},
                                         {0, 0, 0, 0}};

  int opt;
  while ((opt = getopt_long(argc, argv, "f:bj", long_options, NULL)) != -1) {
    switch (opt) {
    case 'f':
      file = optarg;
      break;
    case 'b':
      blame_mode = 1;
      break;
    case 'j':
      json = 1;
      break;
    default:
      fprintf(stderr, "Usage: %s [repo-dir] --file=path --blame --json\n",
              argv[0]);
      exit(1);
    }
  }
  if (optind < argc)
    repo_dir = argv[optind];
  if (!file) {
    fprintf(stderr, "Need file\n");
    exit(1);
  }

  git_libgit2_init();
  git_repository *repo = NULL;
  if (git_repository_open(&repo, repo_dir) != 0) {
    fprintf(stderr, "Failed to open repo\n");
    exit(1);
  }

  git_blame_options blame_opts = GIT_BLAME_OPTIONS_INIT;
  git_blame *blame = NULL;
  if (git_blame_file(&blame, repo, file, &blame_opts) != 0) {
    fprintf(stderr, "Blame failed\n");
    exit(1);
  }

  printf("[\n");
  uint32_t count = git_blame_get_hunk_count(blame);
  for (uint32_t i = 0; i < count; i++) {
    const git_blame_hunk *hunk = git_blame_get_hunk_byindex(blame, i);
    printf("{\"line_start\":%ld,\"lines\":%ld,\"commit_id\":\"%s\",\"author\":"
           "\"%s\"}%s\n",
           hunk->final_start_line_number, hunk->lines_in_hunk,
           git_oid_tostr_s(&hunk->final_commit_id), hunk->final_signature->name,
           i < count - 1 ? "," : "");
  }
  printf("]\n");

  git_blame_free(blame);
  git_repository_free(repo);
  git_libgit2_shutdown();
  return 0;
}

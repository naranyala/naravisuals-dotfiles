
// build: cc git-digest.c -O2 -o git-digest
// git-digest : small git info helper using popen (no libgit)
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void run(const char *cmd) {
  char buf[8192];
  FILE *p = popen(cmd, "r");
  if (!p)
    return;
  while (fgets(buf, sizeof buf, p))
    fputs(buf, stdout);
  pclose(p);
}

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: git-digest <cmd> [args]\n");
    return 2;
  }
  if (strcmp(argv[1], "root") == 0) {
    run("git rev-parse --show-toplevel 2>/dev/null");
  } else if (strcmp(argv[1], "branch") == 0) {
    run("git rev-parse --abbrev-ref HEAD 2>/dev/null");
  } else if (strcmp(argv[1], "changed") == 0) {
    run("git status --porcelain 2>/dev/null | awk '{print $2}'");
  } else if (strcmp(argv[1], "diffstat") == 0) {
    run("git --no-pager diff --stat HEAD 2>/dev/null");
  } else if (strcmp(argv[1], "blame") == 0 && argc == 4) {
    // args: blame <file> <line>
    char cmd[1024];
    snprintf(cmd, sizeof cmd, "git --no-pager blame -L %s,%s -- %s 2>/dev/null",
             argv[3], argv[3], argv[2]);
    run(cmd);
  } else {
    fprintf(stderr, "unknown subcommand\n");
    return 3;
  }
  return 0;
}

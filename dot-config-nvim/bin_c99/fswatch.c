
// build: cc fswatch-c.c -O2 -o fswatch-c
// Linux only (inotify) simple watcher
#define _GNU_SOURCE
#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/inotify.h>
#include <unistd.h>

enum { BUF_LEN = 1024 * (sizeof(struct inotify_event) + NAME_MAX + 1) };

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: fswatch-c <path> [path2 ...]\n");
    return 2;
  }
  int fd = inotify_init1(IN_NONBLOCK);
  if (fd < 0) {
    perror("inotify_init");
    return 1;
  }

  for (int i = 1; i < argc; i++) {
    int wd = inotify_add_watch(fd, argv[i],
                               IN_CREATE | IN_MODIFY | IN_DELETE |
                                   IN_MOVED_FROM | IN_MOVED_TO | IN_ATTRIB);
    if (wd < 0)
      fprintf(stderr, "watch %s failed: %s\n", argv[i], strerror(errno));
  }

  char buf[BUF_LEN];
  while (1) {
    ssize_t len = read(fd, buf, sizeof buf);
    if (len <= 0) {
      usleep(100000);
      continue;
    }
    ssize_t i = 0;
    while (i < len) {
      struct inotify_event *ev = (struct inotify_event *)&buf[i];
      if (ev->len) {
        const char *etype = "UNKNOWN";
        if (ev->mask & IN_CREATE)
          etype = "CREATE";
        else if (ev->mask & IN_MODIFY)
          etype = "MODIFY";
        else if (ev->mask & IN_DELETE)
          etype = "DELETE";
        else if (ev->mask & IN_MOVED_FROM)
          etype = "MOVED_FROM";
        else if (ev->mask & IN_MOVED_TO)
          etype = "MOVED_TO";
        else if (ev->mask & IN_ATTRIB)
          etype = "ATTRIB";
        printf("%s\t%s\n", etype, ev->name);
        fflush(stdout);
      }
      i += sizeof(struct inotify_event) + ev->len;
    }
  }
  close(fd);
  return 0;
}

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/inotify.h>
#include <unistd.h>

#define EVENT_SIZE (sizeof(struct inotify_event))
// Buffer size for events. Set large enough for many concurrent file changes.
#define BUF_LEN (1024 * (EVENT_SIZE + 16))

// Example usage: ./fs_watcher <directory_to_watch>
int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <directory>\n", argv[0]);
    return 1;
  }
  const char *dir_path = argv[1];

  int fd = inotify_init();
  if (fd < 0) {
    perror("inotify_init failed");
    return 1;
  }

  // Watch for creates, deletes, and modifications
  int wd = inotify_add_watch(fd, dir_path,
                             IN_CREATE | IN_DELETE | IN_MODIFY | IN_MOVED_FROM |
                                 IN_MOVED_TO);
  if (wd < 0) {
    perror("inotify_add_watch failed");
    close(fd);
    return 1;
  }

  char buffer[BUF_LEN];

  // Main event loop - Runs indefinitely until killed by Neovim
  while (1) {
    // Blocks until an event occurs
    int length = read(fd, buffer, BUF_LEN);
    if (length < 0) {
      perror("read failed");
      break;
    }

    int i = 0;
    while (i < length) {
      struct inotify_event *event = (struct inotify_event *)&buffer[i];

      // Format the output for Neovim (TYPE | PATH)
      if (event->len) {
        // Determine the event type string
        const char *type_str = "UNKNOWN";
        if (event->mask & IN_CREATE)
          type_str = "CREATE";
        else if (event->mask & IN_DELETE)
          type_str = "DELETE";
        else if (event->mask & IN_MODIFY)
          type_str = "MODIFY";
        // Add logic for IN_ISDIR and MOVED events for robustness

        // Print the event to stdout. Neovim will read this asynchronously.
        // NOTE: Use fflush to ensure the output is immediately sent!
        printf("%s|%s/%s\n", type_str, dir_path, event->name);
        fflush(stdout);
      }
      i += EVENT_SIZE + event->len;
    }
  }

  inotify_rm_watch(fd, wd);
  close(fd);
  return 0;
}

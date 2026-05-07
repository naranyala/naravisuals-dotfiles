// c_clipboard.c
// Simple clipboard getter/setter with history (uses
// ~/.cache/c_clipboard_history) Usage: ./c_clipboard get
//        echo "text" | ./c_clipboard set

#include <X11/Xatom.h>
#include <X11/Xlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define HISTORY_FILE ".cache/c_clipboard_history"
#define MAX_HISTORY 10

void save_to_history(const char *text) {
  char path[512];
  snprintf(path, sizeof(path), "%s/%s", getenv("HOME"), HISTORY_FILE);
  // Ensure dir exists
  char dir[512];
  snprintf(dir, sizeof(dir), "%s/.cache", getenv("HOME"));
  mkdir(dir, 0700);

  FILE *fp = fopen(path, "r");
  char lines[1024][1024];
  int count = 0;
  if (fp) {
    while (count < MAX_HISTORY - 1 &&
           fgets(lines[count], sizeof(lines[0]), fp)) {
      // Remove trailing \n
      char *nl = strchr(lines[count], '\n');
      if (nl)
        *nl = '\0';
      count++;
    }
    fclose(fp);
  }

  // Write new entry at top
  fp = fopen(path, "w");
  if (!fp)
    return;
  fprintf(fp, "%s\n", text);
  for (int i = 0; i < count; i++) {
    fprintf(fp, "%s\n", lines[i]);
  }
  fclose(fp);
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s {get|set}\n", argv[0]);
    return 1;
  }

  Display *dpy = XOpenDisplay(NULL);
  if (!dpy) {
    fprintf(stderr, "Cannot open X display\n");
    return 1;
  }

  Window win =
      XCreateSimpleWindow(dpy, DefaultRootWindow(dpy), 0, 0, 1, 1, 0, 0, 0);
  Atom clipboard = XInternAtom(dpy, "CLIPBOARD", 0);
  Atom utf8 = XInternAtom(dpy, "UTF8_STRING", 0);
  Atom targets = XInternAtom(dpy, "TARGETS", 0);

  if (strcmp(argv[1], "get") == 0) {
    // Request clipboard
    XConvertSelection(dpy, clipboard, utf8, utf8, win, CurrentTime);
    XEvent ev;
    int timeout = 0;
    while (timeout++ < 1000) {
      if (XCheckTypedEvent(dpy, SelectionNotify, &ev)) {
        if (ev.xselection.property == utf8) {
          Atom type;
          int format;
          unsigned long nitems, after;
          unsigned char *data = NULL;
          XGetWindowProperty(dpy, win, utf8, 0, (~0L), 0, AnyPropertyType,
                             &type, &format, &nitems, &after, &data);
          if (data) {
            fwrite(data, 1, nitems, stdout);
            if (nitems == 0 || data[nitems - 1] != '\n')
              fputc('\n', stdout);
            save_to_history((char *)data);
            XFree(data);
          }
          break;
        }
      }
      usleep(1000); // 1ms
    }
  } else if (strcmp(argv[1], "set") == 0) {
    char *text = NULL;
    size_t len = 0;
    ssize_t read = getline(&text, &len, stdin);
    if (read != -1) {
      if (text[read - 1] == '\n')
        text[read - 1] = '\0';
      XStoreBytes(dpy, text, strlen(text));
      XSetSelectionOwner(dpy, clipboard, win, CurrentTime);
      save_to_history(text);
      free(text);
    }
  }

  XDestroyWindow(dpy, win);
  XCloseDisplay(dpy);
  return 0;
}

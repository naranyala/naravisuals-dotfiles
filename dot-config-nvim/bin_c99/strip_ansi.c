/* strip-ansi  (stdin → stdout)  removes every ANSI escape sequence */
#include <stdio.h>

int main(void) {
  int c, state = 0;
  while ((c = getchar()) != EOF) {
    if (state == 0 && c == '\x1b') {
      state = 1;
      continue;
    }
    if (state == 1) {
      if (c == '[') {
        state = 2;
        continue;
      }
      if (c == ']') {
        state = 3;
        continue;
      }
      state = 0;
      continue; /* 2-byte ESC sequence */
    }
    if (state == 2) { /* CSI */
      if ((c >= '0' && c <= '9') || c == ';')
        continue;
      state = 0;
      continue; /* final byte */
    }
    if (state == 3) { /* OSC */
      if (c == '\x07') {
        state = 0;
        continue;
      }
      if (c == '\x1b')
        state = 4;
      continue;
    }
    if (state == 4 && c == '\\') {
      state = 0;
      continue;
    }
    putchar(c);
  }
  return 0;
}

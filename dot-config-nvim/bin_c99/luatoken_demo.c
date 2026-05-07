
#include "luatoken.h"
#include <stdio.h>

int main() {
  const char *code = "local x = 10\n"
                     "function add(a, b)\n"
                     "  return a + b\n"
                     "end\n"
                     "-- comment test\n"
                     "if x then x = x + 1 end\n";

  ltok_state S;
  ltok_init(&S, code);

  while (1) {
    ltok_next(&S);
    if (S.tok.kind == LTOK_EOF)
      break;
    ltok_print(&S.tok);
  }
}

// c_transform.c
// Usage: echo "hello" | ./c_transform base64
//        echo "aGVsbG8K" | ./c_transform base64_decode

#define _POSIX_C_SOURCE 200809L
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

// Simple base64 decode (supports standard alphabet)
static const unsigned char base64_table[64] =
    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

void base64_encode(FILE *in, FILE *out) {
  unsigned char buf[3];
  int n;
  while ((n = fread(buf, 1, 3, in)) > 0) {
    unsigned char out_buf[4];
    out_buf[0] = base64_table[buf[0] >> 2];
    out_buf[1] = base64_table[((buf[0] & 0x03) << 4) | (buf[1] >> 4)];
    out_buf[2] =
        (n > 1) ? base64_table[((buf[1] & 0x0f) << 2) | (buf[2] >> 6)] : '=';
    out_buf[3] = (n > 2) ? base64_table[buf[2] & 0x3f] : '=';
    fwrite(out_buf, 1, 4, out);
    if (feof(in))
      break;
  }
  fputc('\n', out);
}

// Very basic base64 decode (no validation)
void base64_decode(FILE *in, FILE *out) {
  int ch, i = 0;
  unsigned char buf[4], out_buf[3];
  while ((ch = fgetc(in)) != EOF) {
    if (ch == '\n' || ch == '\r')
      continue;
    if (ch == '=') {
      buf[i++] = 0;
      continue;
    }
    const char *pos = strchr((char *)base64_table, ch);
    if (!pos)
      continue;
    buf[i++] = pos - (char *)base64_table;
    if (i == 4) {
      out_buf[0] = (buf[0] << 2) | (buf[1] >> 4);
      out_buf[1] = (buf[1] << 4) | (buf[2] >> 2);
      out_buf[2] = (buf[2] << 6) | buf[3];
      fwrite(out_buf, 1, (buf[2] == 64) ? 1 : (buf[3] == 64 ? 2 : 3), out);
      i = 0;
    }
  }
}

void toggle_case(FILE *in, FILE *out) {
  int c;
  while ((c = fgetc(in)) != EOF) {
    if (islower(c))
      fputc(toupper(c), out);
    else if (isupper(c))
      fputc(tolower(c), out);
    else
      fputc(c, out);
  }
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <op>\n", argv[0]);
    fprintf(stderr, "Operations: base64, base64_decode, togglecase\n");
    return 1;
  }

  const char *op = argv[1];
  if (strcmp(op, "base64") == 0) {
    base64_encode(stdin, stdout);
  } else if (strcmp(op, "base64_decode") == 0) {
    base64_decode(stdin, stdout);
  } else if (strcmp(op, "togglecase") == 0) {
    toggle_case(stdin, stdout);
  } else {
    fprintf(stderr, "Unknown operation: %s\n", op);
    return 1;
  }
  return 0;
}

// c_digest.c
// Usage: ./c_digest file.txt
// Output: {"path":"file.txt","hash":"a1b2c3...","changed":true}

#define _POSIX_C_SOURCE 200809L
#define XXH_INLINE_ALL
#include "xxhash.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

// Simple JSON string escape (for paths only)
void json_escape(const char *s) {
  putchar('"');
  for (; *s; s++) {
    if (*s == '"' || *s == '\\')
      putchar('\\');
    putchar(*s);
  }
  putchar('"');
}

// Read file and compute XXH3 64-bit hash
unsigned long long hash_file(const char *path) {
  int fd = open(path, O_RDONLY);
  if (fd == -1)
    return 0;

  struct stat st;
  if (fstat(fd, &st) != 0 || st.st_size == 0) {
    close(fd);
    return 0;
  }

  // Try to mmap (faster), fallback to read
  unsigned char *data = mmap(NULL, st.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
  unsigned long long hash;
  if (data == MAP_FAILED) {
    // Fallback: read into buffer
    unsigned char *buf = malloc(st.st_size);
    if (!buf || read(fd, buf, st.st_size) != st.st_size) {
      free(buf);
      close(fd);
      return 0;
    }
    hash = XXH3_64bits(buf, st.st_size);
    free(buf);
  } else {
    hash = XXH3_64bits(data, st.st_size);
    munmap(data, st.st_size);
  }
  close(fd);
  return hash;
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <file>\n", argv[0]);
    return 1;
  }

  const char *path = argv[1];
  unsigned long long hash = hash_file(path);
  if (hash == 0) {
    fprintf(stderr, "Cannot read file: %s\n", path);
    return 1;
  }

  // Output JSON
  printf("{");
  printf("\"path\":");
  json_escape(path);
  printf(",\"hash\":\"%016llx\"", hash);

  // Optional: check against cached hash (e.g., in /tmp/.c_digest.HASH)
  char cache_path[512];
  snprintf(cache_path, sizeof(cache_path), "/tmp/.c_digest.%016llx", hash);
  struct stat st;
  bool changed =
      (stat(cache_path, &st) != 0); // true if cache missing → changed

  if (!changed) {
    // Cache exists → file hasn't changed since last check
    // (You could also store last hash in a file per-path, but this is simpler)
  }
  printf(",\"changed\":%s}\n", changed ? "true" : "false");

  // Update cache
  close(open(cache_path, O_CREAT | O_WRONLY, 0600));

  return 0;
}

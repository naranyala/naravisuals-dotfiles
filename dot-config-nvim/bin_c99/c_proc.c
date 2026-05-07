// c_proc.c
// Usage: ./c_proc nvim
// Output: JSON lines of matching processes

#define _GNU_SOURCE
#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void json_str(const char *s) {
  putchar('"');
  for (; *s; s++) {
    if (*s == '"' || *s == '\\')
      putchar('\\');
    putchar(*s);
  }
  putchar('"');
}

int main(int argc, char *argv[]) {
  if (argc != 2) {
    fprintf(stderr, "Usage: %s <name>\n", argv[0]);
    return 1;
  }
  const char *target = argv[1];

  DIR *proc = opendir("/proc");
  if (!proc)
    return 1;

  struct dirent *entry;
  while ((entry = readdir(proc))) {
    if (!isdigit(entry->d_name[0]))
      continue;

    char stat_path[128];
    snprintf(stat_path, sizeof(stat_path), "/proc/%s/stat", entry->d_name);
    FILE *statf = fopen(stat_path, "r");
    if (!statf)
      continue;

    long pid, ppid;
    char comm[256], state;
    long vsize, rss;
    long utime, stime;

    // Parse /proc/PID/stat (fields 1-23)
    fscanf(statf,
           "%ld %255s %c %ld %*d %*d %*d %*d %*u %*u %*u %*u %*u %ld %ld %*d "
           "%*d %*d %*d %*d %*d %*d %*u",
           &pid, comm, &state, &ppid, &utime, &stime);
    fclose(statf);

    // Remove parentheses from comm
    size_t len = strlen(comm);
    if (len >= 2) {
      memmove(comm, comm + 1, len - 2);
      comm[len - 2] = '\0';
    }

    if (strstr(comm, target) == NULL)
      continue;

    // Read cmdline
    char cmdline_path[128];
    snprintf(cmdline_path, sizeof(cmdline_path), "/proc/%s/cmdline",
             entry->d_name);
    FILE *cmdf = fopen(cmdline_path, "r");
    char cmdline[1024] = "";
    if (cmdf) {
      size_t n = fread(cmdline, 1, sizeof(cmdline) - 1, cmdf);
      for (size_t i = 0; i < n; i++) {
        if (cmdline[i] == '\0')
          cmdline[i] = ' ';
      }
      if (n > 0 && cmdline[n - 1] == ' ')
        cmdline[n - 1] = '\0';
      fclose(cmdf);
    }

    // Basic CPU% = (utime + stime) / uptime → simplified
    double cpu = (utime + stime) / 100.0; // rough

    printf("{");
    printf("\"pid\":%ld,", pid);
    printf("\"cpu\":%.1f,", cpu);
    printf("\"mem_kb\":%ld,", rss * getpagesize() / 1024);
    printf("\"cmd\":");
    json_str(cmdline[0] ? cmdline : comm);
    printf("}\n");
  }
  closedir(proc);
  return 0;
}

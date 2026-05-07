
// build: cc taskd-lite.c -O2 -o taskd-lite
// taskd-lite: simple unix-socket task daemon
#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <sys/un.h>
#include <sys/wait.h>
#include <unistd.h>

const char *SOCK = "/tmp/taskd-lite.sock";
static int nextid = 1;

void handle_client(int client) {
  char buf[4096];
  ssize_t r = read(client, buf, sizeof buf - 1);
  if (r <= 0) {
    close(client);
    return;
  }
  buf[r] = 0;
  // trim
  char *cmd = buf;
  while (*cmd && (*cmd == '\n' || *cmd == '\r'))
    cmd++;
  if (strncmp(cmd, "ADD ", 4) == 0) {
    char *task = cmd + 4;
    int id = __sync_fetch_and_add(&nextid, 1);
    pid_t pid = fork();
    if (pid == 0) {
      // child
      char logfile[256];
      snprintf(logfile, sizeof logfile, "/tmp/taskd-%d.log", id);
      FILE *lf = fopen(logfile, "w");
      if (lf) {
        dup2(fileno(lf), STDOUT_FILENO);
        dup2(fileno(lf), STDERR_FILENO);
        fclose(lf);
      }
      // execute via /bin/sh -c
      execl("/bin/sh", "sh", "-c", task, (char *)NULL);
      _exit(127);
    } else if (pid > 0) {
      // parent: respond with id and pid
      char resp[128];
      snprintf(resp, sizeof resp, "OK %d %d\n", id, pid);
      write(client, resp, strlen(resp));
    } else {
      write(client, "ERR fork\n", 9);
    }
  } else if (strncmp(cmd, "STATUS", 6) == 0) {
    // very simple status: list /tmp/taskd-*.log existence and pid unknown
    // respond with filenames
    system("ls /tmp/taskd-*.log 2>/dev/null | sed -e 's/^/LOG /' > "
           "/tmp/taskd-list.tmp");
    FILE *f = fopen("/tmp/taskd-list.tmp", "r");
    if (!f) {
      write(client, "NONE\n", 5);
      close(client);
      return;
    }
    while (fgets(buf, sizeof buf, f))
      write(client, buf, strlen(buf));
    fclose(f);
  } else if (strncmp(cmd, "LOG ", 4) == 0) {
    char *idstr = cmd + 4;
    char logfile[256];
    int id = atoi(idstr);
    snprintf(logfile, sizeof logfile, "/tmp/taskd-%d.log", id);
    FILE *f = fopen(logfile, "r");
    if (!f) {
      write(client, "NOLOG\n", 6);
      close(client);
      return;
    }
    while (fgets(buf, sizeof buf, f))
      write(client, buf, strlen(buf));
    fclose(f);
  } else {
    write(client, "ERR unknown\n", 12);
  }
  close(client);
}

int main(int argc, char **argv) {
  unlink(SOCK);
  int s = socket(AF_UNIX, SOCK_STREAM, 0);
  if (s < 0) {
    perror("socket");
    return 1;
  }
  struct sockaddr_un addr;
  memset(&addr, 0, sizeof addr);
  addr.sun_family = AF_UNIX;
  strncpy(addr.sun_path, SOCK, sizeof addr.sun_path - 1);
  if (bind(s, (struct sockaddr *)&addr, sizeof addr) < 0) {
    perror("bind");
    return 1;
  }
  if (listen(s, 10) < 0) {
    perror("listen");
    return 1;
  }
  printf("taskd-lite listening on %s\n", SOCK);
  fflush(stdout);
  while (1) {
    int client = accept(s, NULL, NULL);
    if (client < 0)
      continue;
    pid_t pid = fork();
    if (pid == 0) {
      close(s);
      handle_client(client);
      _exit(0);
    } else if (pid > 0) {
      close(client);
      // reap children non-blocking
      while (waitpid(-1, NULL, WNOHANG) > 0) {
      }
    }
  }
  close(s);
  return 0;
}

/* project-scopes [STARTDIR]
   prints:  root<TAB>language */
#include <libgen.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
static const struct {
  const char *file;
  const char *lang;
} tbl[] = {{".git", "git"},
           {"compile_commands.json", "c/c++"},
           {"Cargo.toml", "rust"},
           {"package.json", "javascript"},
           {"go.mod", "go"},
           {"pyproject.toml", "python"},
           {NULL, NULL}};
int main(int argc, char **argv) {
  char cwd[4096];
  if (argc > 1)
    strncpy(cwd, argv[1], sizeof(cwd) - 1);
  else
    getcwd(cwd, sizeof(cwd));
  for (;;) {
    for (int i = 0; tbl[i].file; i++) {
      char tmp[4096];
      snprintf(tmp, sizeof(tmp), "%s/%s", cwd, tbl[i].file);
      if (!access(tmp, F_OK)) {
        printf("%s\t%s\n", cwd, tbl[i].lang);
        return 0;
      }
    }
    char *p = strrchr(cwd, '/');
    if (!p)
      break;
    *p = 0;
  }
  printf("%s\tunknown\n", cwd);
  return 0;
}

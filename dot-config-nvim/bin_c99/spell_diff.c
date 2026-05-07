/* spell-diff  OLD  NEW
   both files must contain one word per line (sorted uniq).
   prints words that are *new* and misspelled. */
#include <aspell.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char **argv) {
  if (argc != 3)
    return 1;
  AspellConfig *cfg = new_aspell_config();
  AspellCanHaveError *ret = new_aspell_speller(cfg);
  AspellSpeller *spl = 0;
  if (aspell_error(ret))
    return 2;
  spl = to_aspell_speller(ret);

  FILE *old = fopen(argv[1], "r"), *new = fopen(argv[2], "r");
  if (!old || !new)
    return 1;

  char o[64], n[64];
  int haso = fscanf(old, "%63s", o) == 1;
  int hasn = fscanf(new, "%63s", n) == 1;
  while (haso || hasn) {
    int cmp = haso && hasn ? strcmp(o, n) : (haso ? -1 : 1);
    if (cmp < 0)
      haso = fscanf(old, "%63s", o) == 1;
    else if (cmp > 0) {
      if (!aspell_speller_check(spl, n, -1))
        puts(n);
      hasn = fscanf(new, "%63s", n) == 1;
    } else { /* same word */
      haso = fscanf(old, "%63s", o) == 1;
      hasn = fscanf(new, "%63s", n) == 1;
    }
  }
  delete_aspell_speller(spl);
  delete_aspell_config(cfg);
  fclose(old);
  fclose(new);
  return 0;
}

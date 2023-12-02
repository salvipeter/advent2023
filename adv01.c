#include <stdbool.h>
#include <stdio.h>
#include <string.h>

// Returns -1 if `s` does not start with a digit
int digit(const char *s, bool string_digits) {
  static char *digits[] = { "zero", "one", "two", "three", "four",
                            "five", "six", "seven", "eight", "nine" };
  if (*s >= '0' && *s <= '9')
    return *s - '0';
  if (string_digits)
    for (int i = 0; i <= 9; i++)
      if (strncmp(s, digits[i], strlen(digits[i])) == 0)
        return i;
  return -1;
}

int main(int argc, char **argv) {
  int sum = 0;
  char line[100];
  FILE *f = fopen("adv01.txt", "r");
  while (true) {
    fgets(line, 100, f);
    if (feof(f))
      break;
    int first = -1, last;
    for (const char *s = line; *s; s++) {
      int d = digit(s, false); // true for part 2
      if (d >= 0) {
        if (first < 0)
          first = d;
        last = d;
      }
    }
    sum += first * 10 + last;
  }
  fclose(f);
  printf("%d\n", sum);
}

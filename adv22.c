#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Basic linked list intset implementation */

typedef struct Set {
  int n;
  struct Set *next;
} Set;

bool set_contains(Set *s, int n) {
  while (s) {
    if (s->n == n)
      return true;
    s = s->next;
  }
  return false;
}

Set *set_add(Set *s, int n) {
  if (set_contains(s, n))
    return s;
  Set *new = (Set *)malloc(sizeof(Set));
  new->n = n;
  new->next = s;
  return new;
}

int set_size(const Set *s) {
  int n = 0;
  while (s) {
    n++;
    s = s->next;
  }
  return n;
}

void set_free(Set *s) {
  while (s) {
    Set *tmp = s;
    s = s->next;
    free(tmp);
  }
}

/* Problem-specific code begins */

typedef struct {
  int a[3], b[3];
} Block;

int zless(const void *a, const void *b) {
  return ((Block *)a)->a[2] - ((Block *)b)->a[2];
}

bool above(const Block *a, const Block *b) {
  const int *aa = a->a, *ab = a->b, *ba = b->a, *bb = b->b;
  if (aa[0] == ab[0]) {
    if (ba[0] == bb[0]) {
      if (aa[0] != ba[0])
        return false;
      return ab[1] >= ba[1] && bb[1] >= aa[1];
    }
    return ba[0] <= aa[0] && aa[0] <= bb[0] && aa[1] <= ba[1] && ba[1] <= ab[1];
  }
  if (ba[1] == bb[1]) {
    if (aa[1] != ba[1])
      return false;
    return ab[0] >= ba[0] && bb[0] >= aa[0];
  }
  return ba[1] <= aa[1] && aa[1] <= bb[1] && aa[0] <= ba[0] && ba[0] <= ab[0];
}

void fall(Block *b, int z) {
  b->b[2] += z - b->a[2];
  b->a[2] = z;
}

int reaction(Set * const *chain, int n, int i) {
  Set *falling = set_add(NULL, i);
  bool changed;
  do {
    changed = false;
    for (int b = 0; b < n; ++b) {
      if (set_contains(falling, b))
        continue;
      bool supported = false;
      Set *s = chain[b];
      if (!s)
        continue;
      while (s) {
        if (!set_contains(falling, s->n)) {
          supported = true;
          break;
        }
        s = s->next;
      }
      if (!supported) {
        falling = set_add(falling, b);
        changed = true;
      }
    }
  } while(changed);
  int result = set_size(falling) - 1;
  set_free(falling);
  return result;
}

int main(void) {
  int n = 0;
  char line[100];
  FILE *f = fopen("adv22.txt", "r");
  while (true) {
    fgets(line, 100, f);
    if (feof(f))
      break;
    n++;
  }
  fclose(f);
  Block *blocks = (Block *)malloc(n * sizeof(Block));
  f = fopen("adv22.txt", "r");
  for (int i = 0; i < n; ++i) {
    fgets(line, 100, f);
    blocks[i].a[0] = atoi(strtok(line, ",~"));
    blocks[i].a[1] = atoi(strtok(NULL, ",~"));
    blocks[i].a[2] = atoi(strtok(NULL, ",~"));
    blocks[i].b[0] = atoi(strtok(NULL, ",~"));
    blocks[i].b[1] = atoi(strtok(NULL, ",~"));
    blocks[i].b[2] = atoi(strtok(NULL, ",~"));
  }
  fclose(f);
  qsort(blocks, n, sizeof(Block), zless);

  Set **chain = (Set **)malloc(n * sizeof(Set *));
  Set *unsafe = NULL;
  for (int i = 0; i < n; ++i) {
    Block *b = &blocks[i];
    int maxz = 0;
    Set *supports = NULL;
    for (int j = 0; j < i; ++j) {
      Block *s = &blocks[j];
      int z = s->b[2];
      if (z < maxz)
        continue;
      if (above(b, s)) {
        if (z == maxz)
          supports = set_add(supports, j);
        else {
          maxz = z;
          set_free(supports);
          supports = set_add(NULL, j);
        }
      }
    }
    if (supports && !supports->next)
      unsafe = set_add(unsafe, supports->n);
    chain[i] = supports;
    fall(b, maxz + 1);
  }
  printf("%d\n", n - set_size(unsafe));

  int sum = 0;
  for (int i = 0; i < n; ++i)
    sum += reaction(chain, n, i);
  printf("%d\n", sum);

  for (int i = 0; i < n; ++i)
    set_free(chain[i]);
  free(chain);
  set_free(unsafe);
  free(blocks);
}

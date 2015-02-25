#include <stdio.h>
#include <errno.h>

#define SYS_GETSTATE (323)

int main() {
  long process_state;

  if (syscall(SYS_GETSTATE, &process_state) == -1) {
    fprintf(stderr, "Error calling syscall: %s\n", strerror(errno));
    return -1;
  }

  fprintf(stderr, "gets here!\n");

  printf("new syscall sys_getstate set: %ld\n");
  return 0;
}

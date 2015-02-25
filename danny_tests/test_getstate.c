#include <stdio.h>
#include <errno.h>
#include <string.h>

#define SYS_GETSTATE_SYSCALL_TBL (323)
#define SYS_GETSTATE_UNISTD_DEF (380)

int main() {
  long process_state;

  if (syscall(SYS_GETSTATE_SYSCALL_TBL, &process_state) == -1) {
    fprintf(stderr, "Error calling syscall with %d: %s\n",
            SYS_GETSTATE_SYSCALL_TBL, strerror(errno));
  }

  if (syscall(SYS_GETSTATE_UNISTD_DEF, &process_state) == -1) {
    fprintf(stderr, "Error calling syscall with %d: %s\n",
            SYS_GETSTATE_UNISTD_DEF, strerror(errno));
  }

  printf("new syscall sys_getstate set: %ld\n");

  return 0;
}

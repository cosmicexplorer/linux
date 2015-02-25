#include <stdio.h>
#include <errno.h>
#include <string.h>

#define SYS_GETSTATE_SYSCALL_TBL (323)

int main() {
  long process_state;

  int retval = -1;

  if (syscall(SYS_GETSTATE_SYSCALL_TBL, &process_state) == -1) {
    fprintf(stderr, "Error calling syscall with %d: %s\n",
            SYS_GETSTATE_SYSCALL_TBL, strerror(errno));
  } else {
    printf("state: %ld\n", process_state);
    retval = 0;
  }

  return retval;
}

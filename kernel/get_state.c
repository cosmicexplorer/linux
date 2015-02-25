#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sched.h>
#include <linux/syscalls.h>

// asmlinkage long sys_getstate(long * state_ptr);

SYSCALL_DEFINE1(getstate, long __user *, state_ptr) {
  if (state_ptr == NULL) {
    return -EFAULT;
  }
  *state_ptr = current->state;
  return 0;
}

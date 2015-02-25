#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sched.h>
#include <linux/syscalls.h>

// asmlinkage long sys_getstate(long * state_ptr);

SYSCALL_DEFINE1(getstate, long __user *, state_ptr) {
  printk("no segfault here!\n");
  if (NULL == state_ptr) {
    return -EFAULT;
  }
  printk("no segfault here either!\n");
  *state_ptr = (long)current->state;
  printk("definitely no segfault here yo\n");
  return 0;
}

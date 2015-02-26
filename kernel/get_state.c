#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/sched.h>
#include <linux/syscalls.h>

// asmlinkage long sys_getstate(long * state_ptr);

SYSCALL_DEFINE1(getstate, long __user *, state_ptr)
{
	if (NULL == state_ptr) {
		return -EFAULT;
	}
	copy_to_user(state_ptr, current->state, sizeof(long));
	return 0;
}

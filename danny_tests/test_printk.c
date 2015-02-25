#include <stdio.h>
#include <unistd.h>

int main() {
  pid_t p;
  p = getpid();
  printf("hello, my pid is %d\n", p);
}

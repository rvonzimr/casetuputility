#define _GNU_SOURCE
#include <dlfcn.h>
#include <unistd.h>
#include <string.h>

static int (*real_chdir)(const char *path) = NULL;

int chdir(const char *path) {
  if (real_chdir == NULL) {
    real_chdir = dlsym(RTLD_NEXT, "chdir");
  }

  if (path && strstr(path, "/nix/store")) {
    return 0;
  }

  return real_chdir(path);
}

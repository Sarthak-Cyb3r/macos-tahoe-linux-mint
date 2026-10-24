#define _GNU_SOURCE
#include <dlfcn.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

__attribute__((constructor))
static void init_noglow(void) {
    void *fn = dlsym(RTLD_DEFAULT, "plank_dock_theme_draw_active_glow");
    if (!fn) {
        return;
    }

    long pagesize = sysconf(_SC_PAGESIZE);
    uintptr_t page_start = (uintptr_t)fn & ~(pagesize - 1);

    if (mprotect((void *)page_start, pagesize, PROT_READ | PROT_WRITE | PROT_EXEC) == 0) {
        *(unsigned char *)fn = 0xc3; // 'ret'
        mprotect((void *)page_start, pagesize, PROT_READ | PROT_EXEC);
    }
}

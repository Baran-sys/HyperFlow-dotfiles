#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

static ssize_t (*real_write)(int fd, const void *buf, size_t count) = NULL;

__attribute__((constructor))
static void init_waybar_hypr57_shim(void) {
    real_write = dlsym(RTLD_NEXT, "write");
    unsetenv("LD_PRELOAD");
}

ssize_t write(int fd, const void *buf, size_t count) {
    if (!real_write) {
        real_write = dlsym(RTLD_NEXT, "write");
    }
    if (buf && count >= 9 && count < 256) {
        const char *s = (const char *)buf;
        if (memcmp(s, "dispatch ", 9) == 0) {
            char cmd[256];
            memcpy(cmd, s, count);
            cmd[count] = '\0';
            while (count > 0 && (cmd[count - 1] == '\n' || cmd[count - 1] == '\r' || cmd[count - 1] == ' ')) {
                cmd[--count] = '\0';
            }

            char rewritten[512];
            int matched = 0;

            if (strncmp(cmd, "dispatch workspace ", 19) == 0) {
                const char *arg = cmd + 19;
                snprintf(rewritten, sizeof(rewritten),
                         "dispatch hl.dsp.focus({ workspace = tonumber(\"%s\") or \"%s\" })",
                         arg, arg);
                matched = 1;
            } else if (strncmp(cmd, "dispatch focusworkspaceoncurrentmonitor ", 40) == 0) {
                const char *arg = cmd + 40;
                snprintf(rewritten, sizeof(rewritten),
                         "dispatch hl.dsp.focus({ workspace = tonumber(\"%s\") or \"%s\" })",
                         arg, arg);
                matched = 1;
            } else if (strncmp(cmd, "dispatch togglespecialworkspace ", 32) == 0) {
                const char *arg = cmd + 32;
                snprintf(rewritten, sizeof(rewritten),
                         "dispatch hl.dsp.workspace.toggle_special(\"%s\")",
                         arg);
                matched = 1;
            } else if (strcmp(cmd, "dispatch togglespecialworkspace") == 0) {
                snprintf(rewritten, sizeof(rewritten),
                         "dispatch hl.dsp.workspace.toggle_special()");
                matched = 1;
            }

            if (matched) {
                ssize_t r = real_write(fd, rewritten, strlen(rewritten));
                return (r < 0) ? r : (ssize_t)count;
            }
        }
    }
    return real_write(fd, buf, count);
}

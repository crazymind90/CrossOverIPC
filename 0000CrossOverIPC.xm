


#include <dlfcn.h>
%ctor { dlopen("/var/jb/usr/lib/libCrossOverIPC.dylib", RTLD_LAZY); }
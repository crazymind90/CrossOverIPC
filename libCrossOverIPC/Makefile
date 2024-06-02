ARCHS = arm64e arm64

THEOS_PACKAGE_SCHEME=rootless

export SDKVERSION = 14.5

include $(THEOS)/makefiles/common.mk

export LIBRARY_NAME = libCrossOverIPC

libCrossOverIPC_FILES = libCrossOverIPC.mm ../PlistManager.m
libCrossOverIPC_CFLAGS = -Wno-objc-designated-initializers  
libCrossOverIPC_CODESIGN_FLAGS = -S../ent.plist
libCrossOverIPC_INSTALL_PATH = /usr/lib
libCrossOverIPC_CFLAGS += -DXINA_SUPPORT

include $(THEOS_MAKE_PATH)/library.mk

include $(THEOS_MAKE_PATH)/aggregate.mk




TARGET := iphone:clang:latest:7.0
INSTALL_TARGET_PROCESSES = WeChat

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = WeChatGlass

WeChatGlass_FILES = Tweak.xm
WeChatGlass_CFLAGS = -fobjc-arc
WeChatGlass_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

# The top-level application component is BlinkToRadioAppC
COMPONENT=projectAppC
# Energy of the antenna
CFLAGS += -DCC2420_DEF_RFPOWER=31
# Loads the TinyOS build system, which has all of the rules for building and installing on different platforms
include $(MAKERULES)

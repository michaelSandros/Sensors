# The top-level application component is BlinkToRadioAppC
COMPONENT=projectAppC
# Energy of the antenna
CFLAGS += -DCC2420_DEF_RFPOWER=31
# Loads the TinyOS build system
include $(MAKERULES)

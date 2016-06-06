#include <Timer.h>
#include "project.h"

configuration projectAppC
{
}

implementation
{
   components projectC as App;
   components MainC,LedsC;
   components UserButtonC;
   components new TimerMilliC() as Timer0;
   components ActiveMessageC;
   components new AMSenderC(AM_BLINKTORADIO);
   components new AMReceiverC(AM_BLINKTORADIO);

   App.Boot -> MainC;
   App.Leds -> LedsC;
   App.Timer0 -> Timer0;
   App.Packet -> AMSenderC;
   App.AMPacket -> AMSenderC;
   App.AMControl -> ActiveMessageC;
   App.AMSend -> AMSenderC	;
   App.Receive -> AMReceiverC;
}

#include <Timer.h>
#include "project.h"

module projectC @safe()
{
   uses interface Leds;
   uses interface Boot;
   uses interface Timer<TMilli> as Timer0;
   uses interface Packet;
   uses interface AMPacket;
   uses interface AMSend;
   uses interface Receive;
   uses interface SplitControl as AMControl;
}

implementation
{
   event void Boot.booted()
   {
       call AMControl.start();
   }

   event void Timer0.fired()
   {
   }

   event void AMControl.stopDone(error_t err)
   {
   }

   event void AMControl.startDone(error_t err)
   {
   }

   event void AMSend.sendDone(message_t* msg,error_t err)
   {
   }

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
   {
       return msg;
   }

}

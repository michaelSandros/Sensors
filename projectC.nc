#include <UserButton.h>
#include <Timer.h>
#include "project.h"

module projectC @safe()
{
   uses interface Leds;
   uses interface Boot;
   uses interface Get<button_state_t>;
   uses interface Notify<button_state_t>;
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
       // Per 1 second
       //call Timer0.startPeriodic(1024);
       call AMControl.start();
       call Notify.enable();
   }

   event void Timer0.fired()
   {
       call Leds.led1On();
       call Leds.led0Toggle();
   }

   event void Notify.notify(button_state_t state)
   {
       if(state == BUTTON_PRESSED)
       {
           call Leds.led0On();
       }
       else if(state == BUTTON_RELEASED)
       {
	   call Leds.led0Off();
       }
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

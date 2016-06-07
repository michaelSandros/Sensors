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
   uint16_t counter;
   message_t pkt;
   int counter1 = 0;
   int flag = 0;
   bool busy = FALSE;
   event void Boot.booted()
   {
       call AMControl.start();
       call Notify.enable();
   }

   event void Timer0.fired()
   {
       call Leds.led0Off();
       call Leds.led2Off();    
       if(!busy)
       {   
           Msg* rpkt = (Msg*)(call Packet.getPayload(&pkt,sizeof(Msg)));
	   if(rpkt == NULL)
	   {
	       return;
           }
           rpkt -> nodeid = TOS_NODE_ID;
           rpkt -> counter = counter;
           if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Msg)) ==  SUCCESS)
           {
               busy =  TRUE;
           }
       }
   }

   event void Notify.notify(button_state_t state)
   {
       if(state == BUTTON_RELEASED && counter1 > 0)
       {
       	   if(flag == 0)
           {
               flag = 1;
           }
           else if(flag == 1)
           {
               flag = 0;
               counter1 = 0;
           } 
       }
       if(state == BUTTON_RELEASED && flag == 0)
       {
           call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Msg));
           counter1++;
       }
   } 

   event void AMControl.stopDone(error_t err)
   {
   }

   event void AMControl.startDone(error_t err)
   {
       if (err == SUCCESS)
       {       
       }
       else
       {
	   call AMControl.start();
       }
   }

   event void AMSend.sendDone(message_t* msg,error_t err)
   {
       if(err == SUCCESS)
       {
           busy = FALSE;
       }
   }

   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
   {
       if (len == sizeof(Msg))
       {
	   if(flag == 0)
           {
               Msg* Rpkt = (Msg*)payload;
	       call Leds.led0On();
	       call Leds.led2On();
               // Per 1 second
               call Timer0.startOneShot(1024);
           }
       }
       return msg;
   }
}

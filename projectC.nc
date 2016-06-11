/**
 * Implementation of a Ping - Pong Application. When the user press the 
 * User Button of one of the motes, then the mote starts to transmit
 * a radio message. The packet is sent to all nodes in radio range by 
 * specyfing AM_BROADCAST_ADDR as the destination address.
 * When the other mote receives the radio message it's 
 * Led0 and Led3 turns on. After 1 second the leds are turning off and
 * the receiver turns into a transmitter. If the user press again the 
 * user button of any mote then the application pauses. After pausing, 
 * the application can resume again with the push of the user button.
 * As long as they are both within range of each other the LEDs on both
 * motes will keep changing. If the LEDs on both of the nodes stops 
 * changing and hold steady, then that node is no longer receiving any 
 * messages from the other node.
 * 
 * compile (example given for:Insert one node in each time for compilation):
 * make telosb install, 3 bsl,/dev/ttyUSB0 
 * make telosb reinstall, 6 bsl,/dev/ttyUSB0 
 *  
 * @author Sandros Michael
 * @author Sotiropoulou Efi
 * Univerity of Patras
 *
 * @date   June, 2016
 */

/** include libraries */
#include <UserButton.h>
#include <Timer.h>
#include "project.h"

/** @safe -> enforcing type and memory safety at run time on motes */
module projectC @safe()
{
	/** Module uses interfaces */
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
	/** busy is for the message buffer */
	bool busy = FALSE;
	/** flag = 1 means that there is a communication between the nodes
	 *  flag = 0 means there is no communication between the nodes */
	uint16_t flag = 0;
	/** packet variable */
	message_t pkt;

	/** System booted */
	event void Boot.booted()
	{
		/** Radio start */
		call AMControl.start();
		/** For button interrupts */
		call Notify.enable();
	}
	
	/** User button Interupt Handler */
	event void Notify.notify(button_state_t state)
	{
		/** When the user button is pressed  and the flag is 0 */
		if(state == BUTTON_PRESSED && flag == 0)
		{
			/** increment flag to 1 */
			flag++;
			/** start the timer for one time. The timer will start in 1sec */
            call Timer0.startOneShot(1024);
		}
		/** When the user button is pressed  and the flag is 0 */
		else if(state == BUTTON_PRESSED && flag == 1)
		{
			/** turn off leds 0 and 2 */
			call Leds.led0Off();
			call Leds.led2Off();
			/** flag  = 0 => pause the application */
			flag = 0;
			/** The message buffer can be reused - no transmission in progress */
			if(!busy)
			{
				/** Gets the packet's payload portion and casts it to a 
				 * pointer to the previously declared Msg external type */
				Msg* btrpkt = (Msg*)(call Packet.getPayload(&pkt,sizeof(Msg)));
				if(btrpkt == NULL)
				{
					return;
				}
				/** node id */
				btrpkt -> nodeid = TOS_NODE_ID;
				/** the flag value will be send to the other mote */
				btrpkt -> flag = flag;
				/** The test against SUCCESS verifies that the AM layer 
				 * accepted the message for transmission */
				if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Msg)) == SUCCESS)
				{
					/** the busy flag is set to true */
					busy = TRUE;
				}
			}
		}
	}

	event void Timer0.fired()
	{
		/** turn off leds 0 and 2 */
		call Leds.led0Off();
		call Leds.led2Off();
		/** The message buffer can be reused - no transmission in progress*/
		if(!busy)
		{
			/** Gets the packet's payload portion and casts it to a 
				 * pointer to the previously declared Msg external type */
			Msg* btrpkt = (Msg*)(call Packet.getPayload(&pkt,sizeof(Msg)));
			if(btrpkt == NULL)
			{
				return;
			}
			/** node id */
			btrpkt -> nodeid = TOS_NODE_ID;
			/** the flag value will be send to the other mote */
			btrpkt -> flag = flag;
			/** The test against SUCCESS verifies that the AM layer 
			 * accepted the message for transmission */ 
			if(call AMSend.send(AM_BROADCAST_ADDR,&pkt,sizeof(Msg)) == SUCCESS)
			{
				/** the busy flag is set to true */
				busy = TRUE;
			}
		}
	}
 
	event void AMControl.stopDone(error_t err)
	{
	}

	/** Check Radio */
	event void AMControl.startDone(error_t err)
	{
		/** Radio turned of succesfully */
		if(err == SUCCESS)
		{
		}
		/** Failed to turn the Radio turned on */
		else
		{
			/** Try again */
			call AMControl.start();
		}
	}

	/** This event is signaled after a message transmission attempt */
	event void AMSend.sendDone(message_t* msg,error_t err)
	{
		/** Ensure that the message buffer that was signaled is the same as the local message buffer */
		if(&pkt == msg)
		{
			/** Clears the busy flag to indicate that the message buffer can be reused */
			busy = FALSE;
		}
	}
	
	/** Message received event */
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
	{
		/** Ensures that the length of the message is what is expected */
		if(len == sizeof(Msg))
		{
				/** The message payload is cast to a structure pointer 
				 * of type Msg* and assigned to a local variable */
				Msg* btrpkt = (Msg*)payload;
				/** assign the to local variable flag the transmited 
				 * value from the other node */
				flag = btrpkt -> flag;
				/** if the flag is 1 then the application may continue */
				if(flag == 1)
				{
					/** turn on leds 0 and 2 */
					call Leds.led0On();
					call Leds.led2On();
					/** start the timer for one time. The timer will start in 1sec */
					call Timer0.startOneShot(1024);
				}
		}
		return msg;
	}
}

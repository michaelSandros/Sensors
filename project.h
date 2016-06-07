#ifndef PROJECT_H
#define PROJECT_H

enum
{
   AM_BLINKTORADIO = 6,
   TIMER_PERIOD_MILLI = 250
};

typedef nx_struct Msg
{
   nx_uint16_t nodeid;
   nx_uint16_t counter;
}Msg;

#endif

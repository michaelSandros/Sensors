#ifndef PROJECT_H
#define PROJECT_H

/** for constants */
enum
{
	AM_BLINKTORADIO = 6,
};

/** Message format to send data over the radio */
typedef nx_struct Msg
{
	nx_uint16_t nodeid;
	nx_uint16_t flag;
}Msg;

#endif

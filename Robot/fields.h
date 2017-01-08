#ifndef FIELDS_H
#define	FIELDS_H

// This file defines the Operator <-> Controller data transmission protocol.

// Message fields
#define MSG_NUM         0       // Message number
#define MSG_TYPE        1       // Message type
#define MSG_HIGH        2       // Data field
#define MSG_LOW         3       // Data field
// Message types
#define MSG_HELLO       1       // Say Hello
#define MSG_TEST        2       // Transmission check
#define MSG_POS_X       3       // Joystick position on X axis
#define MSG_POS_Y       4       // Joystick position on Y axis
#define MSG_POS_Z       5       // Joystick position on Z axis
#define MSG_OK          6       // Transmission confirmation
#define MSG_OK_TP       7       // Temperature and Pressure measurements
#define MSG_OK_LR       8       // Current (A) of Left and Right drives
#define MSG_OK_S        9       // Status message
#define MSG_OK_VV       11      // Voltage of Left and Right drives
#define MSG_JOY_BTN     12      // Joystick buttons status 
#define MSG_ERROR       10      // Error message
#define MSG_BYE         255     // Session ending
// Типы ошибок
#define MSG_ERR_UNKN    1       // Unknown type of error

#define STATUS_MCU      0       // Byte 1: There is no connection with MCU
#define STATUS_BATT     1       // Byte 2: Battery OK / Low

#endif	/* FIELDS_H */


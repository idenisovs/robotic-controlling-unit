#ifndef TH_FUNCTIONS_H
#define	TH_FUNCTIONS_H

// Mutexes
extern pthread_mutex_t mutex1;

// Variables:
extern int X;
extern int Y;
extern int Z;

extern unsigned char Press;
extern unsigned char Temper;

extern unsigned char LVolt;
extern unsigned char RVolt;
extern unsigned char LCurr;
extern unsigned char RCurr;

extern int Status;

// Threads:
void    * operator      (void * arg); // communication "daemon <- operator"
void    * chassis       (void * arg); // communication "демон -> chasis MCU"

// Functions
// Joystic coordinates to voltage on the drives
void    pos2volts       (int, int, int, float *, float *);
void    z_correction    (int, float *, float *);

// Byte operations
void    set_bit         (int *, short);
void    clr_bit         (int *, short);
void    xor_bit         (int *, short);

#endif


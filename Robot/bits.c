#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "th_functions.h"

unsigned char high (int word)
{
    return ((word & 0xFF00)>>8);
}
unsigned char low (int word)
{
    return (word & 0x00FF);
}

void set_bit (int *flags, short bit)
{
    *flags |= 1 << bit;
}

void clr_bit (int *flags, short bit)
{
    *flags &= ~(1 << bit);
}

void xor_bit (int *flags, short bit)
{
    *flags ^= 1 << bit;
}
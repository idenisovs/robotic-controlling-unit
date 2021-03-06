#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "th_functions.h"

void z_correction (int z, float *v_left, float *v_right)
{
    int max = 0xFFFF;
    max = max / 2;
    
    float Dev_Left = 0;
    float Dev_Right = 0;
    float Vz = (12/(float)max)*(float)z;
    Vz = abs (Vz);
    
    if (z >= 0)
    {      
        Dev_Left = (12 - *v_left)/12 * Vz;
        *v_left = *v_left + Dev_Left;
        
        Dev_Right = (12 + *v_right)/12 * Vz;
        *v_right = *v_right - Dev_Right;
    } else {
        Dev_Left = (12 + *v_left)/12 * Vz;
        *v_left = *v_left - Dev_Left;
        
        Dev_Right = (12 - *v_right)/12 * Vz;
        *v_right = *v_right + Dev_Right;        
    }
}

void pos2volts(int x, int y, int z, float * v_left, float * v_right)
{
    int max = 0xFFFF / 2;
    int Reverse;
    float R,V,alpha;
    
    Reverse = 1;
    
    x = x - max;                        // Переводим СК из абсолютной в 
    y = y - max;                        // декартову форму. 
    z = z - max;
       
    R = pow(x,2) + pow(y,2);            // Pithagorus
    R = sqrt(R);                        // Movement vector
    if (R > max)                        
        R = max;                        // Do not move outside from 12V.
    
    if (y < 0)
        Reverse = -1;
    
    alpha = atan2(x,y) * (180 / M_PI);  
    V = (R / max) * 12;                 // ADC->V convertation
    alpha = abs( alpha );               // Absolute value of movement angle.
    
    if (x >= 0)
    {
        *v_left = V * Reverse;
        *v_right = V * ((90-alpha) / 90);
    } else {
        *v_left = V * ((90-alpha) / 90);
        *v_right = V * Reverse;
    }
	
    // Z axis correction
    z_correction (z, v_left, v_right);
}
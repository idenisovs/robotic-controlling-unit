#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <math.h>
#include <sys/param.h>
#include "th_functions.h"
#include "fields.h"

// Прототипы функций:
void            chassis_term            ();

unsigned char   convert_temperature     (float temperature);
unsigned char   convert_pressure        (float pressure);
unsigned char   convert_current         (float current);
unsigned char   convert_voltage         (float voltage);

// Тред:        Шасси
// Функция:     Связь с МК шасси, передача комманд управления
//              и сбор данных датчиков МК.
void * chassis (void * arg)
{   
    pthread_setcancelstate      (PTHREAD_CANCEL_DISABLE, NULL);
    
    float LC, RC;               // Left and right drive Current (Ampers)
    float LV, RV;               // Left and right drive Voltage (Volts)   
    bool MCU_connected;         // MCU connection status
    bool Batt_low;              // Battery status
       
    pthread_cleanup_push        (chassis_term, NULL);    
    pthread_setcancelstate      (PTHREAD_CANCEL_ENABLE, NULL);
   
    MCU_connected       = true;
    Batt_low            = true;
    
    int i = 0;
    
    while ( 1 )
    {
        i++;

        if (MCU_connected == true)
        {
            Temper  = convert_temperature   (15);
            Press   = convert_pressure      (2);

            pos2volts(X, Y, Z, &LV, &RV);
            
            if (abs(LV) < 1)
                LV = 0;
            if (abs(RV) < 1)
                RV = 0;
                
            LVolt   = convert_voltage(LV);
            RVolt   = convert_voltage(RV);
                
            LC      = LV / 12 * 2;
            LC      = abs(LC);
            LCurr   = convert_current(LC);
    
            RC      = RV / 12 * 2; 
            RC      = abs(RC);
            RCurr   = convert_current(RC);
        }
        else
        {
            Temper      = 20;
            Press       = 10;
            LVolt       = 0;
            RVolt       = 0;
            LCurr       = 0;
            RCurr       = 0;
            Batt_low    = true;
        }
        
        pthread_mutex_lock(&mutex1);
        
        if (MCU_connected == true)
            set_bit(&Status, STATUS_MCU);
        else
            clr_bit(&Status, STATUS_MCU);
        
        if (Batt_low == true)
            set_bit(&Status, STATUS_BATT);
        else
            clr_bit(&Status, STATUS_BATT);
        
        pthread_mutex_unlock (&mutex1);
            
        usleep (500);
    }

    pthread_cleanup_pop (1);   
    pthread_exit(EXIT_SUCCESS);
}

// Тред:        Шасси.
// Функция:     Завершение треда "шасси".
void chassis_term()
{
    printf ("Chassis thread shutdowned!\n");
}

unsigned char convert_temperature(float temperature)
{
    return (temperature+20)/60.0 * 255;
}
unsigned char convert_pressure(float pressure)
{
    return (pressure+10)/110.0 * 255;
}
unsigned char convert_current (float current)
{
    return current / 2.0 * 255;
}
unsigned char convert_voltage (float voltage)
{
    return (voltage+12) / 24.0 * 255;
}



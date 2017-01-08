#ifndef TH_FUNCTIONS_H
#define	TH_FUNCTIONS_H

// Мьютексы:
extern pthread_mutex_t mutex1;

// Переменные:
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

// Треды:
void    * operator      (void * arg); // связь "демон <- станция оператора"
void    * chassis       (void * arg); // связь "демон -> контроллер шасси"

// Функции
// Перевод координат джойстика в напряжение на обмотках мотора
void    pos2volts       (int, int, int, float *, float *);
void    z_correction    (int, float *, float *);
// Операции с битами статусной переменной
void    set_bit         (int *, short);         // установка
void    clr_bit         (int *, short);         // очистка
void    xor_bit         (int *, short);         // переключение

#endif


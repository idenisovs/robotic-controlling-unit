#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include "th_functions.h"
#include "fields.h"

// Глобальные переменные:
int X,Y,Z,Status;
unsigned char Press, Temper, LVolt, RVolt, LCurr, RCurr;

// Мьютексы:
pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;

// Прототипы функций:
void     msg_protocol    (int size, char * recv, char * send);

// Треды:
void    * operator      (void * arg); // связь "демон <- станция оператора"
void    * chassis       (void * arg); // связь "демон -> контроллер шасси"

int main(int argc, char * argv[])
{
    printf ("Main: Start!\n");
    
    // Глобальные переменные
    Status = 0; X = 0; Y = 0; Z = 0;
    
    // Потоки
    pthread_t   ptr_oper;       // Указатель на поток "Оператор".
    pthread_t   ptr_chassis;    // Указатель на поток "Шасси".
    
    // Локальные переменные.
    int         result  = 0;    // Результат выполнения операции.
    int         id1     = 1;    // Идентификатор потока.
    int         id2     = 2;
    int         sig     = 0;    // Номер полученного сигнала.
    
    // Сигнальные переменные.
    sigset_t sset;
    
    // Установка параметров списка сигналов.
    sigemptyset         (&sset);
    sigaddset           (&sset, SIGTERM);
    pthread_sigmask     (SIG_BLOCK, &sset, NULL);
   
    // Запуск тредов:
    // Тред "оператор".
    printf ("Operator: Operator thread!\n");
    result = pthread_create (&ptr_oper, NULL, operator, &id1);
    if (result != 0) {
        perror ("Creating the operator thread!");
        return (EXIT_FAILURE);
    }   
    // Тред "шасси".
    printf ("Chassis: Chassis thread!\n");
    result = pthread_create (&ptr_chassis, NULL, chassis, &id2);
    if (result != 0) {
        perror ("Creating the Chassis thread!");
        return (EXIT_FAILURE);
    }
     
    // Ожидание сигнала.
    sigwait(&sset, &sig);
    
    // Завершение работы.
    pthread_cancel (ptr_oper);
    pthread_cancel (ptr_chassis);
    
    result = pthread_join(ptr_oper, NULL); 
    if (result != 0) {
        perror ("Joining the operator thread!");
        return (EXIT_FAILURE);
    }    
    result = pthread_join(ptr_chassis, NULL); 
    if (result != 0) {
        perror ("Joining the chassis thread!");
        return (EXIT_FAILURE);
    }
    
    printf ("Done!\n");
    return (EXIT_SUCCESS);
}
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <pthread.h>
#include <signal.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <resolv.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include "th_functions.h"
#include "fields.h"

// Глобальные переменные:
int sd1;
int client;

// Прототипы функций:
void    op_protocol     (int size, unsigned char * recv, unsigned char * send);
void    op_term         ();

// Тред:        Оператор
// Функция:     Связь с станцией оператора, приём и обработка поступающих
//              комманд, пересылка собранных данных.
void * operator (void * arg)
{
    pthread_setcancelstate      (PTHREAD_CANCEL_DISABLE, NULL);
    pthread_cleanup_push        (op_term, NULL);
    
                sd1     = 0;
    int         size    = 0;
    int         result  = 0;

    struct      sockaddr_in addr;
    
    size                 = sizeof(addr);
    bzero (&addr, sizeof(addr));
    addr.sin_family      = AF_INET;
    addr.sin_port        = htons (4002);
    addr.sin_addr.s_addr = INADDR_ANY;
    
    // Инициализация сокета TCP/IP.
    sd1 = socket (AF_INET, SOCK_STREAM, 0);
    printf ("Operator: Socket initialized!\n");    
    
    // Занимаем порт #4002.
    result = bind (sd1, (struct sockaddr *)&addr, size);
    if (result != 0)
        perror ("Bind AF_INET!"); 
    // Начинаем прослушивать заданный сокет.
    result = listen (sd1, 10);
    if (result != 0)
        perror ("Listen!"); 
    // Разрешаем завершение треда извне. 
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
    
    // Ожидание подключений.
    while ( 1 )
    {
        int clientsd = 0;
        
        clientsd = accept (sd1, (struct sockaddr *)&addr, (socklen_t *)&size);
        if (clientsd > 0)
        {
            printf ("Connection!\n");            
            client = clientsd;
            
            int nbytes;
            
            int  buff_size = 4;
            unsigned char buff_rcv [buff_size];
            unsigned char buff_snd [buff_size];
            bzero (&buff_rcv, 4);
            bzero (&buff_snd, 4);
            
            buff_snd[MSG_NUM]   = 1;
            buff_snd[MSG_TYPE]  = MSG_HELLO;
            buff_snd[MSG_HIGH]  = 255;
            buff_snd[MSG_LOW]   = 0;
            
            send (clientsd, buff_snd, buff_size, 0);
            
            do
            {
                bzero (&buff_rcv, 4);
                nbytes = recv (clientsd, buff_rcv, buff_size, 0);
                op_protocol (buff_size, buff_rcv, buff_snd);
                send (clientsd, buff_snd, buff_size, 0);             
            }
            while 
            (buff_rcv[MSG_TYPE] != MSG_BYE);

            close (clientsd);
            printf ("Disconnected!\n");
        }
        else
            perror ("Accept!");
    }
    
    pthread_cleanup_pop (1);   
    pthread_exit(EXIT_SUCCESS);
}
// Тред:        Оператор.
// Функция:     Обработка входящих комманд, формирование и загрузка
//              ответной информации в буффер исходящего сообщения.
void op_protocol (int size, unsigned char * recv, unsigned char * send)
{
    int data = 0;
    char * msg_t;
    
    data = (recv[MSG_HIGH] << 8) | (recv[MSG_LOW] << 0);
        
    switch (recv[MSG_TYPE])
    {
        case MSG_HELLO:
            msg_t = "MSG_HELLO";
            send[MSG_TYPE] = MSG_TEST;
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = 1;
            send[MSG_LOW]  = 1;
            break;
        case MSG_TEST:
            msg_t = "MSG_TEST";
            send[MSG_TYPE] = MSG_HELLO;
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = 170;
            send[MSG_LOW]  = 170;
            break;
        case MSG_POS_X:
            msg_t = "MSG_POS_X";                // Данные датчиков давления и 
            send[MSG_TYPE] = MSG_OK_TP;         // температуры. 
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = Temper;            // Температура
            send[MSG_LOW]  = Press;             // Давление            
            X = data;
            
            break;
        case MSG_POS_Y:
            msg_t = "MSG_POS_Y";                // Передача силы тока левого
            send[MSG_TYPE] = MSG_OK_LR;         // и правого двигателей.
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = LCurr;
            send[MSG_LOW]  = RCurr;
            Y = data;
            break;
        case MSG_JOY_BTN:                       // Передача напряжения
            msg_t = "MSG_JOY_BTN";              // на левом и правом
            send[MSG_TYPE] = MSG_OK_VV;         // двигателях.
            send[MSG_HIGH] = LVolt;
            send[MSG_LOW]  = RVolt;
            break;
        case MSG_POS_Z:                         // Передача статусного
            msg_t = "MSG_POS_Z";                // сообщения.
            send[MSG_TYPE] = MSG_OK_S;
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = high(Status);
            send[MSG_LOW]  = low (Status);
            Z = data;
            break;
        case MSG_BYE:
            msg_t = "MSG_BYE";
            send[MSG_TYPE] = MSG_BYE;
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = 'G';
            send[MSG_LOW]  = 'L';
            break;
        default:
            msg_t = "Unknown";                  
            send[MSG_TYPE] = MSG_ERROR;
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = MSG_ERR_UNKN;
            send[MSG_LOW]  = recv[MSG_NUM];
    }
    printf ("%-10.9s %-10.9s %-10.9s %-10.9s %-10.9s\n", 
            "Num",
            "Type", 
            "High", 
            "Low", 
            "Data");
    printf ("%-10.1i %-10.9s %-10.1i %-10.1i %-10.1i\n", 
            recv[MSG_NUM],
            msg_t, 
            recv[MSG_HIGH], 
            recv[MSG_LOW], 
            data);
    
}

// Тред:        Оператор.
// Функция:     Завершение треда "оператор".
void op_term()
{
    if (client > 0)
    {
        unsigned char remdata [4];
        remdata[MSG_NUM]        = 255;
        remdata[MSG_TYPE]       = MSG_BYE;
        remdata[MSG_HIGH]       = 'g';
        remdata[MSG_LOW]        = 'l';
        
        send (client, remdata, sizeof(remdata), 0);
        
        close (client);
        printf ("Client disconnected!\n");
    }
    if (sd1 != 0)
    {
        close (sd1);
        printf ("Socket closed!\n");
    }
    printf ("Operator thread shutdowned!\n");
}


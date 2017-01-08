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

// Global variables
int sd1;
int client;

// Function prototypes
void    op_protocol     (int size, unsigned char * recv, unsigned char * send);
void    op_term         ();

// This thread provides the communication between robotic controlling unit and operator station.
// As also, it parses and process the received data.
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
    
    // Init the TCP/IP socket
    sd1 = socket (AF_INET, SOCK_STREAM, 0);
    printf ("Operator: Socket initialized!\n");    
    
    // Takes the 4002 port
    result = bind (sd1, (struct sockaddr *)&addr, size);
    if (result != 0)
        perror ("Bind AF_INET!"); 
    // Listening to the socket.
    result = listen (sd1, 10);
    if (result != 0)
        perror ("Listen!"); 
    // Allow to listen this thread from outside
    pthread_setcancelstate(PTHREAD_CANCEL_ENABLE, NULL);
    
    // Awaiting for connections
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

// Incoming command processing and response loading to the responding message buffer.
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
            msg_t = "MSG_POS_X";                // Measurement values 
            send[MSG_TYPE] = MSG_OK_TP;         // of press and temp sensors
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = Temper;            // Temperature
            send[MSG_LOW]  = Press;             // Pressure         
            X = data;
            
            break;
        case MSG_POS_Y:
            msg_t = "MSG_POS_Y";                // Current values of left
            send[MSG_TYPE] = MSG_OK_LR;         // and right drives
            send[MSG_NUM]  = recv[MSG_NUM]+1;
            send[MSG_HIGH] = LCurr;
            send[MSG_LOW]  = RCurr;
            Y = data;
            break;
        case MSG_JOY_BTN:                       // Voltage values 
            msg_t = "MSG_JOY_BTN";              // of left and right
            send[MSG_TYPE] = MSG_OK_VV;         // drives
            send[MSG_HIGH] = LVolt;
            send[MSG_LOW]  = RVolt;
            break;
        case MSG_POS_Z:                         // Status message
            msg_t = "MSG_POS_Z";
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

// Stopping the Operator thread
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


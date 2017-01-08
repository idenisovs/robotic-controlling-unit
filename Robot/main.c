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

// Global variables (Yes, I know, that is bad practice)
int X,Y,Z,Status;
unsigned char Press, Temper, LVolt, RVolt, LCurr, RCurr;

// Mutexes:
pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;

// Function prototypes:
void     msg_protocol    (int size, char * recv, char * send);

// Threads:
void    * operator      (void * arg); // Provides the connection between daemon and operator station.
void    * chassis       (void * arg); // Provides the connection between daemon and MCU

int main(int argc, char * argv[])
{
    printf ("Main: Start!\n");
    
    // Global varibles
    Status = 0; X = 0; Y = 0; Z = 0;
    
    // Thread pointers
    pthread_t   ptr_oper;       // Operator thread pointer.
    pthread_t   ptr_chassis;    // Chassis thread pointer.
    
    // Local variables
    int         result  = 0;    // Operation result
    int         id1     = 1;    // Thread identifier
    int         id2     = 2;
    int         sig     = 0;    // Number of received signal
    
    // Signal variables
    sigset_t sset;
    
    // Setup of signals list
    sigemptyset         (&sset);
    sigaddset           (&sset, SIGTERM);
    pthread_sigmask     (SIG_BLOCK, &sset, NULL);
   
    // Launching threads
    // Operator thread here:
    printf ("Operator: Operator thread!\n");
    result = pthread_create (&ptr_oper, NULL, operator, &id1);
    if (result != 0) {
        perror ("Creating the operator thread!");
        return (EXIT_FAILURE);
    }
	
    // Chasis thread here:
    printf ("Chassis: Chassis thread!\n");
    result = pthread_create (&ptr_chassis, NULL, chassis, &id2);
    if (result != 0) {
        perror ("Creating the Chassis thread!");
        return (EXIT_FAILURE);
    }
     
    // Waiting for signal
    sigwait(&sset, &sig);
    
    // Stopping work after signal is received
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
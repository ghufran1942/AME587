//    Filename: Project
//    Instructor:
//    Group: 3
//    Date: 3/23/2023

#include <xc.h>     // header file
#include <math.h>   // header file
#include <stdlib.h>
#include <pic16f690.h>

#define _XTAL_FREQ 8000000

#pragma config FOSC = INTRCIO, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, CPD = OFF, BOREN = OFF, IESO = OFF, FCMEN = OFF

//Function Declarations
float US_distance();

int main()  // Start of the main function
{
    //    Initialization
    OSCCON = 0b01110000;    // Setting Oscillator to do 8MHz
    TRISAbits.TRISA0 = 0;   // PORTA0 as output
    TRISBbits.TRISB4 = 1;   // PORTB4 as input
    T1CONbits.TMR1ON = 1;   // Enable Timer1
    return 0;
    
    while(1){
        US_distance();
    }
}

float US_distance()
{
    // Signal Initialization
    TRISAbits.TRISA0 = 1;
    __delay_us = 10;
    TRISAbits.TRISA0 = 0;
    
    // Start counting
    
    while (PORTBbits.RB4 == 0);  // Wait for the echo pulse to start
    TMR1 = 0;                   // Reset the timer
    while (PORTBbits.RB4 == 1);  // Wait for the echo pulse to end
    unsigned short duration = TMR1;   // Read the timer value

    return duration * 0.034 / 2;
}

//int Initialization()
//{
//    OSCCON = 0b01110000;    // Setting Oscillator to do 8MHz
//    TRISAbits.TRISA0 = 0;   // PORTA0 as output
//    TRISBbits.TRISB4 = 1;   // PORTB4 as input
//    T1CONbits.TMR1ON = 1;   // Enable Timer1
//    return 0;
//}
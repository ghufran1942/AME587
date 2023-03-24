//    Filename: Project
//    Instructor:
//    Group: 3
//    Date: 3/23/2023

#include <xc.h>     // header file
#include <pic16f690.h>

#define _XTAL_FREQ 8000000

#pragma config FOSC = INTRCIO, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, CPD = OFF, BOREN = OFF, IESO = OFF, FCMEN = OFF

//Function Declarations
float US_distance();
void Send(unsigned char x);
unsigned char Receive(void);

int main()  // Start of the main function
{
    //    Initialization
    OSCCON = 0b01110000;    // Setting Oscillator to do 8MHz
    TRISAbits.TRISA0 = 0;   // PORTA0 as output => Trigger
    TRISBbits.TRISB4 = 1;   // PORTB4 as input => 
    T1CONbits.TMR1ON = 1;   // Enable Timer1
    TRMT = 1;               // Empty Transmit Shift register
    BRGH = 1;               // set Baud Rate high
    SYNC = 0;               // Asynchronous mode
    TXEN = 1;               // Enable transmission
    BRG16 = 0;              // Set Baud Rate Generator to 8bit. 1 for 16
    SPBRG = 25;             // Set baud rate timer period
    PORTC = 0;
    
    while(1){
        float distance = US_distance();
        Send(distance);
        PORTC = Receive();
    }
    return 0;
}

float US_distance()
{
    // Signal Initialization
    TRISAbits.TRISA0 = 1;
    __delay_us(10);
    TRISAbits.TRISA0 = 0;
    
    // Start counting
    
    while (PORTBbits.RB4 == 0);     // Wait for the echo pulse to start
    TMR1 = 0;                       // Reset the timer
    while (PORTBbits.RB4 == 1);     // Wait for the echo pulse to end
    unsigned short duration = TMR1; // Read the timer value

    return duration * 0.034 / 2;
}

void Send(unsigned char x)      // Send 1 Byte to MATLAB via RS232
{
    TXREG = x;                  // Move Byte to Transmit Data Register
    SPEN = 1;                   // Enable Continuous Send (RCSTA reg)
    while (!TRMT);              // Wait until TXREG is empty (TXSTA reg)
}

unsigned char Receive(void)     // Receive 1 Byte from MATLAB via RS232
{
    CREN = 1;                   // Enable Asynchronous Receiver (RCSTA reg)
    while (!RCIF);              // Wait for RCREG to fill (PIR1 reg)
    return RCREG;               // Move Receive Data Register to func output  
} 

//    Filename: TASK15
//    Instructor:
//    Group: 3
//    Date:3/6/2023

#include <xc.h>
#include <math.h>
#include <pic16f690.h>

#define _XTAL_FREQ 8000000

#pragma config FOSC = INTRCIO, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, CPD = OFF, BOREN = OFF, IESO = OFF, FCMEN = OFF

unsigned char inp    = 0b00000000;       // Global declaration for sending byte
unsigned char data   = 0b00000000;       // Global declaration for receiving byte
unsigned char datret = 0b00000000;       // Global declaration for receiving byte

// forward declarations of functions
void Send(unsigned char x);
unsigned char Receive(void);
int Initialization(void);

void main(void)  // Start of the main function
{
    Initialization();
    PORTC = 0;
    CCPR1L = 0;
//    Receive();
    while (1) {
        __delay_us(20);
        GO = 1;                     // Begin AD Conversion
        while(GO);          // Wait for ADC to complete
        Send(ADRESL);                  // Send ADRESL to MATLAB via RS232
        Send(ADRESH);                  // Send ADRESH to MATLAB via RS232
        //Toggle LED/motor 1
        CCPR1L = Receive();
    }
    
}  // End of the main function

void Send(unsigned char x)            // Send 1 Byte to MATLAB via RS232
{
    TXREG = x;                      // Move Byte to Transmit Data Register
    SPEN = 1;                       // Enable Continuous Send (RCSTA reg)
    while (!TRMT);           // Wait until TXREG is empty (TXSTA reg)
} 

unsigned char Receive(void)                   // Receive 1 Byte from MATLAB via RS232
{
    CREN = 1;                       // Enable Asynchronous Receiver (RCSTA reg)
    while (!RCIF);           // Wait for RCREG to fill (PIR1 reg)
    data = RCREG;                   // Move Receive Data Register to func output
    return RCREG;
} 


int Initialization()
{
    // BANK3
    PSTRCON = 0b00010011;           //PA & PB = PWM; PC & PD = port pins; steering update at beginning
    
    // BANK2
    ANSEL  = 0b00000001;            // All pins digital except pin AN0
    ANSELH = 0b00000000;            // All pins digital
    
    // BANK1
    OSCCON = 0b01110000;            // Setting Oscillator to do 8MHz
    ADCON1 = 0b01010000;            // Select ADC Clock to FOSC/16
    TRISA  = 0b00000001;            // Input: pin AN0
    TRISC  = 0b00000000;            // Output: all pins
    //TXSTA bits
    TRMT = 1;                       // Empty Transmit Shift register
    BRGH = 1;                       // set Baud Rate high
    SYNC = 0;                       // Asynchronous mode
    TXEN = 1;                       // Enable transmission
    BRG16 = 0;                      // Set Baud Rate Generator to 8bit. 1 for 16
    SPBRG = 25;                     // Set baud rate timer period
    
    // BANK0
    //ADCON0
    ADON = 1;                       // Enable ADC conversion
    GO = 0;                         // Stop any conversion
    //ADC to AN0
    CHS0 = 0;
    CHS1 = 0;
    CHS2 = 0;
    CHS3 = 0;
    ADFM = 0;                       // Left Justify ADRESH ADRESL
    //CCP1CON; P1A-D all active high, PWM cycle least sig bits, PWM half bridge
    CCP1CON = 0b10001100;
    PR2 = 255;
    CCPR1L = 0b00000000;
    T2CON = 0b01111110;
    return 0;
}
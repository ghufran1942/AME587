//    Filename: Project
//    Instructor:
//    Group: 3
//    Date: 3/23/2023

#include <xc.h>
#include <pic16f690.h>

#define _XTAL_FREQ 8000000

#pragma config FOSC = INTRCIO, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, CPD = OFF, BOREN = OFF, IESO = OFF, FCMEN = OFF

// Global variable
volatile unsigned short timer0_overflow_count = 0;

// Function Declarations
float measure_distance();
void Send(unsigned char x);
unsigned char Receive(void);
void __interrupt() ISR(void);

int main()
{
    // Initialization
    ANSEL = 0b00000000;         // All pins digital
    ANSELH = 0b00000000;        // All pins digital

    OSCCON = 0b01110000;        // Setting Oscillator to 8 MHz
    TRISAbits.TRISA0 = 0;       // PORTA0 as output => Trigger
    TRISBbits.TRISB4 = 1;       // PORTB4 as input => Echo

    // Timer1 configuration (for measuring echo pulse duration)
    T1CONbits.T1CKPS = 0b11;    // Set Timer1 prescaler to 1:8
    T1CONbits.TMR1CS = 0;       // Select internal clock (FOSC/4)
    T1CONbits.TMR1ON = 0;       // Disable Timer1 (it will be enabled in the US_distance function)

    // Timer0 configuration (for handling timeout)
    OPTION_REGbits.PSA = 0;     // Assign prescaler to Timer0
    OPTION_REGbits.PS = 0b010;  // Set the prescaler to 1:8
    OPTION_REGbits.T0CS = 0;    // Select internal instruction cycle clock
    OPTION_REGbits.T0SE = 0;    // Increment on low-to-high transition on T0CKI pin
    TMR0 = 0;                   // Initialize Timer0 value

    // Enable Timer0 overflow interrupt
    INTCONbits.T0IE = 1;        // Enable Timer0 overflow interrupt
    INTCONbits.GIE = 1;         // Enable global interrupts

    // UART Configuration
    TRMT = 1;                   // Empty Transmit Shift register
    BRGH = 1;                   // Set Baud Rate high
    SYNC = 0;                   // Asynchronous mode
    TXEN = 1;                   // Enable transmission
    BRG16 = 0;                  // Set Baud Rate Generator to 8bit. 1 for 16
    SPBRG = 25;                 // Set baud rate timer period
    PORTC = 0;
    
    __delay_ms(100);                // Wait for serial communication to stabilize
    
    while(1)
    {
        __delay_us(20);

        float distance = measure_distance();
        char *bytes = (char*)(&distance);
        for(int i=0; i < 4;i++)
        {
            Send(bytes[i]);
        }

        PORTC = Receive();
    }
    return 0;
}

float measure_distance()
{
    // Signal Initialization
    RA0 = 1;
    __delay_us(10);
    RA0 = 0;

    TMR1 = 0;                   // Reset Timer1
    T1CONbits.TMR1ON = 1;       // Enable Timer1

    // Start counting
    timer0_overflow_count = 0;  // Reset the overflow count
    TMR0 = 0;                   // Reset Timer0 value

    while (PORTBbits.RB4 == 0 && timer0_overflow_count < 10) {} // Wait for the echo pulse to start

    if (timer0_overflow_count >= 10) {
        T1CONbits.TMR1ON = 0;   // Disable Timer1
        return 0;               // If timed out, return 0
    }

    TMR1 = 0;                   // Reset the timer

    while (PORTBbits.RB4 == 1 && timer0_overflow_count < 10) {} // Wait for the echo pulse to end

    T1CONbits.TMR1ON = 0;       // Disable Timer1

    if (timer0_overflow_count >= 10) return 0; // If timed out, return 0

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

void __interrupt() ISR(void)
{
    if (INTCONbits.T0IF)        // Check if Timer0 overflow interrupt occurred
    {
        timer0_overflow_count++;// Increment the overflow count
        TMR0 = 0;               // Reset Timer0 value
        INTCONbits.T0IF = 0;    // Clear the Timer0 overflow interrupt flag
    }
}


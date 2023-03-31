//    Filename: Project
//    Instructor:
//    Group: 3
//    Date: 3/23/2023

#include <xc.h>
#include <pic16f690.h>
#include <stdint.h>

#define _XTAL_FREQ 8000000

#pragma config FOSC = INTRCIO, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, CPD = OFF, BOREN = OFF, IESO = OFF, FCMEN = OFF

volatile uint8_t timer0_overflow_count = 0;

//Function Declarations
unsigned short measure_duration();
float calculate_distance(uint16_t duration);
void Send(unsigned char x);
unsigned char Receive(void);

int main()  // Start of the main function
{
    // Initialization
    ANSEL = 0b00000000;             // All pins digital
    ANSELH = 0b00000000;            // All pins digital

    OSCCON = 0b01110000;            // Setting Oscillator to 8MHz
    TRISAbits.TRISA0 = 0;           // PORTA0 as output => Trigger
    TRISBbits.TRISB4 = 1;           // PORTB4 as input => Echo
    
    T1CONbits.TMR1CS = 0;       // Select internal clock (FOSC/4)
    T1CONbits.TMR1ON = 0;       // Disable Timer1 (it will be enabled in the US_distance function)
    
    OPTION_REGbits.PSA = 0;     // Assign prescaler to Timer0
    OPTION_REGbits.PS0 = 0;
    OPTION_REGbits.PS1 = 1;
    OPTION_REGbits.PS2 = 0;
    OPTION_REGbits.T0CS = 0;    // Select internal instruction cycle clock
    OPTION_REGbits.T0SE = 0;    // Increment on low-to-high transition on T0CKI pin
    TMR0 = 0;
    
    // Set up UART
    TRISCbits.TRISC6 = 1;           // Set TX pin as input
    TRISCbits.TRISC7 = 1;           // Set RX pin as input
    TXSTAbits.BRGH = 1;             // Set Baud Rate high
    TXSTAbits.SYNC = 0;             // Asynchronous mode
    TXSTAbits.TXEN = 1;             // Enable transmission
    BRG16 = 0;                      // Set Baud Rate Generator to 8bit. 1 for 16
    SPBRG = 25;                     // Set baud rate timer period
    RCSTAbits.SPEN = 1;             // Enable serial port
    RCSTAbits.CREN = 1;             // Enable receiver

    __delay_ms(100);                // Wait for serial communication to stabilize
    
    uint16_t prev_duration = -1;
    while(1){
        __delay_us(20);

        uint16_t curr_duration = measure_duration();
        
        if (prev_duration != -1){ // Only compare if there is a valid previous value
            uint8_t range = 0.1 * prev_duration; // depending on the constant 0.1 the range changes.
            uint16_t lower_bound = prev_duration - range;
            uint16_t upper_bound = prev_duration + range;
            if (curr_duration >= lower_bound && curr_duration <= upper_bound) {
                curr_duration = 10;
            }else{
                prev_duration = curr_duration; // Store the current duration value as the previous duration value for the next iteration
            }
        }       
        float distance = calculate_distance(curr_duration);
        
        char *bytes = (char*)(&distance);
        for(int i=0; i < 4;i++)
        {
            Send(bytes[i]);
        }

        PORTC = Receive();
    }
    return 0;
}

unsigned short measure_duration()
{
    // Signal Initialization
    RA0 = 1;
    __delay_us(10);
    RA0 = 0;

    TMR0 = 0;
    // Start counting

    while (PORTBbits.RB4 == 0);     // Wait for the echo pulse to start
    while (PORTBbits.RB4 == 1);     // Wait for the echo pulse to end
    unsigned short duration = TMR0; // Read the timer value

    return duration;
}

void Send(unsigned char x)          // Send 1 Byte to MATLAB via RS232
{
    TXREG = x;                      // Move Byte to Transmit Data Register
    while (!TRMT);                  // Wait until TXREG is empty (TXSTA reg)
}

unsigned char Receive(void)         // Receive 1 Byte from MATLAB via RS232
{
    while (!RCIF);                  // Wait for RCREG to fill (PIR1 reg)
    return RCREG;                   // Move Receive Data Register to func output  
}

float calculate_distance(uint16_t curr_duration){
    float distance = curr_duration * 0.0135 / 2; // I think this should calculate the distance in inches
    return distance;
}



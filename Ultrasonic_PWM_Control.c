//    Filename: Class Project
//    Instructor: Prof. Eniko T. Enikov
//    Group: 3
//    Date: 3/23/2023

#include <xc.h>
#include <math.h>
#include <pic16f690.h>
#include <stdint.h>

#define _XTAL_FREQ 8000000

#pragma config FOSC = INTRCIO, WDTE = OFF, PWRTE = OFF, MCLRE = ON, CP = OFF, CPD = OFF, BOREN = OFF, IESO = OFF, FCMEN = OFF

// Global variable
volatile uint8_t timer0_overflow_count = 0;

// Function Declarations
int initialization();
float measure_duration();
void Send(unsigned char x);
unsigned char Receive(void);
void __interrupt() ISR(void); 

int main(){
    initialization();
//    PORTC = 0;

    __delay_ms(100);
    
    while (1) {
        __delay_us(20);

        float curr_duration = measure_duration();
        char *bytes = (char*)(&curr_duration);
        for(int i=0; i < 4;i++){
            Send(bytes[i]);
        }
        //Toggle motor 1
        CCPR1L = Receive();
        CCP1CON = 0b01001100;
        RC5 = 1; // Enable motor 1
        __delay_us(1000); // Let motor 1 be active for 1/2 second
        RC5 = 0; // Disable motor 1
        
        //Toggle motor 2
//        CCPR1L = Receive();
        CCP1CON = 0b11001100;
        RC4 = 1; // Enable motor 2
        __delay_us(1000); // Let motor 2 be active for 1/2 second
        RC4 = 0; // Disable motor 2
        CCPR1L = 0; // Clear CCPR1L
    }
    return 0;
}
float measure_duration(){
    // Signal Initialization
    RA0 = 1;
    __delay_us(10);
    RA0 = 0;

    TMR1 = 0;                   // Reset Timer1
    T1CONbits.TMR1ON = 1;       // Enable Timer1

    // Start counting
    timer0_overflow_count = 0;  // Reset the overflow count
    TMR0 = 0;                   // Reset Timer0 value

    while (PORTBbits.RB4 == 0 && timer0_overflow_count < 20) {} // Wait for the echo pulse to start

    if (timer0_overflow_count >= 20) {
        T1CONbits.TMR1ON = 0;   // Disable Timer1
        return 0;               // If timed out, return 0
    }

    TMR1 = 0;                   // Reset the timer

    while (PORTBbits.RB4 == 1 && timer0_overflow_count < 20) {} // Wait for the echo pulse to end

    T1CONbits.TMR1ON = 0;       // Disable Timer1

    if (timer0_overflow_count >= 20) return 0; // If timed out, return 0

    unsigned short duration = TMR1; // Read the timer value

    // return duration * 0.034 / 2;
    return duration;
}

void Send(unsigned char x){            // Send 1 Byte to MATLAB via RS232

    TXREG = x;                      // Move Byte to Transmit Data Register
    SPEN = 1;                       // Enable Continuous Send (RCSTA reg)
    while (!TRMT);           // Wait until TXREG is empty (TXSTA reg)
} 

unsigned char Receive(void){                   // Receive 1 Byte from MATLAB via RS232

    CREN = 1;                       // Enable Asynchronous Receiver (RCSTA reg)
    while (!RCIF);           // Wait for RCREG to fill (PIR1 reg)
    return RCREG;
} 

void __interrupt() ISR(void){
    if (INTCONbits.T0IF)        // Check if Timer0 overflow interrupt occurred
    {
        timer0_overflow_count++;// Increment the overflow count
        TMR0 = 0;               // Reset Timer0 value
        INTCONbits.T0IF = 0;    // Clear the Timer0 overflow interrupt flag
    }
}

int initialization(){
    // BANK3
    PSTRCON = 0b00010011;           //PA & PB = PWM; PC & PD = port pins; steering update at beginning
    
    // BANK2
    ANSEL  = 0b00000000;            // All pins digital except pin AN0
    ANSELH = 0b00000000;            // All pins digital
    
    // BANK1
    OSCCON = 0b01110000;            // Setting Oscillator to do 8MHz
//    ADCON1 = 0b01010000;            // Select ADC Clock to FOSC/16
    TRISA = 0b00000100;            // Input: pin AN0 pin A2 as digital input
    TRISB = 0b00010000;             // Input: RB4
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
//    ADON = 1;                       // Enable ADC conversion
//    GO = 0;                         // Stop any conversion

    //ADC to AN0
//    CHS0 = 0;
//    CHS1 = 0;
//    CHS2 = 0;
//    CHS3 = 0;
//    ADFM = 0;                       // Left Justify ADRESH ADRESL
    //CCP1CON; P1A-D all active high, PWM cycle least sig bits, PWM half bridge
    CCP1CON = 0b10001100;
    PR2 = 255;
    CCPR1L = 0b00000000;
    //T2CON = 0b01111110;

    // Timer1 configuration (for measuring echo pulse duration)
    T1CONbits.TMR1CS = 0;       // Select internal clock (FOSC/4)
    T1CONbits.TMR1ON = 0;       // Disable Timer1 

    // Timer0 configuration (for handling timeout)
    OPTION_REGbits.PSA = 0;     // Assign prescaler to Timer0
    OPTION_REGbits.PS = 0b010;  // Set the prescaler to 1:8
    OPTION_REGbits.T0CS = 0;    // Select internal instruction cycle clock
    OPTION_REGbits.T0SE = 0;    // Increment on low-to-high transition on T0CKI pin
    TMR0 = 0;
    
    RA1 = 1;    //Enable Direction for MTR 1
    RA2 = 0;    //Enable Direction for MTR 1
    
    RA5 = 0;    //Enable Direction for MTR 2
    RA4 = 1;    //Enable Direction for MTR 2
    
    return 0;
}

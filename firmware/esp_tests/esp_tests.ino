/*
  ledcWrite_RGB.ino
  Runs through the full 255 color spectrum for an rgb led 
  Demonstrate ledcWrite functionality for driving leds with PWM on ESP32
 
  This example code is in the public domain.
  
  Some basic modifications were made by vseven, mostly commenting.
 */
 
// Set up the rgb led names
uint8_t ledR = 23;
uint8_t ledG = 22;
uint8_t ledB = 21; 

uint8_t ledArray[3] = {1, 2, 3}; // three led channels

const boolean invert = true; // set true if common anode, false if common cathode

uint8_t color = 0;          // a value from 0 to 255 representing the hue
uint32_t R, G, B;           // the Red Green and Blue color components
uint8_t brightness = 255;  // 255 is maximum brightness, but can be changed.  Might need 256 for common anode to fully turn off.

// the setup routine runs once when you press reset:
void setup() 
{            
  Serial.begin(115200);
  delay(10); 
  
  ledcAttachPin(ledR, 1); // assign RGB led pins to channels
  ledcAttachPin(ledG, 2);
  ledcAttachPin(ledB, 3);
  
  // Initialize channels 
  // channels 0-15, resolution 1-16 bits, freq limits depend on resolution
  // ledcSetup(uint8_t channel, uint32_t freq, uint8_t resolution_bits);
  ledcSetup(1, 12000, 8); // 12 kHz PWM, 8-bit resolution
  ledcSetup(2, 12000, 8);
  ledcSetup(3, 12000, 8);
}

// void loop runs over and over again
void loop() 
{
  Serial.println("Send all LEDs a 255 and wait 2 seconds.");
  // If your RGB LED turns off instead of on here you should check if the LED is common anode or cathode.
  // If it doesn't fully turn off and is common anode try using 256.
  ledcWrite(1, 255);
  ledcWrite(2, 0);
  ledcWrite(3, 0);
 
}

/* JoystickProcessingBasicExample.pde
  
  Prints values of joystick shield inputs to console


  NOTE: This is a sketch for the Processing language and won't
        compile in the Arduino IDE.

  
  Requires:
  
    * 'StandardFirmata' sketch needs to be uploaded to the Arduino
      (Found in File > Examples > Firmata > StandardFirmata in the Arduino IDE)

    * The Arduino library needs to be installed for Processing from:

         <http://www.arduino.cc/playground/Interfacing/Processing>
   
    * Written for Processing IDE v2.2.1 and below. May not run for Processing 3
    
         <https://processing.org/download/>
    
  Written for SparkFun Arduino Inventor's Kit CIRC-JOY

 */

// Import classes required to communicate with the Arduino
import processing.serial.*;
import cc.arduino.*;

Arduino arduino;


// Store the Arduino pin associated with each input
final int PIN_BUTTON_SELECT = 2; // Select button is triggered when joystick is pressed

final int PIN_BUTTON_RIGHT = 3;
final int PIN_BUTTON_UP = 4;
final int PIN_BUTTON_DOWN = 5;
final int PIN_BUTTON_LEFT = 6;

final int PIN_ANALOG_X = 0;
final int PIN_ANALOG_Y = 1;


void setup() {

  // Prints a list to the console of all the serial devices 
  // connected to the computer
  println(Arduino.list());
  
  // We assume that the Arduino is the first device in the list,
  // if it's not the first device you need to change the '0'.
  arduino = new Arduino(this, Arduino.list()[4], 57600);


  // Specify each pin connected to a pushbutton as an input.
  // Also enable the Arduino's internal "pull-up" resistors
  // for each pushbutton we want to read--this means the shield
  // doesn't need to have resistors on it.
  // Note that when a pull-up resistor is used on a pin the
  // meaning of the values read are reversed compared to their
  // usual meanings:
  //    * HIGH = the button is not pressed
  //    * LOW = the button is pressed  
  arduino.pinMode(PIN_BUTTON_RIGHT, Arduino.INPUT);  
  arduino.digitalWrite(PIN_BUTTON_RIGHT, Arduino.HIGH);
  
  arduino.pinMode(PIN_BUTTON_LEFT, Arduino.INPUT);  
  arduino.digitalWrite(PIN_BUTTON_LEFT, Arduino.HIGH);
  
  arduino.pinMode(PIN_BUTTON_UP, Arduino.INPUT);  
  arduino.digitalWrite(PIN_BUTTON_UP, Arduino.HIGH);
  
  arduino.pinMode(PIN_BUTTON_DOWN, Arduino.INPUT);  
  arduino.digitalWrite(PIN_BUTTON_DOWN, Arduino.HIGH);
  
  arduino.pinMode(PIN_BUTTON_SELECT, Arduino.INPUT);  
  arduino.digitalWrite(PIN_BUTTON_SELECT, Arduino.HIGH);

}

void draw() {
  // Print the current values of the inputs (joystick and
  // buttons) to the console.
  // Note: It will take several seconds before the readings are valid
  //       because of the time it takes for Processing to establish
  //       the connection with the Arduino.
  println("l:" + arduino.digitalRead(PIN_BUTTON_LEFT) + " " +
          "r:" + arduino.digitalRead(PIN_BUTTON_RIGHT) + " " +
          "u:" + arduino.digitalRead(PIN_BUTTON_UP) + " " +          
          "d:" + arduino.digitalRead(PIN_BUTTON_DOWN) + " " +
          "x:" + arduino.analogRead(PIN_ANALOG_X) + " " +
          "y:" + arduino.analogRead(PIN_ANALOG_Y) + " " +
          "s:" + arduino.digitalRead(PIN_BUTTON_SELECT)
          );
}

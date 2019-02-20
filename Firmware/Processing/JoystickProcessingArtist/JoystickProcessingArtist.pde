/*JoystickProcessingArtist.pde
  
  A simple drawing program to demonstrate joystick control


  NOTE: This is a sketch for the Processing language and won't
        compile in the Arduino IDE.

  
  How to use:
  
    * Use the joystick to control on-screen "pen"
    * Left/Right buttons decrease/increase line color brightness
    * Up/Down buttons change line color hue
    * Select (pressing on the joystick) makes the line thicker
    * Pressing Left & Right buttons together saves a snapshot of the drawing
      in the sketch folder
  
  Requires:
  
    * 'StandardFirmata' sketch needs to be uploaded to the Arduino
      (Found in File > Examples > Firmata > StandardFirmata in the Arduino IDE)

    * The Arduino library needs to be installed for Processing from:

         <http://www.arduino.cc/playground/Interfacing/Processing>
         
    * Written for Processing IDE v2.2.1 and below. May not run for Processing 3
    
         <https://processing.org/download/>

  Written for SparkFun Arduino Inventor's Kit CIRC-JOY

 */

// There are a number of methods you can choose to use to determine the relationship
// between the position of the joystick and the position of the drawing point on
// the screen. Change POSITION_METHOD to be equal to 0, 1, 2 or 3 to try out the
// different variations.
// See the comments in the code below to find out how each method works.
final int POSITION_METHOD = 0;

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

// Store list of button pins which need pull-up resistors activated
int[] BUTTON_PINS = {PIN_BUTTON_SELECT,
                     PIN_BUTTON_LEFT, PIN_BUTTON_RIGHT,
                     PIN_BUTTON_UP, PIN_BUTTON_DOWN};


// Dimensions in pixels of drawing area
final int WINDOW_WIDTH = 400;
final int WINDOW_HEIGHT = 400;

// Store the maximum possible values of the X & Y co-ordinates.
// Because the first pixel in each dimension is 0 the maximum value is one
// less than the actual width or height.
final int MAX_X = WINDOW_WIDTH - 1;
final int MAX_Y = WINDOW_HEIGHT - 1;


// Set initial "pen" colour hue and brightness
int current_hue = 30;
int current_bright = 50;

// Set the initial pen location to the centre of the window.
int draw_x = WINDOW_WIDTH/2;
int draw_y = WINDOW_HEIGHT/2;


// It takes several seconds before the input readings are valid
// because of the time it takes for Processing to establish
// the connection with the Arduino. We don't want to draw anything
// until we know the input readings are valid so we use this variable
// to track if the connection to the Arduino is ready and providing valid
// readings.
boolean arduinoIsReady = false;


void setup() {
  // Set the drawing window size
  size(WINDOW_WIDTH, WINDOW_HEIGHT);

  // We will specify colors as Hue, Saturation and Brightness (HSB) values.
  // The maximum value will be 100%.
  colorMode(HSB, 100);
  
  // Set the background color as white
  background(color(0, 0, 100));
  

  // Prints a list to the console of all the serial devices 
  // connected to the computer
  println(Arduino.list());
  
  // We assume that the Arduino is the first device in the list,
  // if it's not the first device you need to change the '0'.  
  arduino = new Arduino(this, Arduino.list()[4], 57600);


  // Loop over the array of pushbutton pins and specify each as an input
  // and enable the pin's "pull-up" resistor--this means the shield
  // doesn't need to have resistors on it.
  // We use a loop to avoid repeating the pinMode/digitalWrite code.
  // Note that when a pull-up resistor is used on a pin the
  // meaning of the values read are reversed compared to their
  // usual meanings:
  //    * HIGH = the button is not pressed
  //    * LOW = the button is pressed    
  for (int index = 0 ; index < BUTTON_PINS.length; index++) {
    arduino.pinMode(BUTTON_PINS[index], Arduino.INPUT);  
    arduino.digitalWrite(BUTTON_PINS[index], Arduino.HIGH);
  }

}


void draw() {
  // Note: It seems to take a few seconds before the joystick reading is accurate.
  //       I think this is due to the bootloader and other delays in receiving
  //       a response from Firmata. 
  //       A semi-reliable method for determining if we've got a real response
  //       from Firmata is to check the joystick returns a non-zero position in
  //       each axis. Obviously this fails if the joystick is positioned fully down
  //       and left when we start--so don't do that. :)
  //       We don't draw anything until we determine that we've got a real response.
  //       If we calibrated the centre point first we might increase reliability.
  if (!arduinoIsReady) {
    if (!((arduino.analogRead(PIN_ANALOG_X) == 0) && (arduino.analogRead(PIN_ANALOG_Y) == 0))) {
      arduinoIsReady = true;
    } else {
      return;
    }
  }


  // Change the current hue based on the state of the up and down buttons.
  if (arduino.digitalRead(PIN_BUTTON_UP) == arduino.LOW) {
    current_hue++;
  }
 
  if (arduino.digitalRead(PIN_BUTTON_DOWN) == arduino.LOW) {
    current_hue--;      
  }
  
  current_hue = constrain(current_hue, 0, 100);


  // We take a screenshot when both the left and right buttons are pressed. 
  if ((arduino.digitalRead(PIN_BUTTON_RIGHT) == arduino.LOW) &&
      (arduino.digitalRead(PIN_BUTTON_LEFT) == arduino.LOW)) {
        // Note there is little delay between screenshots.
        saveFrame("joystick-drawing-####.png");
  }
  

  // Change the current brightness based on the state of the left and right buttons
  if (arduino.digitalRead(PIN_BUTTON_RIGHT) == arduino.LOW) {
    current_bright++;
  }
 
  if (arduino.digitalRead(PIN_BUTTON_LEFT) == arduino.LOW) {
    current_bright--;      
  }
  
  current_bright = constrain(current_bright, 0, 100);

  fill(color(current_hue, 100, current_bright));
  stroke(color(current_hue, 100, current_bright));


  // Use one of four methods of mapping the current joystick position to 
  // a location on screen.
  if (POSITION_METHOD == 0) {

    // This method is "non-proportional" and makes the joystick act as if
    // is only a simple digital 8-way joystick instead of an analog joystick.
    // This means movement is restricted to a combination of up or down and
    // left or right and not moving.
    // It treats an area in the centre of the joystick's movement as being
    // "centered" and this is determined by the threshold values. This approach
    // avoids the position "wandering" if the joystick is slighty off-centre. 
    int value = arduino.analogRead(PIN_ANALOG_X);  
    
    final int X_THRESHOLD_LOW = 505;
    final int X_THRESHOLD_HIGH = 515;    
    
    final int Y_THRESHOLD_LOW = 500;
    final int Y_THRESHOLD_HIGH = 510;    
    
    if (value > X_THRESHOLD_HIGH) {
      draw_x++;
    } else if (value  < X_THRESHOLD_LOW) {
      draw_x--;    
    }
  
    value = arduino.analogRead(PIN_ANALOG_Y);    
  
    if (value > Y_THRESHOLD_HIGH) {
      draw_y--;
    } else if (value < Y_THRESHOLD_LOW) {
      draw_y++;    
    }
    
  } else if (POSITION_METHOD == 1) {
    
    // Non-proportional
    // This method is a simplified method of the non-proportional method above
    // but does not treat a slightly off centre differently.
    draw_x += int(map(arduino.analogRead(PIN_ANALOG_X), 0, 1023, -1, 1));
    draw_y += int(map(arduino.analogRead(PIN_ANALOG_Y), 0, 1023, 1, -1));
    
  } else if (POSITION_METHOD == 2) {
    
    // Proportional
    // This method is somewhat proportional--the further away the joystick is
    // from a centred position the faster the movement of the drawing point.
    // This would work better if we drew with lines rather than dots.
    draw_x += int(map(arduino.analogRead(PIN_ANALOG_X), 0, 1023, -3, 3));
    draw_y += int(map(arduino.analogRead(PIN_ANALOG_Y), 0, 1023, 3, -3));
    
  } else if (POSITION_METHOD == 3) {
    
    // Direct mapping from position to screen
    // This method creates a direct mapping between the joystick position and
    // the drawing point. e.g. When the joystick is in a top-left position the
    // drawing point is at the top-left corner of the window.
    // With a self-centering joystick this method isn't very useful as most
    // of the time the joystick will be forced to centre or an axis.
    draw_x = int(map(arduino.analogRead(PIN_ANALOG_X), 0, 1023, 0, MAX_X));
    draw_y = int(map(arduino.analogRead(PIN_ANALOG_Y), 0, 1023, MAX_Y, 0));
    
  }

  // Ensure we don't try to draw outside the window
  draw_x = constrain(draw_x, 0, MAX_X);
  draw_y = constrain(draw_y, 0, MAX_Y);      


  // Draw on screen
  if (arduino.digitalRead(PIN_BUTTON_SELECT) == arduino.HIGH) {
    point(draw_x, draw_y);
  } else {
    ellipse(draw_x, draw_y, 5, 5);
  }  
}


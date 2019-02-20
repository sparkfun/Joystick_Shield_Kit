/*JoystickArduinoIntermediateExample.ino

  Modified by: Ho Yun "Bobby" Chan 2/19/2019
  Based on original example by Ryan Owens
  SparkFun Electronics Inc.

  Description:

      A basic sketch to demonstrate reading values from the joystick shield
      Written for SparkFun Arduino Inventor's Kit CIRC-JOY

  How to use:

    - Connect joystick shield to your Arduino
    - Upload this sketch to your Arduino
    - Open the Arduino IDE Serial Monitor (set to 9600 baud)
    - Waggle joystick, push buttons

  Requires:

    - Arduino
    - SparkFun Joystick Shield
*/



// Store the Arduino pin associated with each input
const int PIN_BUTTON_SELECT = 2; // Select button is triggered when joystick is pressed

const int PIN_BUTTON_RIGHT = 3;
const int PIN_BUTTON_UP = 4;
const int PIN_BUTTON_DOWN = 5;
const int PIN_BUTTON_LEFT = 6;

const int PIN_ANALOG_X = 0;
const int PIN_ANALOG_Y = 1;

// Threshold values when the joystick is resting at the center
// Make sure to adjust as necessary

const int X_THRESHOLD_LOW = 505;
const int X_THRESHOLD_HIGH = 530;

const int Y_THRESHOLD_LOW = 500;
const int Y_THRESHOLD_HIGH = 530;

//position and direction

int x_position;
int y_position;

int x_direction;
int y_direction;

void setup() {
  Serial.begin(9600);

  // Specify each pin connected to a pushbutton as an input.
  // Also enable the Arduino's internal "pull-up" resistors
  // for each pushbutton we want to read--this means the shield
  // doesn't need to have resistors on it.
  // Note that when a pull-up resistor is used on a pin the
  // meaning of the values read are reversed compared to their
  // usual meanings:
  //    * HIGH = the button is not pressed
  //    * LOW = the button is pressed

  /* old method to turn on the pull-up resistor for the SEL line
     before Arduino IDE v1.01 (see http://arduino.cc/en/Tutorial/DigitalPins)
    /*pinMode(PIN_BUTTON_RIGHT, INPUT);
    digitalWrite(PIN_BUTTON_RIGHT, HIGH);

    pinMode(PIN_BUTTON_LEFT, INPUT);
    digitalWrite(PIN_BUTTON_LEFT, HIGH);

    pinMode(PIN_BUTTON_UP, INPUT);
    digitalWrite(PIN_BUTTON_UP, HIGH);

    pinMode(PIN_BUTTON_DOWN, INPUT);
    digitalWrite(PIN_BUTTON_DOWN, HIGH);

    pinMode(PIN_BUTTON_SELECT, INPUT);
    digitalWrite(PIN_BUTTON_SELECT, HIGH);*/

  pinMode(PIN_BUTTON_RIGHT, INPUT_PULLUP);
  pinMode(PIN_BUTTON_LEFT, INPUT_PULLUP);
  pinMode(PIN_BUTTON_UP, INPUT_PULLUP);
  pinMode(PIN_BUTTON_DOWN, INPUT_PULLUP);
  pinMode(PIN_BUTTON_SELECT, INPUT_PULLUP);
}


void loop() {
  //reset direction
  x_direction = 0;
  y_direction = 0;

  //read current position
  x_position = analogRead(PIN_ANALOG_X);
  y_position = analogRead(PIN_ANALOG_Y);

  if (x_position > X_THRESHOLD_HIGH) {
    x_direction = 1;
  }
  else if (x_position < X_THRESHOLD_LOW) {
    x_direction = -1;
  }

  if (y_position > Y_THRESHOLD_HIGH) {
    y_direction = 1;
  }
  else if (y_position < Y_THRESHOLD_LOW) {
    y_direction = -1;
  }


  if (x_direction == -1) {
    if (y_direction == -1) {
      Serial.println("left-down");
    }
    else if (y_direction == 0) {
      Serial.println("left");
    }
    else {
      // y_direction == 1
      Serial.println("left-up");
    }
  }
  else if (x_direction == 0) {
    if (y_direction == -1) {
      Serial.println("down");
    }
    else if (y_direction == 0) {
      Serial.println("centered");
    }
    else {
      // y_direction == 1
      Serial.println("up");
    }
  }
  else {
    // x_direction == 1
    if (y_direction == -1) {
      Serial.println("right-down");
    }
    else if (y_direction == 0) {
      Serial.println("right");
    }
    else {
      // y_direction == 1
      Serial.println("right-up");
    }
  }
  
  // Print the current values of the inputs (joystick and
  // buttons) to the console.
  Serial.print("l:");
  Serial.print(digitalRead(PIN_BUTTON_LEFT));
  Serial.print(" ");

  Serial.print("r:");
  Serial.print(digitalRead(PIN_BUTTON_RIGHT));
  Serial.print(" ");

  Serial.print("u:");
  Serial.print(digitalRead(PIN_BUTTON_UP));
  Serial.print(" ");

  Serial.print("d:");
  Serial.print(digitalRead(PIN_BUTTON_DOWN));
  Serial.print(" ");

  Serial.print("x:");
  Serial.print(analogRead(PIN_ANALOG_X));
  Serial.print(" ");

  Serial.print("y:");
  Serial.print(analogRead(PIN_ANALOG_Y));
  Serial.print(" ");

  Serial.print("s:");
  Serial.print(digitalRead(PIN_BUTTON_SELECT));
  Serial.print(" ");

  Serial.println();
  Serial.println();
  //delay(100); //uncomment to read and observe values easier
  
}

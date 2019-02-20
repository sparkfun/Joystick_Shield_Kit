/*JoystickArduinoMelodyControl.ino

  Description:
    A sketch to demonstrate using a joystick to control the
  tempo and pitch of a "melody".

  (And you thought the standard Melody sketch was annoying!)

  How to use:

    - Connect joystick shield to your Arduino
    - Connect piezo buzzer to your Arduino using breadboard and jumper wire
       - Positive pin of buzzer to Arduino pin 9
       - Other pin of buzzer to Arduino ground (GND)
    - Upload this sketch to your Arduino
    - Move joystick
       - Moving left and right controls the tempo
       - Moving up and down controls the pitch

  Requires:

    - Arduino
    - SparkFun Joystick Shield

  This sketch is a lightly modified version of<http://www.arduino.cc/en/Tutorial/Melody>
  for SparkFun Arduino Inventor's Kit CIRC-JOY

*/

// Store the Arduino pin associated with each axis of the joystick input
const int PIN_ANALOG_X = 0;
const int PIN_ANALOG_Y = 1;


const int speakerPin = 9;

int length = 15; // the number of notes
char notes[] = "ccggaagffeeddc "; // a space represents a rest
int beats[] = { 1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 2, 4 };
int tempo = 300;

void playTone(int tone, int duration) {
  for (long i = 0; i < duration * 1000L; i += tone * 2) {
    digitalWrite(speakerPin, HIGH);
    delayMicroseconds(tone);
    digitalWrite(speakerPin, LOW);
    delayMicroseconds(tone);
  }
}

void playNote(char note, int duration) {
  char names[] = { 'c', 'd', 'e', 'f', 'g', 'a', 'b', 'C' };
  int tones[] = { 1915, 1700, 1519, 1432, 1275, 1136, 1014, 956 };

  // play the tone corresponding to the note name
  for (int i = 0; i < 8; i++) {
    if (names[i] == note) {
      // We modify the pitch of the note to be played based on the vertical position
      // of the joystick:
      playTone(tones[i] + map(analogRead(PIN_ANALOG_Y), 0, 1023, 959, -959), duration);
    }
  }
}

void setup() {
  pinMode(speakerPin, OUTPUT);
}

void loop() {
  for (int i = 0; i < length; i++) {
    // We set the tempo based on the horizontal position of the joystick:
    tempo = map(analogRead(PIN_ANALOG_X), 0, 1023, 500, 100);
    if (notes[i] == ' ') {
      delay(beats[i] * tempo); // rest
    } else {
      playNote(notes[i], beats[i] * tempo);
    }

    // pause between notes
    delay(tempo / 2);
  }
}

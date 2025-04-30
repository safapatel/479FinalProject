#include <DHT11.h>

// Include the DHT11 library for interfacing with the sensor.
#include <Adafruit_MPU6050.h> //gyro
#include <Adafruit_Sensor.h>
#include "Adafruit_MPR121.h" //touch sensor
#include "SerialRecord.h"
#include <dht11.h>

#ifndef _BV
#define _BV(bit) (1 << (bit)) 
#endif

// Create an instance of the DHT11 class.
// - For Arduino: Connect the sensor to Digital I/O Pin 2.
// - For ESP32: Connect the sensor to pin GPIO2 or P2.
// - For ESP8266: Connect the sensor to GPIO2 or D4.
Adafruit_MPU6050 mpu;

DHT11 dht11(8);

const int fsr_1 = A0;
const int fsr_2 = A1;
const int fsr_3 = A2;
int valTouch, valRelease;
SerialRecord writer(14);

Adafruit_MPR121 cap = Adafruit_MPR121();
// Keeps track of the last pins touched so we know when buttons are 'released'
uint16_t lasttouched = 0;
uint16_t currtouched = 0;

void setup() {
    // Initialize serial communication to allow debugging and data readout.
    // Using a baud rate of 9600 bps.
    Serial.begin(115200);

    // Get the currently touched pads
    currtouched = cap.touched();

    // Uncomment the line below to set a custom delay between sensor readings (in milliseconds).
}

void loop() {
    int temperature = 0;
    int humidity = 0;

    // Attempt to read the temperature and humidity values from the DHT11 sensor.
    int result = dht11.readTemperatureHumidity(temperature, humidity);

    // Check the results of the readings.
    // If the reading is successful, print the temperature and humidity values.
    // If there are errors, print the appropriate error messages.
    if (result == 0) {
        Serial.print("Temperature: ");
        Serial.print(temperature);
        Serial.print(" °C\tHumidity: ");
        Serial.print(humidity);
        Serial.println(" %");
    } else {
        // Print error message based on the error code.
        Serial.println(DHT11::getErrorString(result));
    }

  delay(500); // Set this to the desired delay. Default is 500ms.

  /*static sensors_event_t lastA;
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  // Acceleration delta
  float dx = a.acceleration.x - lastA.acceleration.x;
  float dy = a.acceleration.y - lastA.acceleration.y;
  float dz = a.acceleration.z - lastA.acceleration.z;
  float deltaAcc = sqrt(dx*dx + dy*dy + dz*dz);
  lastA = a;
  // Gyro magnitude (optional)
  float gyroMag = sqrt(g.gyro.x * g.gyro.x + g.gyro.y * g.gyro.y + g.gyro.z * g.gyro.z);

  // Final motion value
  int movementVal = (int)((deltaAcc + gyroMag) * 100);

  for (uint8_t i=0; i<11; i++) {
    // it if *is* touched and *wasnt* touched before, alert!
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i)) ) {
      valTouch = i; 
    }
    // if it *was* touched and now *isnt*, alert!
    if (!(currtouched & _BV(i)) && (lasttouched & _BV(i)) ) {
      valRelease  = i; 
    }
  }

  // reset our state
  lasttouched = currtouched;

  writer[0] = analogRead(fsr_1);
  writer[1] = analogRead(fsr_2);
  writer[2] = analogRead(fsr_3);
  writer[3] = temperature;
  writer[4] = humidity;
  writer[5] = a.acceleration.x;
  writer[6] = a.acceleration.y;
  writer[7] = a.acceleration.z;
  writer[8] = g.gyro.x;
  writer[9] = g.gyro.y;
  writer[10] = g.gyro.z;
  writer[11] = movementVal;
  writer[12] = valTouch;
  writer[13] = valRelease;

    // Send structured message
  writer.send();*/
  
  // put a delay so it isn't overwhelming
  delay(200);
}

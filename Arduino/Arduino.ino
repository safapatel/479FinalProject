#include "SerialRecord.h"
#include <DHT11.h>
#include <dht_nonblocking.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include "Adafruit_MPR121.h"
#include <Wire.h>

//touch sensor definitions
#ifndef _BV
#define _BV(bit) (1 << (bit)) 
#endif

//Dust sensor definitions
#define        COV_RATIO                       0.2            //ug/mmm / mv
#define        NO_DUST_VOLTAGE                 400            //mv
#define        SYS_VOLTAGE                     5000    

// DHT Sensor definitions and pins
#define DHT_SENSOR_TYPE DHT_TYPE_11
const int DHT_SENSOR_PIN = 10;
DHT_nonblocking dht_sensor(DHT_SENSOR_PIN, DHT_SENSOR_TYPE);

//FSR PINS
const int FSR1_PIN = A0;
const int FSR2_PIN = A1;
const int FSR3_PIN = A2;

//Dust sensor pins and variables
const int iled = 6;                                            //drive the led of sensor
const int vout = 4;                                            //analog input
float density, voltage;
int   adcvalue;

//MPU6050 
Adafruit_MPU6050 mpu;
sensors_event_t accel, gyro, temp;
sensors_event_t lastAccel;

//Touch sensor
Adafruit_MPR121 cap = Adafruit_MPR121();
int valTouch, valRelease;
uint16_t lasttouched = 0;
uint16_t currtouched = 0;

SerialRecord writer(15);


// Function Prototypes
void setupMPU6050();
void setupMPR121();
bool readDHT(float* temperature, float* humidity);
int computeMotionValue();
void updateMotionEvents();
void readTouchSensors();
//Dust sensor functions
int Filter(int m);
void setupDustSensor();
float readDustSensor(int pin);

void setup() {
  Serial.begin(115200);
  setupMPU6050();
  setupMPR121();
  //setupDustSensor();
}

void loop() {
  float temperature = 0, humidity = 0, density = 0;

  if (mpu.getMotionInterruptStatus()) {
    updateMotionEvents();
  }
  readTouchSensors();



  writer[0] = analogRead(FSR1_PIN);
  writer[1] = analogRead(FSR2_PIN);
  writer[2] = analogRead(FSR3_PIN);

  if (readDHT(&temperature, &humidity)) {
    writer[3] = temperature;
    writer[4] = humidity;
  }

  writer[5] = accel.acceleration.x;
  writer[6] = accel.acceleration.y;
  writer[7] = accel.acceleration.z;

  writer[8] = gyro.gyro.x;
  writer[9] = gyro.gyro.y;
  writer[10] = gyro.gyro.z;

  writer[11] = computeMotionValue();

  writer[12] = valTouch;
  writer[13] = valRelease;
  writer[14] = 0;


  writer.send();

  delay(10); // Optional: minimal delay to prevent overload
}

// --------------------------------------------------------------------------------------------------
// Setup & Initialization
// --------------------------------------------------------------------------------------------------
void setupMPU6050() {
  // MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to find MPU6050 chip");
  } else {
    Serial.println("MPU6050 Found!");
    mpu.setHighPassFilter(MPU6050_HIGHPASS_0_63_HZ);
    mpu.setMotionDetectionThreshold(1);
    mpu.setMotionDetectionDuration(20);
    mpu.setInterruptPinLatch(true);
    mpu.setInterruptPinPolarity(true);
    mpu.setMotionInterrupt(true);
  }
}

void setupMPR121() {
  while (!cap.begin(0x5A)) {
    Serial.println("MPR121 not found, check wiring?");
  }
  Serial.println("MPR121 found!");
  currtouched = cap.touched();
}

void setupDustSensor() {
  pinMode(iled, OUTPUT);
  digitalWrite(iled, LOW);                                     //iled default closed                                        //send and receive at 9600 baud
}

// --------------------------------------------------------------------------------------------------
// Sensor Reading Functions
// --------------------------------------------------------------------------------------------------
void updateMotionEvents() {
  mpu.getEvent(&accel, &gyro, &temp);
}

int computeMotionValue() {
  float dx = accel.acceleration.x - lastAccel.acceleration.x;
  float dy = accel.acceleration.y - lastAccel.acceleration.y;
  float dz = accel.acceleration.z - lastAccel.acceleration.z;
  float deltaAcc = sqrt(dx * dx + dy * dy + dz * dz);

  lastAccel = accel;

  float gyroMag = sqrt(gyro.gyro.x * gyro.gyro.x +
                       gyro.gyro.y * gyro.gyro.y +
                       gyro.gyro.z * gyro.gyro.z);

  return (int)((deltaAcc + gyroMag) * 100);
}

bool readDHT(float* temperature, float* humidity) {
  static unsigned long lastMeasureTime = 0;

  if (millis() - lastMeasureTime > 3000ul) {
    if (dht_sensor.measure(temperature, humidity)) {
      lastMeasureTime = millis();
      return true;
    }
  }
  return false;
}

//read touch sensors
void readTouchSensors() {
  lasttouched = currtouched;
  currtouched = cap.touched();

  for (uint8_t i = 0; i < 11; i++) {
    if ((currtouched & _BV(i)) && !(lasttouched & _BV(i))) {
      valTouch = i;
    }
    if (!(currtouched & _BV(i)) && (lasttouched & _BV(i))) {
      valRelease = i;
    }
  }
}

//read dust sensor
float readDustSensor(){
  digitalWrite(iled, HIGH);
  delayMicroseconds(280);
  adcvalue = analogRead(vout);
  digitalWrite(iled, LOW);
  adcvalue = Filter(adcvalue);

  //covert voltage (mv)
  voltage = (SYS_VOLTAGE / 1024.0) * adcvalue * 11;

  //voltage to density
  if(voltage >= NO_DUST_VOLTAGE)
  {
    voltage -= NO_DUST_VOLTAGE;
    density = voltage * COV_RATIO;
  }
  else {density = 0;}
    
}
// --------------------------------------------------------------------------------------------------
// Helper Functions
// --------------------------------------------------------------------------------------------------
int Filter(int m)
{
  static int flag_first = 0, _buff[10], sum;
  const int _buff_max = 10;
  int i;
  
  if(flag_first == 0)
  {
    flag_first = 1;
    for(i = 0, sum = 0; i < _buff_max; i++)
    {
      _buff[i] = m;
      sum += _buff[i];
    }
    return m;
  }
  else
  {
    sum -= _buff[0];
    for(i = 0; i < (_buff_max - 1); i++)
    {
      _buff[i] = _buff[i + 1];
    }
    _buff[9] = m;
    sum += _buff[9];
    
    i = sum / 10.0;
    return i;
  }
}



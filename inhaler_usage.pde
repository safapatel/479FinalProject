PImage inhalerImg;

/// CHANGE ACCORDING TO THE DATA ///
int dosagesLeft;    // Starting dosage count
int totalDosages;   // Maximum dosage count
int dailyUsage = 0;       // Daily usage counter
int usageWindowMin = 10;  // Time window for tracking usage
int prevTouch = -1;       // Previous touch sensor state
int prevRelease = -1;     // Previous release sensor state
int lastDosageTime = 0;   // Time of last dosage count
int COOLDOWN_MS = 5000;   // 5 second cooldown between doses
boolean[] sensorStates = {false, false};  // Track state of both sensors

void Inhalersetup(){
  size(500, 650);
  inhalerImg = loadImage("inhaler.png");
  // Initialize with user's input dosage
  totalDosages = dosage;
  dosagesLeft = dosage;
  println("Initialized inhaler with " + dosage + " doses");
}

void updateInhalerUsage(int touchSensor, int releaseSensor) {
  // Debug output
  println("Touch: " + touchSensor + ", Release: " + releaseSensor);
  
  // Check if enough time has passed since last dosage
  int currentTime = millis();
  boolean canCountDose = (currentTime - lastDosageTime) >= COOLDOWN_MS;
  
  // Only count if there's an actual change in either sensor and cooldown has passed
  if (canCountDose && 
      (touchSensor != prevTouch || releaseSensor != prevRelease) && 
      (touchSensor == 0 || touchSensor == 1 || releaseSensor == 0 || releaseSensor == 1) && 
      dosagesLeft > 0) {
    dosagesLeft--;
    dailyUsage++;
    lastDosageTime = currentTime;
    println("Dosage counted. Left: " + dosagesLeft + "/" + totalDosages);
  }
  
  // Update previous states
  prevTouch = touchSensor;
  prevRelease = releaseSensor;
}

void drawInhalerUsage(){
  background(bgColor);
  
  fill(0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Your inhaler usage", width/2, 80);
  
  textSize(20);

  textAlign(LEFT, TOP);
  text("Dosages left:\n" + dosagesLeft + " / " + totalDosages,
       width*0.15, height*0.3);

  textAlign(RIGHT, TOP);
  text("Daily usage:\n" 
       + dailyUsage 
       + " times in the last \n" 
       + usageWindowMin 
       + " minutes",
       width*0.85, height*0.3);
  
  // Show cooldown status
  int timeSinceLastDose = millis() - lastDosageTime;
  if (timeSinceLastDose < COOLDOWN_MS) {
    fill(#e63946);  // Red for cooldown
    textAlign(CENTER, CENTER);
    textSize(18);
    text("Next dose available in " + ((COOLDOWN_MS - timeSinceLastDose) / 1000) + " seconds",
         width/2, height*0.45);
  }
  
  textAlign(CENTER, CENTER);
  textSize(18);
  float pctLeft = (float)dosagesLeft / totalDosages * 100;
  if (pctLeft < 20) {
    fill(#e63946);  // Red for warning
    text("You only have " 
         + nf(pctLeft, 0, 0) 
         + "% of the medication left,\nplease refill!!",
         width/2, height*0.55);
  } else {
    fill(0);
    text("You have " 
         + nf(pctLeft, 0, 0) 
         + "% of the medication left",
         width/2, height*0.55);
  }
  
  float imgW = 400;
  float imgH = 200;
  float imgX = width/2 - imgW/2;
  float imgY = height*0.80 - imgH/2;
  
  inhalerImg = loadImage("inhaler.png");

  imageMode(CORNER);
  image(inhalerImg, imgX, imgY, imgW, imgH);
  
  // Visual indicators for sensor states
  for (int i = 0; i < 2; i++) {
    if (sensorStates[i]) {
      fill(0, 255, 0, 100);  // Semi-transparent green
      ellipse(width/2 + (i == 0 ? -30 : 30), height*0.80, 30, 30);
    }
  }
}
class MotionData {
  // Acceleration data
  float accelX;
  float accelY;
  float accelZ;
  
  // Gyroscope data
  float gyroX;
  float gyroY;
  float gyroZ;
  
  // Constructor
  MotionData(float ax, float ay, float az, float gx, float gy, float gz) {
    accelX = ax;
    accelY = ay;
    accelZ = az;
    gyroX = gx;
    gyroY = gy;
    gyroZ = gz;
  }
  
  // Create from serial data array
  MotionData(float[] values) {
    if (values.length >= 11) { // Make sure we have enough data
      accelX = values[5];
      accelY = values[6];
      accelZ = values[7];
      gyroX = values[8];
      gyroY = values[9];
      gyroZ = values[10];
    }
  }
  
}
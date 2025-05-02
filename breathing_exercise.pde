import osteele.processing.SerialRecord.*;


float size = 10; //current size - continuously updated
float minSize = 30; //minimum circle size (reduced)
float maxSize = 120; //maximum size (reduced)
float sizeSpeed = 0.01; //change speed for size (how much will the size increase/decrease each frame)
int clickTime, netTime;
int sec = 5; //count down time
int currTime = millis()/1000;

// FSR visualization
float fsrSize = 100;  // Size of the FSR circle

void updateBreathingExercise(float fsr1, float fsr2, float fsr3) {
  // Calculate average FSR value (normalized to 0-1 range)
  float avgFSR = (fsr1 + fsr2 + fsr3) / 3.0;
  // Map FSR value to circle size
  fsrSize = map(avgFSR, 0, 1023, minSize, maxSize);
  println("FSR Values: " + fsr1 + ", " + fsr2 + ", " + fsr3 + " | Average: " + avgFSR + " | Circle Size: " + fsrSize);
}

void drawBreathingExercise(){
  ellipseMode(RADIUS);
  colorMode(HSB, 360, 100, 100);
  currTime = millis()/1000;
  size = map(sin(frameCount * sizeSpeed), -1.0, 1.0, minSize, maxSize);
  netTime = currTime-clickTime;
  println("clicked: ", clickTime, ", ongoing: ", currTime, ", during: ", netTime);
  
  // Draw FSR circle (inverted colors) - left side
  float h2 = 85; // Inverted hue (265 + 180) % 360
  for (float r = fsrSize; r > 0; --r) {
    fill(h2, 90, 90);
    ellipse(width/4, height/2, r, r);
    h2 = (h2 + 1) % 360;
  }
  
  textSize(40);
  if(netTime <= 5){ //breathe in for 5 seconds
    fill(0);
    text("Breathe IN", width/2, 100);
    text(5 -netTime, width/2, 140);
  }
  if(netTime > 5){ //breathe out for 5 seconds
    fill(0);
    text("Breathe OUT", width/2, 100);
    text(11 - netTime, width/2, 140);
    if(netTime > 11){ //reset time
      clickTime = currTime;
      netTime = 0;
    }
  }
  
  // Draw original breathing exercise circle - right side
  float h = 265;
  for (float r = size; r > 0; --r) {
    fill(h, 90, 90);
    ellipse(width*3/4, height/2, r, r);
    h = (h + 1) % 360;
  }
  
  // Add labels
  textSize(20);
  fill(0);
  textAlign(CENTER, CENTER);
  text("Your Breathing (FSR)", width/4, height/2 + maxSize + 30);
  text("Target Breathing", width*3/4, height/2 + maxSize + 30);
  
  // Reset color mode to RGB for buttons
  colorMode(RGB, 255, 255, 255);
}

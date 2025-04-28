float size = 10; //current size - continuously updated
float minSize = 50; //minimum circle size
float maxSize = 200; //maximum size
float sizeSpeed = 0.01; //change speed for size (how much will the size increase/decrease each frame)
int prevTime = 0;
int sec = 5; //count down time

void drawBreathingExercise(){
  size = map(sin(frameCount * sizeSpeed),-1.0,1.0,minSize,maxSize);
  textSize(40);
  int currTime = millis()/1000;
  int netTime = currTime - prevTime;

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
      prevTime = currTime;
    }
  }
  float h = 265;
  for (float r = size; r > 0; --r) {
    fill(h, 90, 90);
    ellipse(width/2, height-250, r, r);
    h = (h + 1) % 360;
  }
}

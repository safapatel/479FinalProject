PImage inhalerImg;

/// CHANGE ACCORDING TO THE DATA ///
int dosagesLeft    = 100;
int totalDosages   = dosage;
int dailyUsage     = 4;
int usageWindowMin = 10;

void Inhalersetup(){
  size(500, 650);
  inhalerImg = loadImage("inhaler.png");
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
  
  textAlign(CENTER, CENTER);
  textSize(18);
  float pctLeft = (float)dosagesLeft / totalDosages * 100;
  text("You only have " 
       + nf(pctLeft, 0, 0) 
       + "% of the medication left,\nplease refill!!",
       width/2, height*0.55);
  
  float imgW = 400;
  float imgH = 200;
  float imgX = width/2 - imgW/2;
  float imgY = height*0.80 - imgH/2;
  
  inhalerImg = loadImage("inhaler.png");

  imageMode(CORNER);
  image(inhalerImg, imgX, imgY, imgW, imgH);
}

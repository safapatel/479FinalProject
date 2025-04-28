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
  fill(bgColor);
  stroke(200);
  strokeWeight(2);
  // a rounded rectangle inset by 20px on each side
  rect(20, 20, width-40, height-40, 20);
  
  // ─── Title ───
  fill(0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Your inhaler usage", width/2, 80);
  
  // ─── Dosages left (left) / Daily usage (right) ───
  textSize(20);
  // left column
  textAlign(LEFT, TOP);
  text("Dosages left:\n" + dosagesLeft + " / " + totalDosages,
       width*0.15, height*0.3);
  // right column
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
  
  float imgW = 200;
  float imgH = 100;
  float imgX = width/2 - imgW/2;
  float imgY = height*0.75 - imgH/2;
  
  imageMode(CORNER);
  image(inhalerImg, imgX, imgY, imgW, imgH);
}

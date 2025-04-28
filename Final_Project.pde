import processing.sound.*;
import processing.serial.*;

int currentScreen = 0; // 0 is the first screen 

// variable to store background color
color bgColor = #D8F3F2;

String dosageAmount = ""; // user input of total dosage amount 

// global variables
int dosage; 
int startTime; 
int elapsedTime;

 
Button screenOne; // change to screen with graph/temp
Button screenTwo; // change to screen with inhaler usage 

void setup() {
  
   size(500, 650);
   
   buttonSetup();
   
  setupRespirationGraph();
  firstTime = millis();
}

void draw() {
    switch(currentScreen){
    case 0: drawFirstScreen();   break;
    case 1: drawSecondScreen();  break;
    case 2: drawThirdScreen();   break;
  }
}

// first screen to take in dosage input 
void drawFirstScreen() {
  background(bgColor); // background color 
  fill(0); // text color
  textSize(24); // text size
  PFont font = createFont("Times new roman", 30, true); // Use script font
  textFont(font); // Apply the font
  textAlign(CENTER, CENTER); // center text in middle
  text("Enter total dosage amount", width / 2, height / 5); // text to display 
  
  // display user input
  fill(0);
  textSize(30);
  text(dosageAmount, width / 2, height / 4);
  
  dosage = parseInt(dosageAmount);
  
  // display buttons
  screenOne.display();  
  screenTwo.display(); 
}

// second screen to display respiration graph and temp and humidity  
void drawSecondScreen() {
  background(bgColor); // background color 
  fill(0); // text color
  textSize(24); // text size
  PFont font = createFont("Times new roman", 30, true); // Use script font
  textFont(font); // Apply the font
  textAlign(CENTER, CENTER); // center text in middle
  
  int currentTime = millis() / 1000; 
  elapsedTime = currentTime - startTime;
  drawRespirationGraph();
  drawGauge(100, height - 100, 200, temperature, 68, 71, "Temp (°F)");
  drawGauge(350, height - 100, 200, humidity, 30, 50, "Humidity (%)");

}

void drawThirdScreen(){
  drawInhalerUsage();
}


// button setup 
void buttonSetup() {
  float btnW = 300;
  float btnH = 60;
  // center them horizontally by subtracting half their width
  screenOne = new Button(width/2 - btnW/2, height/2 - btnH/2, btnW, btnH,
    "Check breathing & weather");
  screenTwo = new Button(width/2 - btnW/2, height/2 + btnH + 20, btnW, btnH,
    "Track inhaler usage");
}

// mouse click behavior 
void mousePressed() {
  if (currentScreen == 0 && screenOne.isClicked(mouseX, mouseY) && !dosageAmount.equals("")) { 
    currentScreen = 1; // switch to the first screen
  } else if (currentScreen == 0 && screenTwo.isClicked(mouseX, mouseY) && !dosageAmount.equals("")) {
    currentScreen = 2; // switch to the second screen
  } 
}

// take in user input of their dosage amount
void keyPressed() {
  // only accept digits
  if (key >= '0' && key <= '9') {
    dosageAmount += key;
  }
  // handle backspace
  else if (key == BACKSPACE && dosageAmount.length() > 0) {
    dosageAmount = dosageAmount.substring(0, dosageAmount.length() - 1);
  }
  // if they hit Enter/Return, you can parse it:
  else if (key == ENTER || key == RETURN) {
    dosage = parseInt(dosageAmount);
  }
}

// button class
class Button {
  float x, y, w, h; // variables for button
  String label; // label on the button 
  
  // set button size 
  Button(float x, float y, float w, float h, String label) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.label = label;
  }
  
  // display button 
  void display() {
    fill(100, 150, 255);
    rect(x, y, w, h, 10);
    
    fill(255);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(label, x + w / 2, y + h / 2);
  }
  
  // behavior when clicked 
  boolean isClicked(int mx, int my) {
    return mx > x && mx < x + w && my > y && my < y + h;
  }
}

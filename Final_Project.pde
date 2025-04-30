import processing.serial.*;

int currentScreen = 0; // 0 is the first screen 

color bgColor = #D8F3F2; // variable to store background color

String dosageAmount = ""; // user input of total dosage amount 

// global variables
int dosage; 
int startTime; 
int elapsedTime;

SerialRecord serialRecord;
Serial myPort;


Button screenOne; // change to screen with graph/temp
Button screenTwo; // change to screen with inhaler usage 
Button screenThree; // change to screen with inhaler usage 

Button backButton; // button to go back 
Button homeButton; // button to go to first screen

void setup() {
 
  size(500, 650);
  buttonSetup(); 
  setupRespirationGraph();
  firstTime = millis();
  noStroke();
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 115200);
  serialRecord = new SerialRecord(this, myPort, 11);
}

void draw() {
    switch(currentScreen){
    case 0: drawFirstScreen();   break;
    case 1: drawSecondScreen();  break;
    case 2: drawThirdScreen();   break;
    case 3: drawFourthScreen();   break;
    case 4: drawBreathingScreen(); break;
  }
  serialRecord.read();
  float fsr1 = serialRecord.values[0] / 1023.0;
  float fsr2   = serialRecord.values[1] / 1023.0;
  float fsr3   = serialRecord.values[2] / 1023.0;
  float temp   = serialRecord.values[3];

  
  println(fsr1 + "," + fsr2 + "," + fsr3 + "," + temp);
  
}

// first screen to take in dosage input 
void drawFirstScreen() {
  background(bgColor); // background color 
  fill(0); // text color
  textSize(24); // text size
  PFont font = createFont("Times new roman", 30, true); // Use script font
  textFont(font); // Apply the font
  textAlign(CENTER, CENTER); // center text in middle
  text("Enter Total Dosage Amount: ", width / 2, height / 5); // text to display 
  
  // display user input
  fill(0);
  textSize(30);
  text(dosageAmount, width / 2, height / 4);
  
  dosage = parseInt(dosageAmount);
  
  // display buttons
  screenOne.display();  
  screenTwo.display(); 
  screenThree.display();
}

// second screen to display respiration graph and temp and humidity  
void drawSecondScreen() {
  background(bgColor); // background color 
  fill(0); // text color
  textSize(24); // text size
  PFont font = createFont("Times new roman", 30, true); // Use script font
  textFont(font); // Apply the font
  textAlign(CENTER, CENTER); // center text in middle
  
  backButton.display(); 
  homeButton.display();
  
  int currentTime = millis() / 1000; 
  elapsedTime = currentTime - startTime;
  drawRespirationGraph();
  drawGauge(100, height - 100, 200, temperature, 68, 71, "Temp (°F)");
  drawGauge(350, height - 100, 200, humidity, 30, 50, "Humidity (%)");
}

// third screen to display the inhaler information 
void drawThirdScreen(){
  drawInhalerUsage();
  backButton.display(); 
  homeButton.display();
}

void drawFourthScreen(){
  backButton.display(); 
  homeButton.display();
}
void drawBreathingScreen() {
  background(bgColor);
  drawBreathingExercise();
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
  screenThree = new Button(width/2 - btnW/2, height/2 + 2*(btnH + 20), btnW, btnH, "Breathing Exercise");
    
  backButton = new Button(width - 550 + 100, height - 645, 100, 20, "Back");
  homeButton = new Button (width / 2 + 100, height - 645, 100, 20, "Home");
}

// mouse click behavior 
void mousePressed() {
  if (currentScreen == 0 && screenOne.isClicked(mouseX, mouseY) && !dosageAmount.equals("")) { 
    currentScreen = 1; // switch to the first screen
  } else if (currentScreen == 0 && screenTwo.isClicked(mouseX, mouseY) && !dosageAmount.equals("")) {
    currentScreen = 2; // switch to the second screen
  } else if (currentScreen == 1 && backButton.isClicked(mouseX, mouseY)){
    currentScreen = 0; 
  } else if (currentScreen == 2 && backButton.isClicked(mouseX, mouseY)){
    currentScreen = 1;
  } else if (currentScreen == 3 && backButton.isClicked(mouseX, mouseY)){
    currentScreen = 2;
  } else if (currentScreen == 1 && homeButton.isClicked(mouseX, mouseY)) {
     currentScreen = 0;  
  } else if (currentScreen == 2 && homeButton.isClicked(mouseX, mouseY)) {
     currentScreen = 0;  
  } else if (currentScreen == 3 && homeButton.isClicked(mouseX, mouseY)) {
     currentScreen = 0;  
  } else if (currentScreen == 0 && screenThree.isClicked(mouseX, mouseY)) {
     currentScreen = 4;
     netTime = 0;
     clickTime = currTime;
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

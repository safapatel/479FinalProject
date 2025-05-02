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

MotionData motion;
int motionValue = 0;

int valTouch = 0;
int valRelease = 0;



void setup() {
 
  size(500, 650);
  buttonSetup(); 
  setupRespirationGraph();
  firstTime = millis();
  noStroke();
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[3], 115200);
  serialRecord = new SerialRecord(this, myPort, 15);
}

void draw() {

  try {
    serialRecord.read();
    float fsr1 = serialRecord.values[0];
    float fsr2 = serialRecord.values[1];
    float fsr3 = serialRecord.values[2];
    temperature = serialRecord.values[3];
    humidity = serialRecord.values[4];
    float accelX = serialRecord.values[5];
    float accelY = serialRecord.values[6];
    float accelZ = serialRecord.values[7];
    float gyroX = serialRecord.values[8];
    float gyroY = serialRecord.values[9];
    float gyroZ = serialRecord.values[10];
    motionValue = serialRecord.values[11];
    valTouch = serialRecord.values[12];
    valRelease = serialRecord.values[13];
    motion = new MotionData(accelX, accelY, accelZ, gyroX, gyroY, gyroZ);

    // Process all three FSR values
    float[] fsrValues = {fsr1, fsr2, fsr3};
    processRespirationSignal(fsrValues);

    // Update inhaler usage tracking
    if (currentScreen == 2) {  // Only track when on inhaler usage screen
      updateInhalerUsage(valTouch, valRelease);
    }

    switch(currentScreen){
      case 0: drawFirstScreen();   break;
      case 1: drawSecondScreen();  break;
      case 2: drawThirdScreen();   break;
      case 3: drawFourthScreen();   break;
      case 4: drawBreathingScreen(); break;
    }
    
    //println(fsr1 + "," + fsr2 + "," + fsr3 + "," + temperature);
  } catch (Exception e) {
    println("Error reading serial data: " + e.getMessage());
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
  text("Enter Total Dosage Amount: ", width / 2, height / 5); // text to display 
  
  // display user input
  fill(0);
  textSize(30);
  text(dosageAmount, width / 2, height / 4);
  
  // Update dosage when Enter is pressed or when switching screens
  if (!dosageAmount.equals("")) {
    dosage = parseInt(dosageAmount);
    // Initialize inhaler usage with the new dosage
    totalDosages = dosage;
    dosagesLeft = dosage;
  }
  
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
  // Convert temperature to Celsius and adjust safe range (20-22°C is comfortable room temperature)
  drawGauge(100, height - 100, 150, temperature, 20, 22, "Temp (°C)");
  drawGauge(350, height - 100, 150, humidity, 30, 50, "Humidity (%)");
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
  // Pass FSR values to the breathing exercise
  updateBreathingExercise(serialRecord.values[0], serialRecord.values[1], serialRecord.values[2]);
  drawBreathingExercise();
  // Add navigation buttons
  backButton.display();
  homeButton.display();
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
    // Ensure dosage is initialized before switching screens
    dosage = parseInt(dosageAmount);
    totalDosages = dosage;
    dosagesLeft = dosage;
  } else if (currentScreen == 0 && screenTwo.isClicked(mouseX, mouseY) && !dosageAmount.equals("")) {
    currentScreen = 2; // switch to the second screen
    // Ensure dosage is initialized before switching screens
    dosage = parseInt(dosageAmount);
    totalDosages = dosage;
    dosagesLeft = dosage;
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
  } else if (currentScreen == 4 && backButton.isClicked(mouseX, mouseY)) {
     currentScreen = 0;
  } else if (currentScreen == 4 && homeButton.isClicked(mouseX, mouseY)) {
     currentScreen = 0;
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

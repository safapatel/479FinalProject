import org.gicentre.utils.*; 
import org.gicentre.utils.stat.*;
XYChart respirationGraph;
FloatList time, respirationRates;

float chartX = 10;
float chartY = 20;
int respiratoryGraphWidth = 450;
int respiratorygraphHeight = 300;
final int timeWindow = 120;
long firstTime = 0;

void setupRespirationGraph() {
    fill(0); // text color
    respirationGraph = new XYChart(this);
    time = new FloatList();
    respirationRates = new FloatList();

    // Initialize with empty data
    respirationGraph.setData(new float[0], new float[0]);

    // Set proper y-axis range for respiratory rate (12-50 breaths per minute)
    respirationGraph.setMinY(12);  
    respirationGraph.setMaxY(50);
    respirationGraph.setMinX(0);
    respirationGraph.setMaxX(timeWindow);  // X-axis represents seconds

    // Styling
    respirationGraph.showXAxis(true);
    respirationGraph.showYAxis(true);
    respirationGraph.setPointSize(2);
    respirationGraph.setLineWidth(1);
    respirationGraph.setAxisColour(0);
    respirationGraph.setAxisLabelColour(0);
}

void drawRespirationGraph() {
  try {
    // Set font for labels
    PFont chartFont = createFont("Georgia", 15);
    fill(0); // text color
    textFont(chartFont);
    
    // Move origin to properly position graph
    translate(30, 20);
    
    // Set point and line colors based on respiratory rate
    fill(0); // text color
    if (respirationRates.size() > 0) {
        float latestRate = respirationRates.get(respirationRates.size() - 1);
        
        if (latestRate >= 40) {
            respirationGraph.setPointColour(color(200, 50, 50)); // Red (High)
            respirationGraph.setLineColour(color(200, 50, 50));
        }
        else if (latestRate >= 30) {
            respirationGraph.setPointColour(color(230, 150, 50)); // Orange (Moderate)
            respirationGraph.setLineColour(color(230, 150, 50));
        }
        else {
            respirationGraph.setPointColour(color(100, 180, 100)); // Green (Normal)
            respirationGraph.setLineColour(color(100, 180, 100));
        }
    }

    // Draw respiration graph
    respirationGraph.draw(-4, 10, respiratoryGraphWidth, respiratorygraphHeight);
   
    // Draw labels
    fill(0);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("Respiratory Rate", respiratoryGraphWidth / 2, respiratorygraphHeight + 40);  // Y-axis label
    
    pushMatrix();
    translate(respiratoryGraphWidth - 470, respiratorygraphHeight/2);
    rotate(-HALF_PI);
    text("Time", 0, 0);
    popMatrix();
    
    int numLines = 4;                    
    float step = respiratorygraphHeight / numLines;
    
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i <= 3; i++) {
      float y = chartY + i * step;
      line(chartX, y, chartX + respiratoryGraphWidth - 35, y);
    }
  }
  catch (Exception e) {
    println(e.getMessage());
    e.printStackTrace();
  }
}

// ======== DATA UPDATE FUNCTION ========
void addPointToRespirationGraph(float val) {
    //if (firstTimestamp == 0) firstTimestamp = millis();
    
    float currentTime = (millis() - firstTime) / 1000.0;
    time.append(currentTime);
    respirationRates.append(val);

    // Trim old data to fit within TIME_WINDOW
    while (time.size() != 0 && (currentTime - time.get(0) > timeWindow)) {
        time.remove(0);
        respirationRates.remove(0);
    }

    // Ensure synchronized data
    if (time.size() != respirationRates.size()) {
        return;
    }

    respirationGraph.setData(time.toArray(), respirationRates.toArray());
    respirationGraph.setMinX(0);
    respirationGraph.setMaxX(timeWindow);
}

float prevBreathTime = 0;  // Stores the last detected breath timestamp

void processRespirationSignal(float breathSignal) {
    // Check if the signal crosses a threshold (basic peak detection)
    if (breathSignal > 0.6) {  // Assuming normalized signal (0 to 1)
        float currentTime = millis() / 1000.0;  // Convert to seconds

        if (prevBreathTime > 0) {
            float IBI = currentTime - prevBreathTime;  // Time between breaths
            float respirationRate = 60.0 / IBI;  // Calculate breaths per minute
            
            addPointToRespirationGraph(respirationRate);  // Add respiration rate to the graph
        }
        
        prevBreathTime = currentTime;  // Store last breath time
    }
}

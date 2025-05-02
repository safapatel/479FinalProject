import org.gicentre.utils.*; 
import org.gicentre.utils.stat.*;
XYChart respirationGraph;
FloatList time;
FloatList[] respirationRates;  // Array of FloatLists for each FSR

float chartX = 10;
float chartY = 20;
int respiratoryGraphWidth = 450;
int respiratorygraphHeight = 300;
final int timeWindow = 15;
long firstTime = 0;

void setupRespirationGraph() {
    fill(0); // text color
    respirationGraph = new XYChart(this);
    time = new FloatList();
    respirationRates = new FloatList[3];  // Initialize array for 3 FSRs
    
    // Initialize FloatLists for each FSR
    for (int i = 0; i < 3; i++) {
        respirationRates[i] = new FloatList();
    }

    // Initialize with empty data
    respirationGraph.setData(new float[0], new float[0]);

    // Set proper y-axis range for respiratory rate (0-1000 for FSR values)
    respirationGraph.setMinY(0);  
    respirationGraph.setMaxY(1000);
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
    
    // Colors for each FSR line
    color[] lineColors = {
        color(255, 0, 0),    // Red for FSR1
        color(0, 255, 0),    // Green for FSR2
        color(0, 0, 255)     // Blue for FSR3
    };
    
    // Draw lines for each FSR
    for (int fsr = 0; fsr < 3; fsr++) {
        if (time.size() > 1) {  // Ensure there are at least 2 points to connect
            stroke(lineColors[fsr]);
            strokeWeight(2);
            
            // Calculate the visible time window
            float currentTime = time.get(time.size() - 1);
            float windowStart = max(0, currentTime - timeWindow);
            
            for (int i = 1; i < time.size(); i++) {
                // Only draw points within the visible window
                if (time.get(i) >= windowStart) {
                    float x1 = map(time.get(i - 1), windowStart, currentTime, 0, respiratoryGraphWidth - 35);
                    float y1 = map(respirationRates[fsr].get(i - 1), 0, 1000, respiratorygraphHeight, 0);
                    float x2 = map(time.get(i), windowStart, currentTime, 0, respiratoryGraphWidth - 35);
                    float y2 = map(respirationRates[fsr].get(i), 0, 1000, respiratorygraphHeight, 0);
                    
                    line(x1, y1, x2, y2); // Draw line segment
                }
            }
        }
    }

    // Draw labels
    fill(0);
    textSize(15);
    textAlign(CENTER, CENTER);
    text("Time (sec)", respiratoryGraphWidth / 2, respiratorygraphHeight + 40);  // X-axis label
    
    pushMatrix();
    translate(respiratoryGraphWidth - 470, respiratorygraphHeight / 2);
    rotate(-HALF_PI);
    text("FSR Value", 0, 0);
    popMatrix();
    
    // Draw legend
    textAlign(LEFT, CENTER);
    for (int i = 0; i < 3; i++) {
        fill(lineColors[i]);
        rect(respiratoryGraphWidth - 100, 20 + i * 20, 15, 15);
        fill(0);
        text("FSR " + (i + 1), respiratoryGraphWidth - 80, 28 + i * 20);
    }
    
    // Draw grid lines
    int numLines = 4;                    
    float step = respiratorygraphHeight / numLines;
    
    stroke(0);
    strokeWeight(1);
    for (int i = 0; i <= 3; i++) {
      float y = chartY + i * step;
      line(chartX, y, chartX + respiratoryGraphWidth - 35, y);
      
      // Add y-axis labels
      fill(0);
      textAlign(RIGHT, CENTER);
      text(nf(map(i * step, 0, respiratorygraphHeight, 1000, 0), 0, 0), chartX - 5, y);
    }
  }
  catch (Exception e) {
    println(e.getMessage());
    e.printStackTrace();
  }
}

// ======== DATA UPDATE FUNCTION ========
void addPointToRespirationGraph(float[] values) {
    float currentTime = (millis() - firstTime) / 1000.0;
    time.append(currentTime);
    
    // Add values for each FSR
    for (int i = 0; i < 3; i++) {
        respirationRates[i].append(values[i]);
    }

    // Trim old data to fit within TIME_WINDOW
    while (time.size() != 0 && (currentTime - time.get(0) > timeWindow)) {
        time.remove(0);
        for (int i = 0; i < 3; i++) {
            respirationRates[i].remove(0);
        }
    }

    // Ensure synchronized data
    if (time.size() != respirationRates[0].size()) {
        return;
    }

    respirationGraph.setData(time.toArray(), respirationRates[0].toArray());
    respirationGraph.setMinX(0);
    respirationGraph.setMaxX(timeWindow);
}

void processRespirationSignal(float[] breathSignals) {
    // Directly add the FSR values to the graph
    addPointToRespirationGraph(breathSignals);
}

/// CHANGE ACCORDING TO INPUTTT///
float temperature = 70;     
float humidity    = 70;     

void tempHumiditysetup() {
  size(200, 100);
  textAlign(CENTER, CENTER);
  textSize(14);
  smooth();
}

void drawGauge(float x, float y, float size, float value, float safeMin, float safeMax, String label) {
  float radius = size/2;
  float startA = PI;
  float endA   = TWO_PI;
  float step   = (endA - startA)/4.0;

  noStroke();
  color[] bandColors = {
    #e63946,  // red
    #f4a261,  // orange
    #e9c46a,  // yellow
    #2a9d8f   // green
  };
  for(int i = 0; i < 4; i++) {
    fill(bandColors[i]);
    arc(x, y, size, size, startA + i*step, startA + (i+1)*step, PIE);
  }

  float angle = map(constrain(value, 0, 100), 0, 100, startA, endA);

  boolean safe = (value >= safeMin && value <= safeMax);
  stroke(safe ? 0 : #e63946);
  strokeWeight(3);

  // draw needle
  float nx = x + cos(angle) * (radius * 0.9);
  float ny = y + sin(angle) * (radius * 0.9);
  line(x, y, nx, ny);

  fill(0);
  noStroke();
  ellipse(x, y, 8, 8);

  fill(0);
  textSize(16);
  text(nf(value, 1, 1), x, y - 20);

  textSize(14);
  text(label, x, y + radius - 210);

  fill(safe ? 0 : #e63946);
  textSize(18);
  text(safe ? "LOW RISK" : "HIGH RISK", x, y + radius - 70);
}

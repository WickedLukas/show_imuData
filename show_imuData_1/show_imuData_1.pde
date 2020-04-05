/**
 * Show IMU data.
 * 
 * Reads the serial port to get x- and y- axis rotational data from an accelerometer,
 * a gyroscope, a comeplementary-filtered combination of the two, and a Kalman filtered combination of the two, and displays the
 * orientation data as it applies to three different colored rectangles.
 * It gives the z-orientation data as given by the gyroscope, but since the accelerometer
 * can't provide z-orientation, we don't use this data.
 * 
 */
 
import processing.serial.*;

Serial  myPort;
int     lf = 10;       // ASCII linefeed
String  inString;      // string for serial communication
 
float   dt;
float   angle_x;
float   angle_y;
float   angle_z;

int t0;
int t;
 
void setup()  { 
  size(1000, 1000, P3D);
  noStroke();
  colorMode(RGB, 256); 
  frameRate(60);

  String portName = "COM7";

  myPort = new Serial(this, portName, 115200);
  myPort.clear();
  myPort.bufferUntil(lf);
  
  t0 = millis();
} 

void draw_rect_rainbow() {
  scale(200);
  beginShape(QUADS);

  fill(0, 1, 1); vertex(-1,  1.5,  0.25);
  fill(1, 1, 1); vertex( 1,  1.5,  0.25);
  fill(1, 0, 1); vertex( 1, -1.5,  0.25);
  fill(0, 0, 1); vertex(-1, -1.5,  0.25);

  fill(1, 1, 1); vertex( 1,  1.5,  0.25);
  fill(1, 1, 0); vertex( 1,  1.5, -0.25);
  fill(1, 0, 0); vertex( 1, -1.5, -0.25);
  fill(1, 0, 1); vertex( 1, -1.5,  0.25);

  fill(1, 1, 0); vertex( 1,  1.5, -0.25);
  fill(0, 1, 0); vertex(-1,  1.5, -0.25);
  fill(0, 0, 0); vertex(-1, -1.5, -0.25);
  fill(1, 0, 0); vertex( 1, -1.5, -0.25);

  fill(0, 1, 0); vertex(-1,  1.5, -0.25);
  fill(0, 1, 1); vertex(-1,  1.5,  0.25);
  fill(0, 0, 1); vertex(-1, -1.5,  0.25);
  fill(0, 0, 0); vertex(-1, -1.5, -0.25);

  fill(0, 1, 0); vertex(-1,  1.5, -0.25);
  fill(1, 1, 0); vertex( 1,  1.5, -0.25);
  fill(1, 1, 1); vertex( 1,  1.5,  0.25);
  fill(0, 1, 1); vertex(-1,  1.5,  0.25);

  fill(0, 0, 0); vertex(-1, -1.5, -0.25);
  fill(1, 0, 0); vertex( 1, -1.5, -0.25);
  fill(1, 0, 1); vertex( 1, -1.5,  0.25);
  fill(0, 0, 1); vertex(-1, -1.5,  0.25);
  
  endShape();
}

void draw_rect(int r, int g, int b) {
  scale(200);
  beginShape(QUADS);
  
  fill(r, g, b);
  vertex(-1.5,  1,  0.25);
  vertex( 1.5,  1,  0.25);
  vertex( 1.5, -1,  0.25);
  vertex(-1.5, -1,  0.25);

  vertex( 1.5,  1,  0.25);
  vertex( 1.5,  1, -0.25);
  vertex( 1.5, -1, -0.25);
  vertex( 1.5, -1,  0.25);

  vertex( 1.5,  1, -0.25);
  vertex(-1.5,  1, -0.25);
  vertex(-1.5, -1, -0.25);
  vertex( 1.5, -1, -0.25);

  vertex(-1.5,  1, -0.25);
  vertex(-1.5,  1,  0.25);
  vertex(-1.5, -1,  0.25);
  vertex(-1.5, -1, -0.25);

  vertex(-1.5,  1, -0.25);
  vertex( 1.5,  1, -0.25);
  vertex( 1.5,  1,  0.25);
  vertex(-1.5,  1,  0.25);

  vertex(-1.5, -1, -0.25);
  vertex( 1.5, -1, -0.25);
  vertex( 1.5, -1,  0.25);
  vertex(-1.5, -1,  0.25);

  endShape();
}

void draw()  {
    background(0);
    lights();
    
    // rotate the coordinate system to match imu coordinate system (left-handed)
    // x - right, y - down, z - back --> x - right, y - front, z - down
    int x_rotation = -90;
    
    // show data
    pushMatrix(); 
    translate(width/2, height/2, -50);
    rotateX(radians(x_rotation));
    rotateZ(radians(angle_z));
    rotateY(radians(angle_y));
    rotateX(radians(angle_x));
    draw_rect(0, 255, 0);
    popMatrix();
      
    textSize(24);
    String datStr = "(" + (int) angle_x + ", " + (int) angle_y + ", " + (int) angle_z + ")";
      
    fill(0, 255, 0);
    text("Madgwick filter", (int) (width/2-80), 25);
    text(datStr, (int) (width/2-80), 50);
      
    
    String dtStr = (int) dt + " µs";
    
    fill(128, 128, 128);
    text("dt = " + dtStr, (int) (width/2)-80, 925);
}

void serialEvent(Serial p) {
  inString = (myPort.readString());
  
  try {
    // Parse the data
    String[] dataStrings = split(inString, '#');
    for (int i = 0; i < dataStrings.length; i++) {
      String type = dataStrings[i].substring(0, 4);
      String dataval = dataStrings[i].substring(4);
      if (type.equals("DEL:")) {
        dt = float(dataval);
      }
      else if (type.equals("MDF:")) {
        String data[] = split(dataval, ',');
        angle_x = float(data[0]);
        angle_y = float(data[1]);
        angle_z = float(data[2]);
      }
    }
  }
  catch (Exception e) {
    println("Caught Exception!");
  }
}

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
float   angle_x_gyro;
float   angle_y_gyro;
float   angle_z_gyro;
float   angle_x_accel;
float   angle_y_accel;
float   angle_z_accel;
float   angle_x_CF;
float   angle_y_CF;
float   angle_z_CF;
float   angle_x_KF;
float   angle_y_KF;
float   angle_z_KF;

 
void setup()  { 
  size(1800, 800, P3D);
  noStroke();
  colorMode(RGB, 256); 

  String portName = "COM4";

  myPort = new Serial(this, portName, 57600);
  myPort.clear();
  myPort.bufferUntil(lf);
} 

void draw_rect_rainbow() {
  scale(90);
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
  scale(90);
  beginShape(QUADS);
  
  fill(r, g, b);
  vertex(-1,  1.5,  0.25);
  vertex( 1,  1.5,  0.25);
  vertex( 1, -1.5,  0.25);
  vertex(-1, -1.5,  0.25);

  vertex( 1,  1.5,  0.25);
  vertex( 1,  1.5, -0.25);
  vertex( 1, -1.5, -0.25);
  vertex( 1, -1.5,  0.25);

  vertex( 1,  1.5, -0.25);
  vertex(-1,  1.5, -0.25);
  vertex(-1, -1.5, -0.25);
  vertex( 1, -1.5, -0.25);

  vertex(-1,  1.5, -0.25);
  vertex(-1,  1.5,  0.25);
  vertex(-1, -1.5,  0.25);
  vertex(-1, -1.5, -0.25);

  vertex(-1,  1.5, -0.25);
  vertex( 1,  1.5, -0.25);
  vertex( 1,  1.5,  0.25);
  vertex(-1,  1.5,  0.25);

  vertex(-1, -1.5, -0.25);
  vertex( 1, -1.5, -0.25);
  vertex( 1, -1.5,  0.25);
  vertex(-1, -1.5,  0.25);

  endShape();
}

void draw()  { 
  
  background(0);
  lights();
    
  // tweaks the look of the cuboid
  int x_rotation = 90;
  
  // show gyro data
  pushMatrix(); 
  translate(width/9 + width/18, height/2, -50); 
  rotateX(radians(-angle_x_gyro - x_rotation));
  rotateY(radians(-angle_y_gyro));
  draw_rect(255, 0, 0);
  popMatrix(); 

  // show complementary filtered data
  pushMatrix();
  translate(2*width/9+3*width/18, height/2, -50);
  rotateX(radians(-angle_x_CF - x_rotation));
  rotateY(radians(-angle_y_CF));
  draw_rect(0, 255, 0);
  popMatrix();
  
  // show Kalman filtered data
  pushMatrix();
  translate(3*width/9+5*width/18, height/2, -50);
  rotateX(radians(-angle_x_KF - x_rotation));
  rotateY(radians(-angle_y_KF));
  draw_rect(0, 0, 255);
  popMatrix();
  
  // show accel data
  pushMatrix();
  translate(4*width/9+7*width/18, height/2, -50);
  rotateX(radians(-angle_x_accel - x_rotation));
  rotateY(radians(-angle_y_accel));
  draw_rect(255, 255, 255);
  popMatrix();
 
  textSize(24);
  String gyrStr = "(" + (int) angle_x_gyro + ", " + (int) angle_y_gyro + ")";
  String accStr = "(" + (int) angle_x_accel + ", " + (int) angle_y_accel + ")";
  String cfiStr = "(" + (int) angle_x_CF + ", " + (int) angle_y_CF + ")";
  String kfiStr = "(" + (int) angle_x_KF + ", " + (int) angle_y_KF + ")";
 

  fill(255, 0, 0);
  text("Gyroscope", (int) (width/9+width/18-100), 25);
  text(gyrStr, (int) (width/9 + width/18-100), 50);

  fill(0, 255, 0);
  text("Complementary filter", (int) (2*width/9+3*width/18-100), 25);
  text(cfiStr, (int) (2*width/9+3*width/18-100), 50);
  
  fill(0, 0, 255);
  text("Kalman filter", (int) (3*width/9+5*width/18-100), 25);
  text(kfiStr, (int) (3*width/9+5*width/18-100), 50);
  
  fill(255, 255, 255);
  text("Accelerometer", (int) (4*width/9+7*width/18-100), 25);
  text(accStr, (int) (4*width/9+7*width/18-100), 50);
  
  
  String dtStr = (int) dt + " µs";
  
  fill(128, 128, 128);
  text("dt", (int) (width/2), 675);
  text(dtStr, (int) (width/2), 700);
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
        /*
        print("Dt:");
        println(dt);
        */
        
      } else if (type.equals("GYR:")) {
        String data[] = split(dataval, ',');
        angle_x_gyro = float(data[0]);
        angle_y_gyro = float(data[1]);
        angle_z_gyro = float(data[2]);
      } else if (type.equals("ACC:")) {
        String data[] = split(dataval, ',');
        angle_x_accel = float(data[0]);
        angle_y_accel = float(data[1]);
      } else if (type.equals("CFI:")) {
        String data[] = split(dataval, ',');
        angle_x_CF = float(data[0]);
        angle_y_CF = float(data[1]);
      } else if (type.equals("KFI:")) {
        String data[] = split(dataval, ',');
        angle_x_KF = float(data[0]);
        angle_y_KF = float(data[1]);
      }
    }
  } catch (Exception e) {
      println("Caught Exception!");
  }
}
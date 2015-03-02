//Commenting
//Comment again

import processing.opengl.*;
import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
OpenCV opencv;

PVector p1 = new PVector();
PVector p2 = new PVector();
float distance = 0.0;
float dnow = 0.0;
float dprev = 0.0;

ArrayList<PVector> mPoints = new ArrayList<PVector>();
ArrayList<PVector> mChaos = new ArrayList<PVector>();

int radius = 100;
int time = 0;
boolean up = false;
boolean down = false;
float mS;
float mT;
float mCounter;
int strColor = 200;
final int NUMBER_OF_POINTS = 720;

float m = 0;
float count = -PI/2;


void setup() {
  size(1280, 720, OPENGL);
  background(255);
  video = new Capture(this, 640/2, 480/2);
  opencv = new OpenCV(this, 640/2, 480/2);
  //opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  contours = new ArrayList<Contour>();  
  video.start();
  
    // Array for detection colors
  colors = new int[maxColors];
  hues = new int[maxColors];
  
  outputs = new PImage[maxColors];

  stroke(0);
  mS = 0.0;
  mT = 0.0;


  for (int i=0; i<NUMBER_OF_POINTS; i++) {
    mS += 10;
    mT += 0.25;
    createPoint(mS, mT);
  }

  for (int i=0; i<NUMBER_OF_POINTS; i++) {
    PVector p = new PVector();
    p.set(mPoints.get(i));
    p.x = random(-10, 10);
    p.y = random(-10, 10);
    p.z = random(-10, 10);
    mChaos.add(p);
  }
  

}

void draw() {
  background(255);
  detect();
  stroke(0);
  translate(width/2, height/2, 0);
  rotateX(PI/2 );  
  rotateZ(mCounter * PI);
  mCounter+=1.0/frameRate;


  /*
  for (int i=1; i<mPoints.size (); i++) {
   PVector v1 = mPoints.get(i-1);
   PVector v2 = mPoints.get(i);
   line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
   }
   
   for (int i=1; i<mChaos.size (); i++) {
   PVector v1 = mChaos.get(i-1);
   PVector v2 = mChaos.get(i);
   line(v1.x, v1.y, v1.z, v2.x, v2.y, v2.z);
   }
   */

  //Kind of map(0,1) with easing
  /*
  if(up){
  count+=0.02;
  up = false;
  }
  else if(down){
  count-=0.02;
  down = false;
  }
  */
  count+=(distance);
  m = ( sin(count) + 1 ) * 0.5;
   
 
  
  for (int i=1; i<NUMBER_OF_POINTS; i++) {
    PVector v1 = mChaos.get(i-1);
    PVector v2 = mChaos.get(i);

    PVector w1 = mPoints.get(i-1);
    PVector w2 = mPoints.get(i);

    PVector f1 = new PVector();
    PVector f2 = new PVector();

    // Interpolation ----------------------------
    f1.x = w1.x + (v1.x - w1.x) * m;
    f1.y = w1.y + (v1.y - w1.y) * m;
    f1.z = w1.z + (v1.z - w1.z) * m;

    f2.x = w2.x + (v2.x - w2.x) * m;
    f2.y = w2.y + (v2.y - w2.y) * m;
    f2.z = w2.z + (v2.z - w2.z) * m;

    line(f1.x, f1.y, f1.z, f2.x, f2.y, f2.z);
  }
  
}


void createPoint(float s, float t) {

  float radianS = radians(s);
  float radianT = radians(t);

  PVector mPoint = new PVector();
  mPoint.x =  (radius * cos(radianS) * sin(radianT));
  mPoint.y =  (radius * sin(radianS) * sin(radianT));
  mPoint.z =  (radius * cos(radianT));
  mPoints.add(mPoint);
}
/*
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      up = true;
    } else if (keyCode == DOWN) {
      down = true;
    } 
  }
}
*/
/*
void video(){
  opencv.loadImage(video);

  image(video, 0, 0 );

  noFill();
  stroke(0,255,0);
 // strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  //println(faces.length);
  //println(distance);

  for (int i = 0; i < faces.length; i++) {
    //println(faces[i].x + "," + faces[i].y);
    rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
  }
  if(faces.length==2){
  p1.x = faces[0].x;
  p2.x = faces[1].x;
  
  p1.y = faces[0].y;
  p2.y = faces[1].y;
  
  p1.z = 0;
  p2.z = 0;


  
  if(frameCount%10==0){
  dnow = abs((p1.dist(p2))/1000.0);
  distance = dnow - dprev;
//  println("dnow" + dnow);
//  println("dprev" + dprev);
  println(distance);
  dprev = dnow;
  }
  }
 else
 distance = 0.0;
  
}
*/
void captureEvent(Capture c) {
  c.read();
}

void detect() {
  
  //background(150);
  
  if (video.available()) {
    video.read();
  }

  // <2> Load the new frame of our movie in to OpenCV
  opencv.loadImage(video);
  
  // Tell OpenCV to use color information
  opencv.useColor();
  src = opencv.getSnapshot();
  
  // <3> Tell OpenCV to work in HSV color space.
  opencv.useColor(HSB);
  
  detectColors();
  
  // Show images
  image(src, 0, 0);
  for (int i=0; i<outputs.length; i++) {
    if (outputs[i] != null) {
      image(outputs[i], width-src.width/4, i*src.height/4, src.width/4, src.height/4);
      
      noStroke();
      fill(colors[i]);
      rect(src.width, i*src.height/4, 30, src.height/4);
    }
  }
  
  // Print text if new color expected
  textSize(20);
  stroke(255);
  fill(255);
  
  if (colorToChange > -1) {
    text("click to change color " + colorToChange, 10, 25);
  } else {
    text("press key [1-4] to select color", 10, 25);
  }
  
  displayContoursBoundingBoxes();
}


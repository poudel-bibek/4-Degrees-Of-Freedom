import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

// Bibek: Added for the button control panel
final float BUTTON_WIDTH = 50;
final float BUTTON_HEIGHT = 50; 
final float MARGIN = inchToPix(0.15f); 
final float SPACING = inchToPix(0.05f); 


private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

PImage buttonUp, buttonDown, buttonRight, buttonLeft, buttonTurnRight, buttonTurnLeft, buttonPlus, buttonMinus;
PImage buttonUpHighlight, buttonDownHighlight, buttonRightHighlight, buttonLeftHighlight, buttonTurnRightHighlight, buttonTurnLeftHighlight, buttonPlusHighlight, buttonMinusHighlight;

float control1X = 400; //set hardcoded values, because height and width have not been set yet
float control2X = control1X + 3.5 * BUTTON_WIDTH; // Second control panel

float centerY = 735; // Common Y center for both control panels
float control1Y = centerY; // Use centerY directly to align the middle of the panel vertically

// Calculate positions for the control buttons based on the panels
float upX = control1X; // Up button X for the first control panel
float upY = centerY - BUTTON_HEIGHT - SPACING + 25; // Up button Y
float downX = control1X; // Down button X for the first control panel
float downY = centerY + BUTTON_HEIGHT + SPACING - 25; // Down button Y
float leftX = control1X - BUTTON_WIDTH - SPACING; // Left button X for the first control panel
float leftY = centerY; // Left button Y
float rightX = control1X + BUTTON_WIDTH + SPACING; // Right button X for the first control panel
float rightY = centerY; // Right button Y

float plusX = control2X; // Plus button X
float plusY = centerY - BUTTON_HEIGHT - SPACING + 25; // Plus button Y
float minusX = control2X; // Minus button X
float minusY = centerY + BUTTON_HEIGHT + SPACING - 25; // Minus button Y
float turnLeftX = control2X - BUTTON_WIDTH - SPACING; // TurnLeft button X
float turnLeftY = centerY; // TurnLeft button Y
float turnRightX = control2X + BUTTON_WIDTH + SPACING; // TurnRight button X
float turnRightY = centerY; // TurnRight button Y
  
void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  // Load button images
  buttonUp = loadImage("./assets/buttons/no_highlight/up.png");
  buttonDown = loadImage("./assets/buttons/no_highlight/down.png");
  buttonRight = loadImage("./assets/buttons/no_highlight/right.png");
  buttonLeft = loadImage("./assets/buttons/no_highlight/left.png");
  buttonTurnRight = loadImage("./assets/buttons/no_highlight/turnright.png");
  buttonTurnLeft = loadImage("./assets/buttons/no_highlight/turnleft.png");
  buttonPlus = loadImage("./assets/buttons/no_highlight/plus.png");
  buttonMinus = loadImage("./assets/buttons/no_highlight/minus.png");
  
  buttonUpHighlight = loadImage("./assets/buttons/highlight/up.png");
  buttonDownHighlight = loadImage("./assets/buttons/highlight/down.png");
  buttonRightHighlight = loadImage("./assets/buttons/highlight/right.png");
  buttonLeftHighlight = loadImage("./assets/buttons/highlight/left.png");
  buttonTurnRightHighlight = loadImage("./assets/buttons/highlight/turnright.png");
  buttonTurnLeftHighlight = loadImage("./assets/buttons/highlight/turnleft.png");
  buttonPlusHighlight = loadImage("./assets/buttons/highlight/plus.png");
  buttonMinusHighlight = loadImage("./assets/buttons/highlight/minus.png");
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  // Draw 
  drawControlPanel(buttonUp, buttonDown, buttonLeft, buttonRight, 1);
  drawControlPanel(buttonPlus, buttonMinus, buttonTurnLeft, buttonTurnRight, 2);
  
  // Perform actions based on button presses
  checkButtonActions();
}

// Bibek: Modified Helper function 0. Draw a control panel
void drawControlPanel(PImage up, PImage down, PImage left, PImage right, int panelNumber) {
 
  
  if (panelNumber == 1) {
    // Logic for the first panel (Up, Down, Left, Right)
    drawButton(up, overButton(upX - BUTTON_WIDTH / 2, upY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? buttonUpHighlight : buttonUp, upX, upY);
    drawButton(down, overButton(downX - BUTTON_WIDTH / 2, downY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? buttonDownHighlight : buttonDown, downX, downY);
    drawButton(left, leftX < control1X ? buttonLeftHighlight : buttonLeft, leftX, leftY);
    drawButton(right, rightX > control1X ? buttonRightHighlight : buttonRight, rightX, rightY);
    
  } else if (panelNumber == 2) {
    // Logic for the second panel (Plus, Minus, TurnLeft, TurnRight)
    // Adjust this logic as needed for the different layout or behavior
    drawButton(up, overButton(plusX - BUTTON_WIDTH / 2, plusY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? buttonPlusHighlight : buttonPlus, plusX,plusY);
    drawButton(down, overButton(minusX - BUTTON_WIDTH / 2, minusY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? buttonMinusHighlight : buttonMinus, minusX, minusY);
    drawButton(left, overButton(turnLeftX - BUTTON_WIDTH / 2, turnLeftY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? buttonTurnLeftHighlight : buttonTurnLeft, turnLeftX, turnLeftY);
    drawButton(right, overButton(turnRightX - BUTTON_WIDTH / 2, turnRightY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? buttonTurnRightHighlight : buttonTurnRight, turnRightX, turnRightY);
  }
}

// Bibek: Helper function 1. Draw a button based on 2 images.
void drawButton(PImage defaultImg, PImage hoverImg, float x, float y) {
  PImage imgToShow = overButton(x - BUTTON_WIDTH / 2, y - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT) ? hoverImg : defaultImg;
  image(imgToShow, x - BUTTON_WIDTH / 2, y - BUTTON_HEIGHT / 2); 
}

// Bibek: Helper function 2. Check if mouse is over button
boolean overButton(float x, float y, float width, float height) {
  return mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height;
  
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
}

// Bibek: Helper function 3. Continuously check where the mouse is pressed.
void checkButtonActions() {
  
  // Check if buttons are pressed and perform actions
  if (mousePressed && (overButton(upX - BUTTON_WIDTH / 2, upY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoY -= inchToPix(.02f);
  }
  if (mousePressed &&(overButton(downX - BUTTON_WIDTH / 2, downY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoY += inchToPix(.02f);
  }
  if (mousePressed &&(overButton(leftX - BUTTON_WIDTH / 2, leftY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoX -= inchToPix(.02f);
  }
  if (mousePressed &&(overButton(rightX - BUTTON_WIDTH / 2, rightY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoX += inchToPix(.02f);
  }
  
  // second control panel
  if (mousePressed &&(overButton(plusX - BUTTON_WIDTH / 2, plusY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {

    logoZ = constrain(logoZ + inchToPix(.02f), .01, inchToPix(4f));
  }
  if (mousePressed &&(overButton(minusX - BUTTON_WIDTH / 2, minusY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoZ = constrain(logoZ - inchToPix(.02f), .01, inchToPix(4f));
  }
  if (mousePressed &&(overButton(turnLeftX - BUTTON_WIDTH / 2, turnLeftY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoRotation--;
  }
  if (mousePressed &&(overButton(turnRightX - BUTTON_WIDTH / 2, turnRightY - BUTTON_HEIGHT / 2, BUTTON_WIDTH, BUTTON_HEIGHT))) {
    logoRotation++;
  }
 
}


void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}

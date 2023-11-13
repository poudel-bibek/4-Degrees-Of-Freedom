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

// Shiv: Added for drag and drop
boolean isDraggingLogo = false;
float dragOffsetX = 0;
float dragOffsetY = 0;

//Shiv: Submit button properties
float submitButtonX;
float submitButtonY;
float submitButtonWidth;
float submitButtonHeight;
String submitButtonText = "Submit";
boolean submitButtonOver = false;

//Shiv: variables for resizing and rotating
boolean isResizing = false;
boolean isRotating = false;
float handleSize = 15;// Size of the visible handle areas
int activeHandle = -1; // -1 for none, 0-3 for corners, 4-7 for edges
PVector initialMousePos = new PVector(0, 0); // Initial mouse position for rotation
float initialLogoZ = 0; // Initial size of the logo when resizing starts
float initialRotation = 0; // Initial rotation of the logo when rotation starts

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
  
  //Shiv: Initialize submit button properties
  submitButtonWidth = inchToPix(1.5f); // 1.5 inches wide
  submitButtonHeight = inchToPix(0.75f); // 0.75 inches tall
  submitButtonX = width - border; // Positioned from the right border
  submitButtonY = height - submitButtonHeight; // Positioned from the bottom border
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
  //Shiv: Draw the draggable square (logo)
  pushMatrix();
  translate(logoX, logoY);
  rotate(radians(logoRotation));
  fill(60, 60, 192); // Color of the square
  if (isDraggingLogo) {
    stroke(255, 255, 0); // Highlight color when dragging
  } else {
    stroke(0); // Default border color
  }
  rect(0, 0, logoZ, logoZ); // Draw the square centered on (logoX, logoY)
  popMatrix();
  
  //Shiv: Submit Button
  if (submitButtonOver) {
    fill(100, 255, 100); // Highlight color if mouse is over
  } else {
    fill(200); // Default color
  }
  noStroke();
  rect(submitButtonX, submitButtonY, submitButtonWidth, submitButtonHeight, inchToPix(0.1f)); // Slightly rounded corners
  textAlign(CENTER, CENTER);
  fill(0);
  text(submitButtonText, submitButtonX, submitButtonY + inchToPix(0.1f)); // Adjust text position to be centered on button
  
  //Shiv: Draw handles for resizing and rotating
  
  // Transform mouse coordinates to square's local coordinate system
  PVector transformedMouse = getTransformedMouse(mouseX, mouseY, logoX, logoY, logoRotation);

  handleSize = logoZ * 0.1; // For example, handles are 10% of the square size
  handleSize = constrain(handleSize, 7, 30); // Constrain size to a reasonable range
  drawHandles(logoX, logoY, logoZ, logoRotation);
  pushMatrix();
  translate(logoX, logoY);
  rotate(radians(logoRotation));
  fill(60, 60, 192);
  rect(0, 0, logoZ, logoZ);
  popMatrix();
  // Set cursor based on mouse position
  updateCursor(transformedMouse);
  
  // Display success status
  displayMatchStatus();
  //Shiv End
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
   // Transform mouse coordinates to square's local coordinate system
    PVector transformedMouse = getTransformedMouse(mouseX, mouseY, logoX, logoY, logoRotation);

    // Determine which handle (if any) is active
    activeHandle = getActiveHandle(transformedMouse, logoZ);
  //Shiv: rotate and resize with handles check
  if (activeHandle != -1) {
    if (activeHandle < 4) { // Corners
      isRotating = true;
      initialRotation = logoRotation;
      initialMousePos.set(transformedMouse);
    } else { // Edges
      isResizing = true;
      initialMousePos.set(transformedMouse);
      initialLogoZ = logoZ;
    }
  }
  //Shiv: Check if the click is within the bounds of the logo square
  else if (mouseX > logoX - logoZ/2 && mouseX < logoX + logoZ/2 && mouseY > logoY - logoZ/2 && mouseY < logoY + logoZ/2) {
    isDraggingLogo = true;
    dragOffsetX = logoX - mouseX;
    dragOffsetY = logoY - mouseY;
  }  
  if (mouseX > submitButtonX - submitButtonWidth / 2 &&
      mouseX < submitButtonX + submitButtonWidth / 2 &&
      mouseY > submitButtonY - submitButtonHeight / 2 &&
      mouseY < submitButtonY + submitButtonHeight / 2) {
    submit();
  }
  if (isRotating) {
        initialRotation = logoRotation;
        PVector center = new PVector(logoX, logoY);
        initialMousePos = new PVector(mouseX, mouseY).sub(center);
        initialMousePos.rotate(-radians(logoRotation));
    }
}

//Shiv: Added for Submit Button color
void mouseMoved() {
  // Check if the mouse is over the submit button for highlighting
  if (mouseX > submitButtonX - submitButtonWidth / 2 && mouseX < submitButtonX + submitButtonWidth / 2 && mouseY > submitButtonY - submitButtonHeight / 2 && mouseY < submitButtonY + submitButtonHeight / 2) {
    submitButtonOver = true;
  } else {
    submitButtonOver = false;
  }
}

//Shiv: The submit function has the logic that was previously in the mouseReleased function
void submit() {
  if (!userDone && !checkForSuccess()) {
    errorCount++;
  }
  trialIndex++; // Move on to next trial
  if (trialIndex == trialCount && !userDone) {
    userDone = true;
    finishTime = millis();
  }
}

//Shiv: Mouse Drag
void mouseDragged() {
  PVector transformedCurrentMouse = getTransformedMouse(mouseX, mouseY, logoX, logoY, logoRotation);
  //Shiv: for resizing
  if (isResizing) {
    // Transform current mouse coordinates to square's local coordinate system
    // Calculate the change in size based on transformed coordinates
    float sizeChange;
    switch (activeHandle) {
      case 4: // Top
        sizeChange = initialMousePos.y - transformedCurrentMouse.y;
        break;
      case 5: // Bottom
        sizeChange = transformedCurrentMouse.y - initialMousePos.y;
        break;
      case 6: // Left
        sizeChange = initialMousePos.x - transformedCurrentMouse.x;
        break;
      case 7: // Right
        sizeChange = transformedCurrentMouse.x - initialMousePos.x;
        break;
      default:
        sizeChange = 0; // Default case if no valid handle is selected
        break;
    }
    if (activeHandle == 6 || activeHandle == 7) { // Left or Right handles
        // Adjust width (if necessary, depending on how you want to handle horizontal resizing)
        logoZ = initialLogoZ + sizeChange;
    } else {
        // Adjust height
        logoZ = initialLogoZ + sizeChange * 2;
    }
    logoZ = max(logoZ, 10); // Prevent the square from disappearing
  }
  //Shiv: For rotate
  else if (isRotating) {
    PVector center = new PVector(logoX, logoY);
    PVector prevVec = new PVector(pmouseX, pmouseY).sub(center);
    PVector currentVec = new PVector(mouseX, mouseY).sub(center);
    // Calculate the angle between the previous and current vectors
    float angleDelta = atan2(currentVec.y, currentVec.x) - atan2(prevVec.y, prevVec.x);
    // Normalize the angle delta to avoid jumps
    if (angleDelta > PI) {
        angleDelta -= TWO_PI;
    } else if (angleDelta < -PI) {
        angleDelta += TWO_PI;
    }
    // Apply the angle delta to the rotation
    logoRotation += degrees(angleDelta);
}
  //Shiv: Drag and update position
  else if (isDraggingLogo) {
    logoX = mouseX + dragOffsetX;
    logoY = mouseY + dragOffsetY;
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
  //Shiv: Stop Dragging+rotate+resize
    isDraggingLogo = false;
    isResizing = false;
    isRotating = false;
    activeHandle = -1;
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

// Shiv: to draw handles
void drawHandles(float x, float y, float size, float rotation) {
  pushMatrix();
  translate(x, y);
  rotate(radians(rotation));
  fill(255, 0, 0); // Red color for handles
  ellipse(-size/2, -size/2, handleSize, handleSize); // Top-left
  ellipse(size/2, -size/2, handleSize, handleSize); // Top-right
  ellipse(-size/2, size/2, handleSize, handleSize); // Bottom-left
  ellipse(size/2, size/2, handleSize, handleSize); // Bottom-right
  ellipse(0, -size/2, handleSize, handleSize); // Top
  ellipse(0, size/2, handleSize, handleSize); // Bottom
  ellipse(-size/2, 0, handleSize, handleSize); // Left
  ellipse(size/2, 0, handleSize, handleSize); // Right
  popMatrix();
}

//Shiv: Active Handle
int getActiveHandle(PVector mouse, float size) {
    // Check if mouse is over any corner handle for rotation
    if (dist(mouse.x, mouse.y, -size/2, -size/2) < handleSize / 2) return 0; // Top-left
    if (dist(mouse.x, mouse.y, size/2, -size/2) < handleSize / 2) return 1; // Top-right
    if (dist(mouse.x, mouse.y, -size/2, size/2) < handleSize / 2) return 2; // Bottom-left
    if (dist(mouse.x, mouse.y, size/2, size/2) < handleSize / 2) return 3; // Bottom-right

    // Check if mouse is over any edge handle for resizing
    if (dist(mouse.x, mouse.y, 0, -size/2) < handleSize / 2) return 4; // Top
    if (dist(mouse.x, mouse.y, 0, size/2) < handleSize / 2) return 5; // Bottom
    if (dist(mouse.x, mouse.y, -size/2, 0) < handleSize / 2) return 6; // Left
    if (dist(mouse.x, mouse.y, size/2, 0) < handleSize / 2) return 7; // Right

    return -1; // No active handle
}

PVector getTransformedMouse(float mouseX, float mouseY, float x, float y, float rotation) {
    PVector mouse = new PVector(mouseX, mouseY);
    PVector center = new PVector(x, y);
    mouse.sub(center);
    mouse.rotate(-radians(rotation));
    return mouse;
}

void updateCursor(PVector transformedMouse) {
    int handle = getActiveHandle(transformedMouse, logoZ);

    if (isMouseOverSquare(transformedMouse, logoZ)) {
        cursor(MOVE);
    } else if (handle >= 0 && handle < 4) {
        cursor(HAND); // Rotate cursor (hand cursor as a placeholder)
    } else if (handle >= 4) {
        cursor(CROSS); // Resize cursor
    } else {
        cursor(ARROW);
    }
}
  
boolean isMouseOverSquare(PVector mouse, float size) {
    return mouse.x > -size / 2 && mouse.x < size / 2 && mouse.y > -size / 2 && mouse.y < size / 2;
}

void displayMatchStatus() {
    boolean isSuccess = checkForSuccess();
    String statusText = isSuccess ? "True" : "False";
    if (isSuccess) {
        fill(0, 255, 0); // Green text for "True"
    } else {
        fill(255, 0, 0); // Red text for "False"
    }
    textAlign(RIGHT, TOP);
    textSize(20);
    text("Match: " + statusText, width - 10, 10); // Display in the top right corner
}

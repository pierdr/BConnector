
var turnLEDon = false;
var flashLED  = false;
var allOff    = false;
var registeredButton = false; 
var boardNumber = -1;

function setup() {
   createCanvas(windowWidth, windowHeight);
   connector.getInstance().setupSocket("172.16.3.218:9092");
   
}

function draw() {
  background(55,66,187);
  
  text("hello world",20,30);
  noStroke();
  
  if(connector.getInstance().status=="OPENED" && !registeredButton){

      connector.getInstance().registerOrientation(0);
      registeredButton=true;
  }
  if(connector.getInstance().status=="OPENED")
  {
    if(connector.getInstance().buttonRegistered)
    {
      if(connector.getInstance().buttonState)
      {
          rect(30,20,100,100);
      }
    }
  }
/*  if(millis()>1000 && connector.getInstance().status=="OPENED" && !turnLEDon)
  {
  	console.log("led");
  	turnLEDon = true;
  	connector.getInstance().setColor(0,0,128,0,255);
  }

  if(millis()>2000 && !flashLED) 
  {
    console.log("flash");
    connector.getInstance().flashColor(2,128,0,128,3);
    flashLED = true;

  }
  if(millis()>5000 && !allOff) 
  {
    console.log("vibrate");
    connector.getInstance().makeVibrate(0);
    connector.getInstance().setColor(0,0,0,0,255);
/*
    connector.getInstance().makeVibrate(2);
    connector.getInstance().setColor(2,0,0,0,255);
    allOff = true;

  }*/

  
}




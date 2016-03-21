
var turnLEDon = false;
var flashLED  = false;
var allOff    = false;

function setup() {
   createCanvas(windowWidth, windowHeight);
   connector.getInstance().setupSocket("192.168.1.6:9092");
   
}

function draw() {
  background(55,66,187);
  
  text("hello world",20,30);
  noStroke();
  if(millis()>1000 && connector.getInstance().status=="OPENED" && !turnLEDon)
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
    connector.getInstance().setColor(2,0,0,0,255);*/
    allOff = true;

  }

  
}




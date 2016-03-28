
var registeredButton = false; 
var boardNumber = 0;

function setup() {
   createCanvas(windowWidth, windowHeight);

   connector.getInstance().setupSocket("10.0.1.12:9092");
   
}

function draw() {
  background(55,66,255);
  
  text("hello world",20,30);
  ellipse(10,10,10,10);
  noStroke();
  
  if(connector.getInstance().status=="OPENED" && !registeredButton){

      connector.getInstance().registerOrientation(boardNumber);
     // connector.getInstance().getRSSI(0);
     connector.getInstance().setColor(0,0,0,1);
     connector.getInstance().setColor(4,0,0,1);
      registeredButton=true;
  }
  if(connector.getInstance().status=="OPENED")
  {
    if(connector.getInstance().orientationRegistered)
    {
      if(connector.getInstance().orientation.indexOf("Portrait")!=-1)
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




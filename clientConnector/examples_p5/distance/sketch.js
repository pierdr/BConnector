
var started = false;
var eventTimed=0;

function setup() {
   createCanvas(windowWidth, windowHeight);
  BFc.setupSocket("192.168.137.60:9092");
   frameRate(25); 

}

function draw() {
  background(230);


if(BFc.status=="OPENED")
  {
 	if(millis()-eventTimed>500)
 	{
 		eventTimed=millis();
 		BFc[3].getRSSI();
 	}
  }

  if(BFc[3].rssi>=-50)
  {
  	fill(0,230,0);
  	noStroke();
	rect(0,0,20,20);
	closebyAway();
  }
  if(BFc[3].rssi<-50 && BFc[3].rssi>=-60)
  {
  	fill(0,230,230);
  	noStroke();
	rect(0,0,20,20);
	midAway();
	
  }
  if(BFc[3].rssi<-60&& BFc[3].rssi>=-68)
  {
  	fill(230,0,230);
  	noStroke();
	rect(0,0,20,20);
	midAway();

  }
   if(BFc[3].rssi<-68 && BFc[3].rssi>=-80)
  {
  	fill(230,10,101);
  	noStroke();
	rect(0,0,20,20);
	farAway();
  }
  if(BFc[3].rssi<-80 &&  BFc[3].rssi>=-90)
  {
	
	fill(230,0,0);
  	noStroke();
	rect(0,0,20,20);
	farAway();
  }
  if(BFc[3].rssi<-90)
  {
  	farfarAway();
  }
  
}

function farAway(){

  fill(0,0,0);
  textSize(9);
  text(floor(BFc[3].rssi),5,10);

  fill(0,0,0);
  textSize(150);
  var sec = second();
  if(sec<10)
  {
  	sec="0"+sec;
  }
  var min = minute();
  if(min<10)
  {
  	min="0"+min;
  }
  textAlign(CENTER);
  text(hour()+":"+min+":"+sec,windowWidth/2,windowHeight/2);
}

function farfarAway(){

 background(0);
}


function midAway(){

  fill(0,0,0);
  textSize(9);
  text(floor(BFc[3].rssi),5,10);

  fill(0,0,0);
  textSize(60);
  
  textAlign(CENTER);
  text("Lorem ipsum dolor sit amet,",windowWidth/2,windowHeight/2-200);
  text("consectetur adipiscing elit.",windowWidth/2,windowHeight/2);
}

function closebyAway(){

  fill(0,0,0);
  textSize(9);
  text(floor(BFc[3].rssi),5,10);

  fill(0,0,0);
  textSize(30);
  

  textAlign(CENTER);
  var a = windowHeight/7;
  text("Lorem ipsum dolor sit amet,\n consectetur adipiscing elit.",windowWidth/2,a);
  text("Lorem ipsum dolor sit amet,\n consectetur adipiscing elit.",windowWidth/2,a*2);
  text("Lorem ipsum dolor sit amet,\n consectetur adipiscing elit.",windowWidth/2,a*3);
  text("Lorem ipsum dolor sit amet,\n consectetur adipiscing elit.",windowWidth/2,a*4);
  text("Lorem ipsum dolor sit amet,\n consectetur adipiscing elit.",windowWidth/2,a*5);
}


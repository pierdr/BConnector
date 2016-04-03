
var registerSomething = false; 
var boardNumber = 0;

function setup() {
   createCanvas(windowWidth, windowHeight);

   BFc.setupSocket("192.168.137.30:9092");
   
}

function draw() {
  background(55,66,255);
  
  text("hello world",20,30);
  ellipse(10,10,10,10);
  noStroke();
  
  if(connector.getInstance().status=="OPENED" && !registerSomething){
    registerSomething = true;
    BFc.registerShake(3);
     
  }
  if(BFc.status=="OPENED" && registerSomething)
  {
    console.log( BFc[3].shaked );
    if(BFc[3].shaked)
    {
      ellipse(0,0,windowWidth,windowHeight);
    }
  }
  
}




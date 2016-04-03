var didSomething = false;

function setup() {
   createCanvas(windowWidth, windowHeight);

   BFc.setupSocket("192.168.137.30:9092");
   
}

function draw() {
  background(55,66,255);
  
  if(connector.getInstance().status=="OPENED" && !didSomething){
    BFc[3].flashColor(0,255,0,3);
    didSomething = true;
       
  }  
}




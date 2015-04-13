var started=false;

function setup() {
   createCanvas(900, 900);
   gem.getInstance().setupSocket();
   frameRate(30); 
}
function loop()
{
  if(gem.getInstance().status=="OPENED" && !started)
  {
    gem.getInstance().registerAccelerometer();
  }
}
function draw() {
  
    background(255);
    ellipse(100,100,map(gem.getInstance().accelerometer.y,-1024,1024,0,100),map(gem.getInstance().accelerometer.y,-1024,1024,0,100));
  
}



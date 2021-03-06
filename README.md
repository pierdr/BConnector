#BF Educational kit
##### Teaching prototyping for **interactive spaces** and **smart objects** 


This kit is meant to make simple for designers and developers the access to physical prototyping. Bluetooth low energy is becoming the common standard for low power physical computing, at the moment the entry barriers for touching this technology are quite high because of it's low level access from smartphone devices. 

The kit allows the access of multible boards simply from web apps.


## How To Get Started
####Download repository

Git user can follow these steps in the terminal:

- navigate to the location where you want to copy the repository;
- type ```git clone https://github.com/pierdr/BFConnector.git```


otherwhise just download this repo from github.
 
The library is suited both for recursive logic (like p5js) and event based logic (js/jquery).
 
#####p5js
Following the sample sketch (available in the folder _sample\_p5_) for p5js with recursive logic:

```javascript
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
```

#####javascript/jquery
In event based programming remember to open the socket before calling it (available in the folder _sample\_p5_):

```javascript
$(function(){
      BFc.setupSocket("192.168.137.30:9092"); 
});
```
The HTML looks like:

```html
 <button onclick="BFc[3].flashColor(0,0,255,3);" style="margin:100px">FLASH LED 3 TIMES</button>
```
 
####Run the server (Optional)

######Mac OS X 
- Navigate to client connector ```cd BFConnector/clientConnector```
- Start the webserver with the command: ```python -m SimpleHTTPServer 8000```
- Open your browser and go to the url ```http://localhost:8000/sample/``` to check that is working.

In the folder clientConnector you can duplicate the _sample_ folder and rename it as you like. 

Open your browser and go to the url ```http://localhost:8000/yourname/```.


The server is not necessary but just nice to have.




## Reference
<p align="center" >
  <img src="archive/BFEducationalKit.png" alt="AFNetworking" title="AFNetworking">
</p>



### __`connector` object__

The connector object is a singleton that abstracts the controller of the ble modules. 


```javascript
BFc
```


##### Attributes

`status`  _INIT_, _OPENED_, _RUNNING_, _CLOSED_, _ERROR_

```javascript
if(BFc.status=="OPENED")
{
	background(12,255,23);
}

```

__utility methods__  
 
`setupSocket(socketAddress)`   start the communication with a socket address in the form `"192.168.1.17:9092"` (the server is receiving on port 9092)  


### __`gem` object__

Every single board connected is abstracted via a gem object that is accessible via the BFc object.
```javascript
if(BFc[3].rssi>-50)
{
	console.log("It's close!");
}
```

##### Attributes

`buttonState` true is pressed, false is up

`buttonRegistered` true or false

`temperature` eg 24.25

`freeFallRegistered` true or false

`freeFall` true if in free fall

`tapRegistered` true or false

`tap` true if tap is sensed

`shakeRegistered` true or false

`shaked` true if shake is sensed

`orientationRegistered` true or false

`orientation` "Portrait","PortraitUpsideDown","LandscapeLeft","LandscapeRight"

`rssi` signal strength, negative integer with closer to 0 = closer to connector

`batteryLevel` 0 to 100

##### Methods

__actuator methods__   
`setColor(deviceNumber,red,green,blue,intensity)` set the color the led of one board. _deviceNumber_ is an integer between 0 and 4, the components _red_, _green_, _blue_ and _intensity_ are integers between 0 and 255

`makeVibrate(duration)` _deviceNumber_ is an integer between 0 and 5, it will create a vibration

__get methods__ 

`getTemperature()`  

`getRSSI()`  

`getBatteryLevel()`


__sensor methods__ 

Sensors are organized with an observer pattern logic. 
You can register to observe a sensor, when done you can release it.

`registerButton()`  
`releaseButton()`  

`registerShake()`  
`releaseShake()`

`registerFreeFall()`  
`releaseFreeFall()`

`registerOrientation()`  
`releaseOrientation()`

`registerTap()`  
`releaseTap()`


### global methods
Global methods are called by the library when any of these events happen.

`shaked()`

`tapped()`

`orientationChanged(deviceOrientation)`

`isFalling()`

`buttonPressed()`





--
###History

The project is forked from *designing connected experiences with ble* ([workshop description](http://resonate.io/2015/education/designing-connected-experiences-with-ble/)) hosted by Tellart during Resonate 2015.








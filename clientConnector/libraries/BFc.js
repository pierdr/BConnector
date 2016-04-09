/*******   
Started by Tellart for Resonate 2015

Further developed by Pierluigi Dalla Rosa @binaryfutures
*******/

var MAX_NUM_BOARDS = 20;

var  connector= (function () {
    var instance;
 
    function createInstance() {
        var object = new Object();

        object.socket 				= new Object();
        object.status 			   	= "INIT";


       

        object.setupSocket = function(socketAddress){
			
			if(socketAddress=="")
			{
				socketAddress = "192.168.1.:9092";
			}

			if (BrowserDetect.browser == "Firefox") {
				object.socket = new MozWebSocket(get_appropriate_ws_url(socketAddress));
			} else {
				object.socket = new ReconnectingWebSocket(get_appropriate_ws_url(socketAddress));
			}
			
			// open
			try {
				object.socket.onopen = function() {
					
					object.status = "OPENED";
					try{
						socketOpened();
					}
					catch(e)
					{

					}
				} 


				// received message
				object.socket.onmessage =function got_packet(msg) {
					
					messageObject = JSON.parse(msg.data);
					boardNumReceived = messageObject["boardNum"]-0;
					console.info("::: ----> received:\""+messageObject["message"]+"\"");
					if(( (object[boardNumReceived]==undefined)) && boardNumReceived!=undefined)
						{
							object[boardNumReceived] = new gemObject();
						}
					if(messageObject["message"]=="buttonEvent")
					{

						if(messageObject["value"]==0 || messageObject["value"]=="0")
						{
							
							object[boardNumReceived].buttonState = false;
						}
						else
						{
								
							object[boardNumReceived].buttonState = true;						
						}
						try{
					        buttonPressed();
						}
						catch(e)
						{
							
						}
						return;
					}
					else if(messageObject["message"] == "rssiGet")
					{
						object[boardNumReceived].rssi = messageObject["value"];
					}
					else if(messageObject["message"] == "temperatureGet")
					{
						object[boardNumReceived].temperature = messageObject["value"];
					}
					else if(messageObject["message"] == "tapEvent")
					{
						object[boardNumReceived].tap = true;
						window.setTimeout(function(){
								object[boardNumReceived].tap = false;
						},100);

						try{
					        tapped();
						}
						catch(e)
						{
							
						}
					}
					else if(messageObject["message"] == "batteryGet")
					{
						object[boardNumReceived].batteryLevel = messageObject["value"];

					}
					else if(messageObject["message"] == "freeFallEvent")
					{
						object[boardNumReceived].freeFall = true;
						window.setTimeout(function(){
								object[boardNumReceived].freeFall = false;
						},500);
						try{
					        isFalling();
						}
						catch(e)
						{
							
						}
					}
					else if(messageObject["message"] == "orientationEvent")
					{
						object.orientation = messageObject["value"];

						try{
					        orientationChanged(object.orientation);
						}
						catch(e)
						{
							
						}
					}
					else if(messageObject["message"] == "shakeEvent")
					{
						
						object[boardNumReceived].shaked = true;
						//console.log(Date.now());
						window.setTimeout(function(){
								
							object[boardNumReceived].shaked = false;
						},100);

						try{
					        shaked();
						}
						catch(e)
						{
							
						}
					}else if(messageObject["message"] == "error")
					{
						console.warn(messageObject["type"]);
					}
					else if(messageObject["message"] == "bleAssigned")
					{
						object.status = "RUNNING"
						object.boardNumber = messageObject["number"];
						try{
					        initDevice(object.boardNumber);
						}
						catch(e)
						{
							
						}
					}
					else if(messageObject["message"] == "test")
					{
						console.log(Date.now());
					}
				}

				object.socket.onclose = function(){
					object.status = "CLOSED";
					console.warn("connection:"+object.status);
					object.boardNumber = -1;
				}
				object.socket.onerror = function(){
					object.status = "ERROR";
				}
				
			} catch(exception) {
				alert('<p>Error' + exception);  
				object.status = "ERROR";
			}
		}

		object.checkIfGemExists=function(boardNum)
		{
			if(( (object[boardNum]==undefined)) && boardNum!=undefined)
			{
				object[boardNum] = new gemObject(boardNum);
			}
		}


		object.flashColor = function(deviceNumber,red,green,blue,numberOfFlashes)
		{
			object.checkIfGemExists(deviceNumber);
			if(arguments.length == 5)
			{	
				
				var message="{\"message\":\"flashColor\",\"device\":\""+deviceNumber+"\",\"red\":\""+red+"\",\"blue\":\""+blue+"\",\"green\":\""+green+"\",\"numberOfFlashes\":\""+numberOfFlashes+"\"}";
				this.sendMessage(message);
				
			}
			else
			{
				console.warn("flashColor requires 5 variables");
				
			}
		}


		object.setColor = function(deviceNumber,red,green,blue,intensity)
		{
			object.checkIfGemExists(deviceNumber);
			if(arguments.length == 5)
			{	
				
				var message="{\"message\":\"setColor\",\"device\":\""+deviceNumber+"\",\"red\":\""+red+"\",\"blue\":\""+blue+"\",\"green\":\""+green+"\",\"intensity\":\""+intensity+"\"}";
				

				this.sendMessage(message);
				
			}
			else if(arguments.length == 4)
			{
				var message="{\"message\":\"setColor\",\"device\":\""+deviceNumber+"\",\"red\":\""+arguments[1]+"\",\"blue\":\""+arguments[2]+"\",\"green\":\""+arguments[3]+"\",\"intensity\":\"255\"}";
				
				this.sendMessage(message);
				
			}
		}
		object.grantAccess = function()
		{
			console.warn("connector :: grantAccess :: discontinued");
			return;
			var message="{\"message\":\"grantAccess\"}";
			this.sendMessage(message);
			
		}
		object.revokeAccess = function()
		{
			console.warn("connector :: revokeAccess :: discontinued");
			return;
			var message="{\"message\":\"revokeAccess\"}";
			this.sendMessage(message);
			
		}

		object.getBatteryLevel = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: readBatteryLevel :: no device number");
				return;
			}
			var message="{\"message\":\"getBatteryLevel\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
			
		}
		object.getRSSI = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: readRSSI :: no device number");
				return;
			}
			var message="{\"message\":\"getRSSI\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
			
		}
		object.registerButton = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerButton :: no device number");
				return;
			}
			var message="{\"message\":\"registerButton\",\"device\":\""+deviceNumber+"\"}";
			this.buttonRegistered = true;
			this.sendMessage(message);
			
		}
		object.getTemperature = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: getTemperature :: no device number");
				return;
			}
			var message="{\"message\":\"getTemperature\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
			object.temperatureRegistered = true;

		}
		object.releaseTemperature= function(){
			object.checkIfGemExists(deviceNumber);
			console.warn("connector :: releaseTemperature :: discontinued");
			return;
			var message="{\"message\":\"releaseTemperature\"}";
			this.sendMessage(message);
			object.temperatureRegistered = false;
		}
		
		object.registerShake = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerShake :: no device number");
				return;
			}
			var message="{\"message\":\"registerShake\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);

		}

		object.releaseShake= function(deviceNumber){
			object.checkIfGemExists(deviceNumber);
			var message="{\"message\":\"releaseShake\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerFreeFall = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerFreeFall :: no device number");
			}
			var message="{\"message\":\"registerFreeFall\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.releaseFreeFall= function(deviceNumber){
			object.checkIfGemExists(deviceNumber);
			var message="{\"message\":\"releaseFreeFall\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerTap = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerTap :: no device number");
			}
			var message="{\"message\":\"registerTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.releaseTap= function(deviceNumber){
			object.checkIfGemExists(deviceNumber);
			var message="{\"message\":\"releaseTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerDoubleTap = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerDoubleTap :: no device number");
			}
			var message="{\"message\":\"registerDoubleTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.releaseDoubleTap= function(deviceNumber){
			object.checkIfGemExists(deviceNumber);
			var message="{\"message\":\"releaseDoubleTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerOrientation = function(deviceNumber)
		{
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerOrientation :: no device number");
			}
			var message="{\"message\":\"registerOrientation\",\"device\":\""+deviceNumber+"\"}";
			object.orientationRegistered = true;
			this.sendMessage(message);
		}
		object.releaseOrientation= function(deviceNumber){
			object.checkIfGemExists(deviceNumber);
			var message="{\"message\":\"releaseOrientation\",\"device\":\""+deviceNumber+"\"}";
			object.orientationRegistered = false;
			this.sendMessage(message);
		}
		object.makeVibrate= function(deviceNumber,duration){
			object.checkIfGemExists(deviceNumber);
			if(deviceNumber==undefined)
			{
				console.warn("connector :: makevibrate :: no device number");
			}
			
			var message;
			if(duration != "" && duration != undefined && duration != '')
			{
				message="{\"message\":\"makeVibrate\",\"device\":\""+deviceNumber+"\",\"duration\":\""+duration+"\"}";
			}
			else
			{
				message="{\"message\":\"makeVibrate\",\"device\":\""+deviceNumber+"\"}";
			}
			
			this.sendMessage(message);
		}
		object.makeVibrateWithOptions= function(length,amplitude,deviceNumber){
			object.checkIfGemExists(deviceNumber);
			console.warn("connector :: makeVibrateWithOptions not supoorted");
			return;
			if(length=="" || length==undefined)
			{
				length=500;
			}
			var message;
			if(arguments.length==3)
			{
				message="{\"message\":\"makeVibrate\",\"device\":\""+deviceNumber+"\",\"withLength\":\""+length+"\",\"withAmplitude\":\""+amplitude+"\"}";
			}
			else
			{
				message="{\"message\":\"makeVibrate\",\"device\":\""+object.boardNumber+"\",\"withLength\":\""+arguments[0]+"\",\"withAmplitude\":\""+arguments[1]+"\"}";	
			}
			console.log(message);
			this.sendMessage(message);
		}

		object.releaseButton= function(deviceNumeber){
			object.checkIfGemExists(deviceNumber);
			var message="{\"message\":\"releaseButton\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
			this.buttonRegistered = false;
		}
		
		object.sendMessage = function(message){
			try{
				object.socket.send(message);
			}
			catch(e)
			{
				console.warn("communication error: "+e);
			}

		}



        return object;
    }
    return {
        getInstance: function () {
            if (!instance) {
                instance = createInstance();
            }
            return instance;
        }
    };
})();

window.BFc = connector.getInstance();


var gemObject = function(gemNumber)
{
	this.gemNum					= gemNumber;

	this.freeFallRegistered 	= false;
	this.freeFall				= false;

	this.buttonRegistered   	= false;
    this.buttonState      		= false;
       
    this.temperatureRegistered 	= false;
    this.temperature           	= -1;
        
    this.freeFallRegistered    = false;
    this.freeFall              = false;

    this.tapRegistered 		 	= false;
    this.tap					= false;

    this.doubleTapRegistered 	= false;
    this.tap					= false;

    this.shakeRegistered		= false;
    this.shaked 				= false;

    this.orientationRegistered 	= false;
    this.orientation			= "";

    this.rssi					= -1;

    this.batteryLevel			= -1;


    //*** ACTUATORS' METHODS ***//
    this.setColor=function(r,g,b)
    {
    	BFc.setColor(this.gemNum,r,b,g);
    }
    this.flashColor=function(r,g,b,numOfFlashes)
    {
    	BFc.flashColor(this.gemNum,r,g,b,numOfFlashes);
    }
	this.makeVibrate=function(duration)
    {
    	BFc.makeVibrate(this.gemNum,duration);
    }

    this.makeVibrate=function(duration)
    {
    	BFc.makeVibrate(this.gemNum,duration);
    }

    //*** GET METHODS***//
    this.getRSSI = function()
    {
    	BFc.getRSSI(this.gemNum);
    }
    this.getBatteryLevel = function()
    {
    	BFc.getBatteryLevel(this.gemNum);
    }
    this.getTemperature = function()
    {
    	BFc.getTemperature(this.gemNum);
    }

    //*** SENSORS' METHODS ***//
    /**TAP**/
    this.registerTap 			= function(){this.tapRegistered=true;     ;BFc.registerTap(this.gemNum);}
    this.releaseTap 			= function(){this.tapRegistered=false;     ;BFc.releaseTap(this.gemNum);}
    /**DOUBLETAP**/
    this.registerDoubleTap 		= function(){this.doubleTapRegistered =true;    ;BFc.registerDoubleTap(this.gemNum);}
    this.releaseDoubleTap 		= function(){this.doubleTapRegistered =false;     ;BFc.releaseDoubleTap(this.gemNum);}
    /**ORIENTATION**/
    this.registerOrientation 	= function() {this.orientationRegistered=true;    ;BFc.registerOrientation(this.gemNum);}
    this.releaseOrientation  	= function() {this.orientationRegistered=false;     ;BFc.releaseOrientation(this.gemNum);}
    /**SHAKE**/
    this.registerShake 			= function(){this.registerShake=true;     ;BFc.registerShake(this.gemNum);}
    this.releaseShake 			= function(){this.registerShake=false;     ;BFc.releaseShake(this.gemNum);}
    /**FREEFALL**/
    this.registerFreeFall 		= function() { this.freeFallRegistered=true;     ;BFc.registerFreeFall(this.gemNum);}
    this.releaseFreeFall  		= function() { this.freeFallRegistered=false;     ;BFc.releaseFreeFall(this.gemNum);}
     /**BUTTON**/
    this.registerButton			= function() { this.buttonRegistered=true;     ;BFc.registerButton(this.gemNum);}
    this.releaseButton  		= function() { this.buttonRegistered=false;     ;BFc.releaseButton(this.gemNum);}

   

}
//INIT GEMS
for(var i=0;i<MAX_NUM_BOARDS;i++)
{
	BFc.checkIfGemExists(i);
}



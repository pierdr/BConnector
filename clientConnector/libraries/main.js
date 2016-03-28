/*******   
Started by Pierluigi Dalla Rosa @Tellart for Resonate 2015

Further developed by Pierluigi Dalla Rosa @binaryfutures
*******/


var  connector= (function () {
    var instance;
 
    function createInstance() {
        var object = new Object();

        object.socket 				= new Object();
        object.status 			   	= "INIT";

        object.boardNumber          = -1;

        object.buttonState      	= false;
        object.buttonRegistered   	= false;

        object.temperatureRegistered = false;
        object.temperature           = "";
        
        object.freeFallRegistered    = false;
        object.freeFall              = false;

        object.tapRegistered 		 = false;
        object.tap					 = false;

        object.shakeRegistered		 = false;
        object.shaked 				 = false;

        object.orientationRegistered = false;
        object.orientation			 = "";

        object.rssi					 = -1;

        object.batteryLevel			 = -1;

        object.setupSocket = function(socketAddress){
			// setup websocket
			// get_appropriate_ws_url is a nifty function by the libwebsockets people
			// it decides what the websocket url is based on the broswer url
			// e.g. https://mygreathost:9099 = wss://mygreathost:9099
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
				} 


				// received message
				object.socket.onmessage =function got_packet(msg) {
					console.log(msg);
					messageObject = JSON.parse(msg.data);

					if(messageObject["message"]=="buttonEvent")
					{
						if(messageObject["value"]==0 || messageObject["value"]=="0")

						{
							object.buttonState=false;
						}
						else
						{
							object.buttonState=true;
							
							
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
						object.rssi = messageObject["value"];
					}
					else if(messageObject["message"] == "temperatureGet")
					{
						object.temperature = messageObject["value"];
					}
					else if(messageObject["message"] == "tapEvent")
					{
						object.tap = true;
						window.setTimeout(function(){
								object.tap = false;
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
						object.batteryLevel = messageObject["value"];
					}
					else if(messageObject["message"] == "freeFallEvent")
					{
						object.freeFall = true;
						window.setTimeout(function(){
								object.freeFall = false;
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
						object.shaked = true;
						window.setTimeout(function(){
								object.shaked = false;
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
		object.flashColor = function(deviceNumber,red,green,blue,numberOfFlashes)
		{
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
			if(arguments.length == 5)
			{	
				
				var message="{\"message\":\"setColor\",\"device\":\""+deviceNumber+"\",\"red\":\""+red+"\",\"blue\":\""+blue+"\",\"green\":\""+green+"\",\"intensity\":\""+intensity+"\"}";
				

				this.sendMessage(message);
				
			}
			else
			{
				var message="{\"message\":\"setColor\",\"device\":\""+object.boardNumber+"\",\"red\":\""+arguments[0]+"\",\"blue\":\""+arguments[1]+"\",\"green\":\""+arguments[2]+"\",\"intensity\":\""+arguments[3]+"\"}";
				
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
			
			console.warn("connector :: releaseTemperature :: discontinued");
			return;
			var message="{\"message\":\"releaseTemperature\"}";
			this.sendMessage(message);
			object.temperatureRegistered = false;
		}
		
		object.registerShake = function(deviceNumber)
		{
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerShake :: no device number");
				return;
			}
			var message="{\"message\":\"registerShake\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);

		}

		object.releaseShake= function(deviceNumber){

			var message="{\"message\":\"releaseShake\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerFreeFall = function(deviceNumber)
		{
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerFreeFall :: no device number");
			}
			var message="{\"message\":\"registerFreeFall\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.releaseFreeFall= function(deviceNumber){
			var message="{\"message\":\"releaseFreeFall\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerTap = function(deviceNumber)
		{
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerTap :: no device number");
			}
			var message="{\"message\":\"registerTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.releaseTap= function(deviceNumber){
			
			var message="{\"message\":\"releaseTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerDoubleTap = function(deviceNumber)
		{
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerDoubleTap :: no device number");
			}
			var message="{\"message\":\"registerDoubleTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.releaseDoubleTap= function(deviceNumber){
			
			var message="{\"message\":\"releaseDoubleTap\",\"device\":\""+deviceNumber+"\"}";
			this.sendMessage(message);
		}
		object.registerOrientation = function(deviceNumber)
		{
			if(deviceNumber==undefined)
			{
				console.warn("connector :: registerOrientation :: no device number");
			}
			var message="{\"message\":\"registerOrientation\",\"device\":\""+deviceNumber+"\"}";
			object.orientationRegistered = true;
			this.sendMessage(message);
		}
		object.releaseOrientation= function(deviceNumber){
			
			var message="{\"message\":\"releaseOrientation\",\"device\":\""+deviceNumber+"\"}";
			object.orientationRegistered = false;
			this.sendMessage(message);
		}
		object.makeVibrate= function(deviceNumber,duration){

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
				console.warn("error in communicating with the connector");
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

function clamp(value, minVal, maxVal)
{
	if(value<minVal)
	{
		value = minVal;
		return value;
	}
	if(value>maxVal)
	{
		value = maxVal;
		return value;
	}
	return value;
}
 

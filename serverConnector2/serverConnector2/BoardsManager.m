//
//  BoardsManager.m
//  serverConnector2
//
//  Created by Pierluigi Dalla Rosa on 3/16/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import "BoardsManager.h"


#define CLAMP(x, low, high) ({\
__typeof__(x) __x = (x); \
__typeof__(low) __low = (low);\
__typeof__(high) __high = (high);\
__x > __high ? __high : (__x < __low ? __low : __x);\
})

@implementation BoardsManager
+ (id)sharedManager {
    
    static BoardsManager *sharedMyManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
-(id)init{
    self = [super init];
    _deviceUUIDS=[NSArray arrayWithObjects:@"CADD0E85-70A5-C31F-434C-9899987DA446",@"C48030C3-AE8E-1E19-7D19-2597E78D4F56",@"FD8EC4DA-04F4-92F5-4553-97B79C748785",@"F06681D0-206C-260E-3AD0-E56D3DF8F0D6",@"66CD7A06-EC82-27AD-C4E0-F693A95117C3",nil];
    _bleModules = [NSMutableArray array];
    for (int i=0; i<MAX_NUM_OF_DEVICES; i++) {
        [_bleModules addObject:@""];
    }
    
    [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:NO handler:^(NSArray *array) {
        for (MBLMetaWear *device in array) {
            NSLog(@"Found MetaWear: %@", device.identifier);
            for(int i=0;i<MAX_NUM_OF_DEVICES;i++)
            {
                if([device.identifier.UUIDString isEqualToString:[_deviceUUIDS objectAtIndex:i]])
                {
                    //connect
                    [device connectWithHandler:^(NSError *error) {
                        if (!error) {
                            
                            [device rememberDevice];
                            if (device.isGuestConnection) {
                               // [device setConfiguration:nil handler:nil];
                                NSLog(@"it's guest");
                            }
                            // Hooray! We connected to a MetaWear board, so flash its LED!
                            [device.led flashLEDColorAsync:[UIColor greenColor] withIntensity:1.0 numberOfFlashes:2];
                            [_bleModules replaceObjectAtIndex:i withObject:device];
                            
                            
                            [device addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];

                            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBoardsConnected" object:nil];
                        }
                    }];
                }
            }
        }
    }];
    return self;
}

-(NSArray*)numBoardsConnected{
    
    int count =0;
    for (int i=0; i<[_bleModules count]; i++) {
        if([[_bleModules objectAtIndex:i] isKindOfClass:[MBLMetaWear class]])
        {
            if(((MBLMetaWear*)[_bleModules objectAtIndex:i]).state!=CBPeripheralStateDisconnected)
            {
                count++;
            }
            else
            {
                [_bleModules replaceObjectAtIndex:i withObject:@""];
            }
        }
        else
        {
            [_bleModules replaceObjectAtIndex:i withObject:@""];
        }
    }
    return [NSArray arrayWithArray:_bleModules];
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateBoardsConnected" object:nil];
}

#pragma mark BOARD ACTUATOR METHODS
//** LED SET **//
-(int)setLEDColor:(UIColor*)color ToBoardNum:(int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp.led setLEDColorAsync:color withIntensity:1.0];
        return 1;
    }
    else
    {
        return 0;
    }
}
//** LED FLASH **//
- (int) flashLEDWithColor:(UIColor*)color  andNumOfFlashes:(int)numFlashes    ToBoardNum:(int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp.led flashLEDColorAsync:color withIntensity:1.0 numberOfFlashes:numFlashes];
        return 1;
    }
    else
    {
        return 0;
    }
}
//** MAKE VIBRATE **//
- (int) makeVibrateWithDuration:(int)duration   ToBoardNum:(int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        uint8_t dcycle =  248;
        uint16_t pwidth = CLAMP(duration, 250, 3000);
        [metaTmp.hapticBuzzer startHapticWithDutyCycleAsync:dcycle pulseWidth:pwidth completion:nil];
        return 1;
    }
    else
    {
        return 0;
    }
}

#pragma mark BOARD SENSOR METHODS - REGISTER
//** REGISTER BUTTON **//
- (int) registerButtonForBoardNum:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp.mechanicalSwitch.switchUpdateEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
            //NSLog(@"Switch Changed: %@", obj);
            NSString* newMessage=[NSString stringWithFormat:@"{\"message\":\"buttonEvent\",\"value\":\"%d\",\"boardNum\":\"%d\"}",[obj.value integerValue],boardNum];
            [webSocket send:newMessage];
        }];
       /* [metaTmp.mechanicalSwitch.switchUpdateEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
            if(error)
            {
                NSLog(@"error %@",error);
                [metaTmp connectWithHandler:^(NSError *error){
                    if(!error)
                    {
                        NSLog(@"connected again");
                        [self registerButtonForBoardNum:boardNum withWebSocket:webSocket];
                    
                    }
                    else {
                        NSLog(@"connection error %@",error);
                    }
                    
                }];
                return;
            }
            
            NSString* newMessage=[NSString stringWithFormat:@"{\"message\":\"buttonEvent\",\"value\":\"%d\"}",[obj.value integerValue]];
                [webSocket send:newMessage];
        }];*/
        return 1;
    }
    else
    {
        return 0;
    }
}
//** RELEASE BUTTON **//
- (int) releaseButtonForBoardNum: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp.mechanicalSwitch.switchUpdateEvent stopNotificationsAsync];
        return 1;
    }
    else
    {
        return 0;
    }
}
//** REGISTER ORIENTATION **//
- (int) registerOrientation:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            [accelerometerMMA8452Q.orientationEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
                if(error)
                {
                    NSLog(@"error %@",error);
                }
                else
                {
                    MBLOrientationData *data = obj;
                    NSString* orientation = @"";
                    
                    switch (data.orientation) {
                        case MBLAccelerometerOrientationPortrait:
                            orientation = @"LandscapeLeft";
                            break;
                        case MBLAccelerometerOrientationPortraitUpsideDown:
                            orientation = @"LandscapeRight";
                            break;
                        case MBLAccelerometerOrientationLandscapeLeft:
                            orientation = @"PortraitUpsideDown";
                            break;
                        case MBLAccelerometerOrientationLandscapeRight:
                            orientation = @"Portrait";
                            break;
                            
                    }
                    NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"orientationEvent\",\"value\":\"%@\",\"boardNum\":\"%d\"}",orientation,boardNum];
                    [webSocket send:newMessage];
                }
            }];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** RELEASE ORIENTATION **//
- (int) releaseOrientation: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
            MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)metaTmp.accelerometer;
             [accelerometerBMI160.orientationEvent stopNotificationsAsync];
        }
        else if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            [accelerometerMMA8452Q.orientationEvent stopNotificationsAsync];
        }
       
        return 1;
    }
    else
    {
        return 0;
    }
}

//** REGISTER TAP **//
- (int) registerTap:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            accelerometerMMA8452Q.tapDetectionAxis = MBLAccelerometerAxisX;
            accelerometerMMA8452Q.tapType = MBLAccelerometerTapTypeSingle;
            
            [accelerometerMMA8452Q.tapEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
                if(error)
                {
                    NSLog(@"error %@",error);
                }
                else
                {
                    
                    NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"tapEvent\",\"boardNum\":\"%d\"}",boardNum];
                    [webSocket send:newMessage];
                }
            }];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** RELEASE TAP **//
- (int) releaseTap: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            [accelerometerMMA8452Q.tapEvent stopNotificationsAsync];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** REGISTER DOUBLE TAP **//
- (int) registerDoubleTap:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            accelerometerMMA8452Q.tapDetectionAxis = MBLAccelerometerAxisX;
            accelerometerMMA8452Q.tapType = MBLAccelerometerTapTypeDouble;
            
            [accelerometerMMA8452Q.tapEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
                if(error)
                {
                    NSLog(@"error %@",error);
                }
                else
                {
                    
                    NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"tapEvent\",\"boardNum\":\"%d\"}",boardNum];
                    [webSocket send:newMessage];
                }
            }];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** RELEASE DOUBLE TAP **//
- (int) releaseDoubleTap: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            [accelerometerMMA8452Q.tapEvent stopNotificationsAsync];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}

//** REGISTER FREE FALL **//
- (int) registerFreeFall:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
           
            [accelerometerMMA8452Q.freeFallEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
                if(error)
                {
                    NSLog(@"error %@",error);
                }
                else
                {
                    
                    NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"freeFallEvent\",\"boardNum\":\"%d\"}",boardNum];
                    [webSocket send:newMessage];
                }
            }];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** RELEASE FREE FALL **//
- (int) releaseFreeFall: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            [accelerometerMMA8452Q.freeFallEvent stopNotificationsAsync];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}

//** REGISTER SHAKE **//
- (int) registerShake:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            
            [accelerometerMMA8452Q.shakeEvent startNotificationsWithHandlerAsync:^(MBLOrientationData * _Nullable obj, NSError * _Nullable error) {
                if(error)
                {
                    NSLog(@"error %@",error);
                }
                else
                {
                 
                    //NSTimeInterval timeInMiliseconds = [[NSDate date] timeIntervalSince1970];
                    //printf("%f", timeInMiliseconds);

                    NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"shakeEvent\",\"boardNum\":\"%d\"}",boardNum];
                    [webSocket send:newMessage];
                }
            }];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** RELEASE SHAKE **//
- (int) releaseShake: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            MBLAccelerometerMMA8452Q *accelerometerMMA8452Q = (MBLAccelerometerMMA8452Q *)metaTmp.accelerometer;
            [accelerometerMMA8452Q.shakeEvent stopNotificationsAsync];
        }
        
        return 1;
    }
    else
    {
        return 0;
    }
}
#pragma mark BOARD SENSORS METHODS - GET

//** GET TEMPERATURE **//
- (int) getTemperature:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
      
        [[metaTmp.temperature.onDieThermistor readAsync] success:^(MBLNumericData *  result) {
            
            NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"temperatureGet\",\"value\":\"%f\",\"boardNum\":\"%d\"}",result.value.floatValue,boardNum];
            [webSocket send:newMessage];
        }];
        
        return 1;
    }
    else
    {
        return 0;
    }
}
//** GET RSSI **//
- (int) getRSSI:(int)boardNum withWebSocket:(PSWebSocket* )webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp readRSSIWithHandler:^(NSNumber *number, NSError *error) {
             NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"rssiGet\",\"value\":\"%f\",\"boardNum\":\"%d\"}",[number floatValue],boardNum ];
            [webSocket send:newMessage];
        }];
        return 1;
    }
    else
    {
        return 0;
    }
}
//** GET BATTERY LEVEL **//
- (int) getBatteryLevel:(int) boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp readBatteryLifeWithHandler:^(NSNumber *number, NSError *error) {
            NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"batteryGet\",\"value\":\"%f\",\"boardNum\":\"%d\"}",[number floatValue],boardNum ];
            [webSocket send:newMessage];
        }];
        
        return 1;
    }
    else
    {
        return 0;
    }
}

@end

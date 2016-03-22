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
    _deviceUUIDS=[NSArray arrayWithObjects:@"CADD0E85-70A5-C31F-434C-9899987DA446",@"C48030C3-AE8E-1E19-7D19-2597E78D4F56",@"FD8EC4DA-04F4-92F5-4553-97B79C748785",nil];
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
                            
                            //[device forgetDevice];
                            /*
                             bleDeviceMap[idNumberReference[device.identifier.UUIDString.UTF8String]]=device;
                             numOfConnectedDevices=0;
                             accessGranted[idNumberReference[device.identifier.UUIDString.UTF8String]] = false;
                             
                             // device.accelerometer.sampleFrequency = MBLAccelerometerSampleFrequency1_56Hz;
                             
                             for (int k=0; k<MAX_NUM_OF_DEVICES; k++) {
                             if(bleDeviceMap[k]!=nil)
                             {
                             numOfConnectedDevices++;
                             }
                             }*/
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

#pragma mark BOARD SENSOR METHODS
//** REGISTER BUTTON **//
- (int) registerButtonForBoardNum:(int)boardNum withWebSocket:(PSWebSocket *)webSocket{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        [metaTmp.mechanicalSwitch.switchUpdateEvent startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
            NSLog(@"Switch Changed: %@", obj);
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
                    NSString *newMessage =[NSString stringWithFormat: @"{\"message\":\"orientationEvent\",\"value\":\"%@\"}",orientation];
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
- (int) releaseOrientation: (int)boardNum{
    if([[_bleModules objectAtIndex:boardNum] isKindOfClass:[MBLMetaWear class]])
    {
        MBLMetaWear* metaTmp = [_bleModules objectAtIndex:boardNum];
        if ([metaTmp.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
            MBLAccelerometerBMI160 *accelerometerBMI160 = (MBLAccelerometerBMI160 *)metaTmp.accelerometer;
             [accelerometerBMI160.orientationEvent stopNotificationsAsync];
        }
       
        return 1;
    }
    else
    {
        return 0;
    }
}


- (MBLMetaWear*) getBoardNum:(int)boardNum{
    return [_bleModules objectAtIndex:boardNum];
}
@end

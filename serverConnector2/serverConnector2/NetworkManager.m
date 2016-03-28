//
//  NetworkManager.m
//  serverConnector2
//
//  Created by Pierluigi Dalla Rosa on 3/16/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#define PORT 9092
#import "NetworkManager.h"
#import "ConsoleManager.h"
#import "BoardsManager.h"

@implementation NetworkManager

+ (id)sharedManager {
    static NetworkManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    _server = [PSWebSocketServer serverWithHost:nil port:PORT];
    _server.delegate = self;
    [_server start];
    
    return self;
}

#pragma mark - PSWebSocketServerDelegate

- (void)serverDidStart:(PSWebSocketServer *)server {
    //NSLog(@"Server did start…");
}
- (void)serverDidStop:(PSWebSocketServer *)server {
    //NSLog(@"Server did stop…");
}
- (BOOL)server:(PSWebSocketServer *)server acceptWebSocketWithRequest:(NSURLRequest *)request {
   // NSLog(@"Server should accept request: %@", request);
    return YES;
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSLog(@"Server websocket did receive message: %@", message);
 
    NSError *error = nil;
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    id object = [NSJSONSerialization
                 JSONObjectWithData:data
                 options:0
                 error:&error];
    
    if(error) {
        /* JSON was malformed*/
        [webSocket send:@"{\"error\":\"BAD JSON\"}"];
         }
    
    // the originating poster wants to deal with dictionaries;
    // assuming you do too then something like this is the first
    // validation step:
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *results = object;
        if([[results allKeys] containsObject:@"message"] && [[results allKeys] containsObject:@"device"])
        {
            NSString* keyDirective      = [results valueForKey:@"message"];
            int boardNum                = [[results valueForKey:@"device"] intValue];
            int success                 = -1;
            if(boardNum<0 || boardNum>MAX_NUM_OF_DEVICES)
            {
               [webSocket send:@"{\"error\":\"WRONG DEVICE NUM\"}"];
                return;
            }
            [[ConsoleManager sharedManager] log:keyDirective];
            
            if([keyDirective isEqualToString:@"readBatteryLevel"])
            {
                
            }
            else if([keyDirective isEqualToString:@"setColor"])
            {
                
                float alpha = 255.0;
                if([[results allKeys] containsObject:@"alpha"])
                {
                    alpha = [[results valueForKey:@"alpha"] floatValue];
                }
                
                if([[results allKeys] containsObject:@"red"] && [[results allKeys] containsObject:@"blue"]&& [[results allKeys] containsObject:@"green"])
                {
                   success = [[BoardsManager sharedManager] setLEDColor:
                     [UIColor
                      colorWithRed:([[results valueForKey:@"red"] floatValue]/255)
                      green:([[results valueForKey:@"green"] floatValue]/255)
                      blue:([[results valueForKey:@"blue"] floatValue]/255)
                      alpha:(alpha/255)]
                                                    ToBoardNum:boardNum];
                }
            }
            else if([keyDirective isEqualToString:@"flashColor"])
            {
                
                float alpha = 255.0;
                if([[results allKeys] containsObject:@"alpha"])
                {
                    alpha = [[results valueForKey:@"alpha"] floatValue];
                }
                int numberOfFlashes = 1;
                if([[results allKeys] containsObject:@"numberOfFlashes"])
                {
                    numberOfFlashes = [[results valueForKey:@"numberOfFlashes"] intValue];
                }
                
                if([[results allKeys] containsObject:@"red"] && [[results allKeys] containsObject:@"blue"] && [[results allKeys] containsObject:@"green"])
                {
                   success = [[BoardsManager sharedManager] flashLEDWithColor:
                     [UIColor
                      colorWithRed:([[results valueForKey:@"red"] floatValue]/255)
                      green:([[results valueForKey:@"green"] floatValue]/255)
                      blue:([[results valueForKey:@"blue"] floatValue]/255)
                      alpha:(alpha/255.0)]
                                                     andNumOfFlashes:numberOfFlashes
                                                          ToBoardNum:boardNum];
                }
            }
            else if([keyDirective isEqualToString:@"makeVibrate"])
            {
                int duration = 500;
                if([[results allKeys] containsObject:@"duration"])
                {
                    duration = [ [results valueForKey:@"duration"] floatValue];
                }
                success = [[BoardsManager sharedManager] makeVibrateWithDuration:duration ToBoardNum:boardNum];
            }
            else if([keyDirective isEqualToString:@"registerButton"])
            {
                success = [[BoardsManager sharedManager] registerButtonForBoardNum:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseButton"])
            {
                success = [[BoardsManager sharedManager] releaseButtonForBoardNum:boardNum];
            }
            else if([keyDirective isEqualToString:@"registerOrientation"])
            {
                success = [[BoardsManager sharedManager] registerOrientation:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseOrientation"])
            {
                success = [[BoardsManager sharedManager] releaseOrientation:boardNum];
            }
            else if([keyDirective isEqualToString:@"registerTap"])
            {
                success = [[BoardsManager sharedManager] registerTap:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseTap"])
            {
                success = [[BoardsManager sharedManager] releaseTap:boardNum];
            }
            else if([keyDirective isEqualToString:@"registerDoubleTap"])
            {
                success = [[BoardsManager sharedManager] registerDoubleTap:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseDoubleTap"])
            {
                success = [[BoardsManager sharedManager] releaseDoubleTap:boardNum];
            }
            else if([keyDirective isEqualToString:@"registerFreeFall"])
            {
                success = [[BoardsManager sharedManager] registerFreeFall:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseFreeFall"])
            {
                success = [[BoardsManager sharedManager] releaseFreeFall:boardNum];
            }
            else if([keyDirective isEqualToString:@"registerShake"])
            {
                success = [[BoardsManager sharedManager] registerShake:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"releaseShake"])
            {
                success = [[BoardsManager sharedManager] releaseShake:boardNum];
            }
            else if([keyDirective isEqualToString:@"getBatteryLevel"])
            {
                success = [[BoardsManager sharedManager] getBatteryLevel:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"getRSSI"])
            {
                success = [[BoardsManager sharedManager] getRSSI:boardNum withWebSocket:webSocket];
            }
            else if([keyDirective isEqualToString:@"getTemperature"])
            {
                success = [[BoardsManager sharedManager] getTemperature:boardNum withWebSocket:webSocket];
            }
            
            
            if(!success)
            {
                [webSocket send:@"{\"error\":\"wrong BOARDNUMBER\"}"];
            }
        }
       
        else{
            [[ConsoleManager sharedManager] log:@"received wrong message"];
            [webSocket send:@"{\"error\":\"missing BOARDNUMBER or MESSAGE\"}"];
            return;
        }
        /* proceed with results as you like; the assignment to
         an explicit NSDictionary * is artificial step to get
         compile-time checking from here on down (and better autocompletion
         when editing). You could have just made object an NSDictionary *
         in the first place but stylistically you might prefer to keep
         the question of type open until it's confirmed */
    }
    else
    {
        /* there's no guarantee that the outermost object in a JSON
         packet will be a dictionary; if we get here then it wasn't,
         so 'object' shouldn't be treated as an NSDictionary; probably
         you need to report a suitable error condition */
    }
    
}
- (void)server:(PSWebSocketServer *)server webSocketDidOpen:(PSWebSocket *)webSocket {
    //NSLog(@"Server websocket did open");
   
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
   // NSLog(@"Server websocket did close with code: %@, reason: %@, wasClean: %@", @(code), reason, @(wasClean));
}
- (void)server:(PSWebSocketServer *)server webSocket:(PSWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"Server websocket did fail with error: %@", error);
}

@end

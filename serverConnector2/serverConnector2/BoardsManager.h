//
//  BoardsManager.h
//  serverConnector2
//
//  Created by Pierluigi Dalla Rosa on 3/16/16.
//  Copyright © 2016 binaryfutures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MetaWear/MetaWear.h>
#import <PSWebSocketServer.h>

#define MAX_NUM_OF_DEVICES 3

@interface BoardsManager : NSObject

@property (nonatomic,strong)NSMutableArray*                         bleModules;
@property (nonatomic,strong)NSArray*                                deviceUUIDS;

+ (id)sharedManager;
- (id)init;
- (NSArray*)numBoardsConnected;


- (int) setLEDColor:(UIColor*)color             ToBoardNum:(int)boardNum;
- (int) flashLEDWithColor:(UIColor*)color  andNumOfFlashes:(int)numFlashes    ToBoardNum:(int)boardNum;
- (int) makeVibrateWithDuration:(int)duration   ToBoardNum:(int)boardNum;

- (int) registerButtonForBoardNum:(int)boardNum withWebSocket:(PSWebSocket *)webSocket;
- (int) releaseButtonForBoardNum: (int)boardNum;

- (int) registerOrientation:(int)boardNum withWebSocket:(PSWebSocket *)webSocket;
- (int) releaseOrientation: (int)boardNum;

- (int) registerTap:(int)boardNum withWebSocket:(PSWebSocket *)webSocket;
- (int) releaseTap: (int)boardNum;

- (int) registerDoubleTap:(int)boardNum withWebSocket:(PSWebSocket *)webSocket;
- (int) releaseDoubleTap: (int)boardNum;

- (int) registerTemperature:(int)boardNum withWebSocket:(PSWebSocket *)webSocket;
- (int) releaseTemperature: (int)boardNum;


@end

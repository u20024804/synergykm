//
//  SKMConfigEntry.h
//  SynergyKM
//
//  Created by Philip Molter on 8/21/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    SKMSwitchLockTypeNone = 0,
    SKMSwitchLockTypeDelay = 1,
    SKMSwitchLockTypeDoubleClick = 2
};

enum {
    SKMLogLevelNote = 0,
    SKMLogLevelInfo = 1,
    SKMLogLevelDebug = 2,
    SKMLogLevelDebug1 = 3,
    SKMLogLevelDebug2 = 4
};

@interface SKMConfigEntry : NSObject
{
    NSString *name;
    
    BOOL isServerConfig;
    
    NSString *address;
    
    NSString *screenName;
    NSUInteger screenPort;
    
    BOOL enableHeartbeat;
    BOOL synchronizeScreenSaver;
    BOOL relativeMouseMoves;
    
    NSUInteger heartbeatMilliSeconds;
    NSUInteger switchLockType;
    NSUInteger switchLockMilliSeconds;
    
    NSUInteger logLevel;
    
    NSMutableArray *screens;
}

@property (retain) NSString *name;

@property (assign) BOOL isServerConfig;

@property (retain) NSString *address;

@property (retain) NSString *screenName;
@property (assign) NSUInteger screenPort;

@property (assign) BOOL enableHeartbeat;
@property (assign) BOOL synchronizeScreenSaver;
@property (assign) BOOL relativeMouseMoves;

@property (assign) NSUInteger heartbeatMilliSeconds;
@property (assign) NSUInteger switchLockType;
@property (assign) NSUInteger switchLockMilliSeconds;

@property (assign) NSUInteger logLevel;

@end

//
//  SKMConfigEntry.m
//  SynergyKM
//
//  Created by Philip Molter on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SKMConfigEntry.h"

@implementation SKMConfigEntry

@synthesize name;

@synthesize isServerConfig;

@synthesize address;

@synthesize screenName;
@synthesize screenPort;

@synthesize enableHeartbeat;
@synthesize synchronizeScreenSaver;
@synthesize relativeMouseMoves;

@synthesize heartbeatMilliSeconds;
@synthesize switchLockType;
@synthesize switchLockMilliSeconds;

@synthesize logLevel;

- (id)init
{
    self = [super init];
    if (self) {
        self.name = [NSString new];
        
        self.isServerConfig = NO;

        self.address = nil;
        
        self.screenName = nil;
        self.screenPort = 0;
        
        self.enableHeartbeat = NO;
        self.synchronizeScreenSaver = NO;
        self.relativeMouseMoves = NO;
        
        self.heartbeatMilliSeconds = 250;
        self.switchLockType = SKMSwitchLockTypeNone;
        self.switchLockMilliSeconds = 250;
        
        self.logLevel = SKMLogLevelNote;
    }
    
    return self;
}

@end

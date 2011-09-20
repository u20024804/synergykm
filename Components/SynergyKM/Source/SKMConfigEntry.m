//
//  SKMConfigEntry.m
//  SynergyKM
//
//  Created by Philip Molter on 8/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, 
//  are permitted provided that the following conditions are met:
//
//  •  Redistributions of source code must retain the above copyright notice, 
//     this list of conditions and the following disclaimer.
//  •  Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation 
//     and/or other materials provided with the distribution.
//  •  Neither the name of the Philip Molter nor the names of its 
//     contributors may be used to endorse or promote products derived from 
//     this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
//  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
//  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
//  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
//  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
//  OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
//  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
//  USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "SKMConfigEntry.h"
#import "SKMCommon.h"

#define DEFAULT_HEARTBEAT_MILLISECONDS 250
#define DEFAULT_SWITCHLOCK_MILLISECONDS 250

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
    if (self != nil) {
        self.name = [NSString new];
        
        self.isServerConfig = NO;

        self.address = nil;
        
        self.screenName = nil;
        self.screenPort = 0;
        
        self.enableHeartbeat = NO;
        self.synchronizeScreenSaver = NO;
        self.relativeMouseMoves = NO;
        
        self.heartbeatMilliSeconds = DEFAULT_HEARTBEAT_MILLISECONDS;
        self.switchLockType = SKMSwitchLockTypeNone;
        self.switchLockMilliSeconds = DEFAULT_SWITCHLOCK_MILLISECONDS;
        
        self.logLevel = SKMLogLevelNote;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self != nil) {
        self.name = [decoder decodeObjectForKey:@"name"];
        
        self.isServerConfig = [decoder decodeBoolForKey:@"isServerConfig"];
        
        self.address = [decoder decodeObjectForKey:@"address"];
        
        self.screenName = [decoder decodeObjectForKey:@"screenName"];
        self.screenPort = [decoder decodeIntegerForKey:@"screenPort"];
        
        self.enableHeartbeat = [decoder decodeBoolForKey:@"enableHeartbeat"];
        self.synchronizeScreenSaver = [decoder decodeBoolForKey:@"synchronizeScreenSaver"];
        self.relativeMouseMoves = [decoder decodeBoolForKey:@"relativeMouseMoves"];
        
        self.heartbeatMilliSeconds = [decoder decodeIntegerForKey:@"heartbeatMilliSeconds"];
        self.switchLockType = [decoder decodeIntegerForKey:@"switchLockType"];
        self.switchLockMilliSeconds = [decoder decodeIntegerForKey:@"switchLockMilliSeconds"];
        
        self.logLevel = [decoder decodeIntegerForKey:@"logLevel"];
        
        if (self.switchLockType < SKMSwitchLockTypeMin ||
            self.switchLockType > SKMSwitchLockTypeMax)
            self.switchLockType = SKMSwitchLockTypeNone;
        if (self.logLevel < SKMLogLevelMin || self.logLevel > SKMLogLevelMax)
            self.logLevel = SKMLogLevelNote;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    
    [encoder encodeBool:self.isServerConfig forKey:@"isServerConfig"];

    [encoder encodeObject:self.address forKey:@"address"];

    [encoder encodeObject:self.screenName forKey:@"screenName"];
    [encoder encodeInteger:self.screenPort forKey:@"screenPort"];

    [encoder encodeBool:self.enableHeartbeat forKey:@"enableHeartbeat"];
    [encoder encodeBool:self.synchronizeScreenSaver forKey:@"synchronizeScreenSaver"];
    [encoder encodeBool:self.relativeMouseMoves forKey:@"relativeMouseMoves"];

    [encoder encodeInteger:self.heartbeatMilliSeconds forKey:@"heartbeatMilliSeconds"];
    [encoder encodeInteger:self.switchLockType forKey:@"switchLockType"];
    [encoder encodeInteger:self.switchLockMilliSeconds forKey:@"switchLockMilliSeconds"];

    [encoder encodeInteger:self.logLevel forKey:@"logLevel"];
}

/* we watch this so anyone who cares will know something changed */
- (void)didChangeValueForKey:(NSString *)key
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SKMConfigChangedNotification
     object:self];
    [super didChangeValueForKey:key];
}

@end

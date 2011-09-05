//
//  SKMConfigEntry.h
//  SynergyKM
//
//  Created by Philip Molter on 8/21/11.
//  Copyright 2011 Philip Molter. All rights reserved.
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

#import <Cocoa/Cocoa.h>

enum {
    SKMSwitchLockTypeNone = 0,
    SKMSwitchLockTypeDelay = 1,
    SKMSwitchLockTypeDoubleClick = 2,
    
    SKMSwitchLockTypeMin = SKMSwitchLockTypeNone,
    SKMSwitchLockTypeMax = SKMSwitchLockTypeDoubleClick
};

enum {
    SKMLogLevelNote = 0,
    SKMLogLevelInfo = 1,
    SKMLogLevelDebug = 2,
    SKMLogLevelDebug1 = 3,
    SKMLogLevelDebug2 = 4,
    
    SKMLogLevelMin = SKMLogLevelNote,
    SKMLogLevelMax = SKMLogLevelDebug2
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

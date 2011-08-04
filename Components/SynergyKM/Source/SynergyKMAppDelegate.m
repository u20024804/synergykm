//
//  SynergyKMAppDelegate.m
//  SynergyKM
//
//  Created by Philip Molter on 8/2/11.
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

#import "SynergyKMAppDelegate.h"

@implementation SynergyKMAppDelegate

@synthesize settingsWindowController;

#define SKImageByName(name)(\
[[[NSImage alloc] \
  initByReferencingFile:[[NSBundle bundleForClass:[self class]] \
                         pathForImageResource:name]] \
 autorelease]\
)

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (void)awakeFromNib
{
    NSLog(@"SynergyKMAppDelegate awakeFromNib called");
    status = [[[NSStatusBar systemStatusBar]
               statusItemWithLength:NSVariableStatusItemLength] retain];
    [status setMenu:menu];
    [status setTitle:@""];
    [status setHighlightMode:YES];
    [status setImage:SKImageByName(@"StatusIdle")];
}

- (IBAction)toggleSynergyActivation:(id)sender
{
    if ([sender tag] == 1) {
        [activateMenuItem setHidden:YES];
        [deactivateMenuItem setHidden:NO];
    } else if ([sender tag] == 2) {
        [deactivateMenuItem setHidden:YES];
        [activateMenuItem setHidden:NO];
    }
}

- (IBAction)configureSynergy:(id)sender
{
    if (settingsWindowController == nil) {
        settingsWindowController = [[SKMSettingsWindowController alloc]
                                    initWithWindowNibName:@"Settings"];
    }
    
    [[settingsWindowController window] makeKeyAndOrderFront:nil];
}

- (void)reloadConfiguration:(id)sender
{
    
}
@end
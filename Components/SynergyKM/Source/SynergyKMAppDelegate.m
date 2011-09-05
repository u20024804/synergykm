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
#import "SKMCommon.h"

@implementation SynergyKMAppDelegate

@synthesize settingsWindowController;
@synthesize activeApp;
@synthesize lastDeactivatedApp;

#define SKImageByName(name)(\
[[[NSImage alloc] \
  initByReferencingFile:[[NSBundle bundleForClass:[self class]] \
                         pathForImageResource:name]] \
 autorelease]\
)


- (BOOL)isWindowActive
{
    if (settingsWindowController != nil &&
        [[settingsWindowController window] isVisible]) {
        return TRUE;
    }
    return FALSE;
}

- (void)becomeMenuOnly:(NSNotification *)menuOnlyNotification
{
    if (activeApp != nil) {
        [activeApp activateWithOptions:0];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)launchNote
{

}

- (void)applicationWillTerminate:(NSNotification *)terminateNote
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:SKMLastWindowClosedNotification
     object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     removeObserver:self
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     removeObserver:self
     name:NSWorkspaceDidDeactivateApplicationNotification
     object:nil];

    lastDeactivatedApp = nil;
    activeApp = nil;
}

- (void)awakeFromNib
{
    settingsWindowController = [[SKMSettingsWindowController alloc]
                                initWithWindowNibName:@"Settings"];

    /* our statusbar item and menu
     * icon-only (no title), highlights on selection,
     * starts with the idle image */
    statusBar = [[[NSStatusBar systemStatusBar]
               statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusBar setMenu:menu];
    [statusBar setTitle:@""];
    [statusBar setHighlightMode:YES];
    [statusBar setImage:SKImageByName(@"StatusIdle")];
    [statusBar setAlternateImage:SKImageByName(@"StatusIdle_P")];

    /* listen for applications activating and deactivating
     * we can then reactivate applications that are deactivated when
     * we enter menu-only mode */
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(trackApplicationDeactivation:)
     name:NSWorkspaceDidDeactivateApplicationNotification
     object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self
     selector:@selector(trackApplicationActivation:)
     name:NSWorkspaceDidActivateApplicationNotification
     object:nil];

    /* listen for our configuration window close notification
     * note that the window hasn't been created yet, so we can't
     * just listen for our window event */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(becomeMenuOnly:)
     name:SKMLastWindowClosedNotification
     object:nil];
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
    /* bring the window to the front first as it makes tracking the
     * activation/deactivation steps easier */
    [[settingsWindowController window] makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:TRUE];
}

- (void)reloadConfiguration:(id)sender
{
    
}

- (void)trackApplicationActivation:(NSNotification *)activateNote
{
    /* this is the app that is becoming active */
    NSRunningApplication *activatedApp =
        [[activateNote userInfo] objectForKey:NSWorkspaceApplicationKey];

    /* if we are the app that is becoming active, we need to check
     * whether we're in menu-only mode or we have our config window open;
     * if we're in menu-only mode, we don't want to be the active app */
    if ([activatedApp.bundleIdentifier
         isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        
        /* our config window isn't open; we're in menu-only mode
         * tell ourselves to act as if all windows are closed */
        if (![self isWindowActive]) {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:SKMLastWindowClosedNotification
             object:self];
        }
    } else {
        activeApp = activatedApp;
    }
}

- (void)trackApplicationDeactivation:(NSNotification *)deactivateNote
{
    /* the app that was just deactivated */
    NSRunningApplication *deactivatedApp =
        [[deactivateNote userInfo] objectForKey:NSWorkspaceApplicationKey];

    /* if this app is the deactivated app; then we need to check whether
     * our current active app is also us; if so, we're going to reactivate
     * our previously deactivated app (the one active before us)
     * -- if and only if we're in menu-only mode */
    if ([deactivatedApp.bundleIdentifier
          isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
        
        /* menu-only mode and the active app is this app */
        if (![self isWindowActive] &&
            [activeApp.bundleIdentifier
             isEqualToString:[[NSBundle mainBundle] bundleIdentifier]]) {
            activeApp = lastDeactivatedApp;
        
            [[NSNotificationCenter defaultCenter]
             postNotificationName:SKMLastWindowClosedNotification
             object:self];
        }
        
    /* some other app is being deactivated, but we're in menu-only mode
     * and we either don't know which app is active (just started) or
     * we are the active app -- reactivate the app being deactivated */
    } else if (![self isWindowActive] &&
               (activeApp == nil ||
                [activeApp.bundleIdentifier
                 isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])) {
        activeApp = deactivatedApp;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:SKMLastWindowClosedNotification
         object:self];

    /* otherwise, just track the last deactivated app */
    } else {
        lastDeactivatedApp = deactivatedApp;
    }
}
@end
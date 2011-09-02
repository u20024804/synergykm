//
//  SKMSettingsWindowController.h
//  SynergyKM
//
//  Created by Philip Molter on 8/3/11.
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

#import <Foundation/Foundation.h>

#import "SKMConfigListController.h"

@interface SKMSettingsWindowController : NSWindowController
<NSTableViewDataSource, NSTableViewDelegate> {
    NSPanel *editLocationsPanel;
    NSView *editLocationsView;
    NSPopUpButton *locationMenu;
    SKMConfigListController *configListController;
    NSTableView *configListTable;
    NSButton *addLocationButton;
    NSButton *removeLocationButton;
}

@property (retain) IBOutlet NSPanel *editLocationsPanel;
@property (retain) IBOutlet NSView *editLocationsView;
@property (retain) IBOutlet NSPopUpButton *locationMenu;
@property (retain) IBOutlet SKMConfigListController *configListController;
@property (retain) IBOutlet NSTableView *configListTable;
@property (retain) IBOutlet NSButton *addLocationButton;
@property (retain) IBOutlet NSButton *removeLocationButton;

- (IBAction)saveSettings:(id)sender;
- (IBAction)changeLocation:(id)sender;
- (IBAction)addLocation:(id)sender;
- (IBAction)removeLocation:(id)sender;
- (IBAction)editLocations:(id)sender;
- (IBAction)finishEditingLocations:(id)sender;
- (IBAction)closeEditingLocations:(NSWindow *)sheet
                       returnCode:(NSInteger)rc
                      contextInfo:(void *)contextInfo;
@end

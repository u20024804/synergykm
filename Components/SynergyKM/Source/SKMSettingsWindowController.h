//
//  SKMSettingsWindowController.h
//  SynergyKM
//
//  Created by Philip Molter on 8/3/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKMSettingsWindowController : NSWindowController {
    NSPopUpButton *locationMenu;
    NSMenuItem *selectedLocationItem;
    NSPanel *editLocationsPanel;
}

@property (retain) IBOutlet NSPanel *editLocationsPanel;
@property (retain) IBOutlet NSPopUpButton *locationMenu;
@property (retain) NSMenuItem *selectedLocationItem;

- (IBAction)saveSettings:(id)sender;
- (IBAction)changeLocation:(id)sender;
- (IBAction)editLocations:(id)sender;
- (IBAction)finishEditingLocations:(id)sender;

@end

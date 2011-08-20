//
//  SKMSettingsWindowController.h
//  SynergyKM
//
//  Created by Philip Molter on 8/3/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKMSettingsWindowController : NSWindowController
<NSTableViewDataSource, NSTableViewDelegate> {
    NSPanel *editLocationsPanel;
    NSView *editLocationsView;
    NSPopUpButton *locationMenu;
    NSArrayController *configListController;
    NSTableView *configListTable;
    NSButton *addLocationButton;
    NSButton *removeLocationButton;

    NSMenuItem *selectedLocationItem;
    NSMutableArray *configList;
}

@property (retain) IBOutlet NSPanel *editLocationsPanel;
@property (retain) IBOutlet NSView *editLocationsView;
@property (retain) IBOutlet NSPopUpButton *locationMenu;
@property (retain) IBOutlet NSArrayController *configListController;
@property (retain) IBOutlet NSTableView *configListTable;
@property (retain) IBOutlet NSButton *addLocationButton;
@property (retain) IBOutlet NSButton *removeLocationButton;

@property (retain) NSMenuItem *selectedLocationItem;
@property (retain) NSMutableArray *configList;

- (IBAction)saveSettings:(id)sender;
- (IBAction)changeLocation:(id)sender;
- (IBAction)addLocation:(id)sender;
- (IBAction)editLocations:(id)sender;
- (IBAction)finishEditingLocations:(id)sender;
- (IBAction)closeEditingLocations:(NSWindow *)sheet
                       returnCode:(NSInteger)rc
                      contextInfo:(void *)contextInfo;
@end

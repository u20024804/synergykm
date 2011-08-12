//
//  SKMSettingsWindowController.m
//  SynergyKM
//
//  Created by Philip Molter on 8/3/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import "SKMSettingsWindowController.h"
#import "SKMCommon.h"

@implementation SKMSettingsWindowController

@synthesize editLocationsPanel;
@synthesize locationMenu;
@synthesize selectedLocationItem;

- (void)windowDidLoad
{
    selectedLocationItem = [locationMenu selectedItem];
    if (selectedLocationItem == nil ||
        [selectedLocationItem isSeparatorItem] ||
        [[selectedLocationItem title]
         isEqualToString:NSLocalizedString(@"Edit Locations", nil)]) {
        [locationMenu selectItemWithTitle:NSLocalizedString(@"Default", nil)];
        selectedLocationItem = [locationMenu selectedItem];
    }

    /* we want to know when our window closes so we can notify our app */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(processWindowCloseEvent:)
     name:NSWindowWillCloseNotification
     object:self.window];
}

- (IBAction)saveSettings:(id)sender
{
    // TODO: implement
}

- (IBAction)changeLocation:(id)sender
{
    NSMenuItem *selectedItem = [locationMenu selectedItem];
    if (selectedItem != nil &&
        ![selectedItem isSeparatorItem] &&
        ![[selectedItem title]
          isEqualToString:NSLocalizedString(@"Edit Locations", nil)]) {
        selectedLocationItem = selectedItem;
    }
}

- (IBAction)editLocations:(id)sender
{
    [NSApp beginSheet:editLocationsPanel
       modalForWindow:self.window
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
    [NSApp runModalForWindow:editLocationsPanel];
    [NSApp endSheet:editLocationsPanel];
    [editLocationsPanel orderOut:self];
}

- (IBAction)finishEditingLocations:(id)sender
{
    [locationMenu selectItem:selectedLocationItem];
    [NSApp stopModal];
    
}

- (void)processWindowCloseEvent:(NSNotification *)windowClosingNotification
{
    /* we're closing, notify ourselves that our window is closing */
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SKMLastWindowClosedNotification
     object:self];
}

@end

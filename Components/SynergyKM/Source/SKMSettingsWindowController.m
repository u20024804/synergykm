//
//  SKMSettingsWindowController.m
//  SynergyKM
//
//  Created by Philip Molter on 8/3/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import "SKMSettingsWindowController.h"

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

    [[NSNotificationCenter defaultCenter]
     addObserverForName:NSWindowWillCloseNotification
                 object:self.window
                  queue:nil
             usingBlock:^(NSNotification *note) { [NSApp deactivate]; }];
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:nil];
    NSLog(@"SKMSettingsWindowController windowDidLoad");
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
    NSLog(@"SKMSettingsWindowController editLocations: called");
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
    NSLog(@"SKMSettingsWindowController finishEditingLocations: called");
    [locationMenu selectItem:selectedLocationItem];
    [NSApp stopModal];
    
}

@end

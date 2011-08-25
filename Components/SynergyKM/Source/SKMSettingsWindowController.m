//
//  SKMSettingsWindowController.m
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

#import "SKMSettingsWindowController.h"
#import "SKMConfigEntry.h"
#import "SKMCommon.h"

@interface SKMSettingsWindowController ()

@property (retain) NSString *selectedLocationTitle;
@property (retain) NSMutableArray *configList;

@end

@implementation SKMSettingsWindowController

@synthesize editLocationsPanel;
@synthesize editLocationsView;
@synthesize locationMenu;
@synthesize configListController;
@synthesize configListTable;
@synthesize addLocationButton;
@synthesize removeLocationButton;

@synthesize selectedLocationTitle;
@synthesize configList;


NSInteger compareViews(id firstView, id secondView, void *context);


#pragma Interface actions

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
            selectedLocationTitle = [selectedItem title];
        }
}

- (IBAction)addLocation:(id)sender
{
    NSString *newLabel = NSLocalizedString(@"New Location", nil);
    NSUInteger nextNewLocationId = 0;
    NSUInteger i = 0;
    SKMConfigEntry *newLocation = [[SKMConfigEntry alloc] init];
    
    [editLocationsPanel makeFirstResponder:sender];

    /* match /^New Location(?: [1-9][0-9]*)?$/ to find all current entries
     * that might conflict with the New Location we're about to create */
    NSPredicate *match = [NSPredicate 
                          predicateWithFormat:@"SELF.name MATCHES %@",
                          [NSString
                           stringWithFormat:@"^%@(?: [1-9][0-9]*)?$",
                           newLabel]];
    NSArray *newLocations = [configList filteredArrayUsingPredicate:match];

    if ([newLocations count] > 0) {
        for (i = 0; i < [newLocations count]; i++) {
            SKMConfigEntry *configEntry =
                (SKMConfigEntry *)[newLocations objectAtIndex:i];
            
            if ([configEntry.name length] > [newLabel length]) {
                NSInteger locationId =
                    [[configEntry.name
                      substringFromIndex:([newLabel length] + 1)]
                     integerValue];
                if (locationId > nextNewLocationId) {
                    nextNewLocationId = locationId;
                }
            }
        }
        
        nextNewLocationId++;
    }
    
    if (nextNewLocationId > 0) {
        newLabel = [NSString
                    stringWithFormat:@"%@ %ld",
                    newLabel, nextNewLocationId];
    }
    
    newLocation.name = newLabel;
    
    [configListController addObject:newLocation];
    
    [removeLocationButton setEnabled:YES];
    
    [configListTable
     selectRowIndexes:[NSIndexSet
                       indexSetWithIndex:([configList count] - 1)]
     byExtendingSelection:NO];
    [configListTable
     editColumn:0
     row:([configList count] - 1)
     withEvent:nil
     select:YES];
}

- (IBAction)removeLocation:(id)sender
{
    [editLocationsPanel makeFirstResponder:sender];

    NSUInteger rows = [configListTable numberOfRows];
    if (rows <= 1)
        return;
    
    NSUInteger selectedRow = [configListTable selectedRow];
    
    [configListController removeObjectAtArrangedObjectIndex:selectedRow];

    if (selectedRow == rows - 1)
        selectedRow--;
    
    [configListTable
     selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow]
     byExtendingSelection:NO];
    
    if ([configListTable numberOfRows] <= 1)
        [removeLocationButton setEnabled:NO];
}

- (IBAction)editLocations:(id)sender
{
    /* because we have a +/- button bar where the buttons overlap,
     * we add this observer to allow us to always bring the firstResponder
     * button forward, so its highlight won't be truncated by other buttons */
    [editLocationsPanel
     addObserver:self
     forKeyPath:@"firstResponder"
     options:NSKeyValueObservingOptionOld
     context:nil];

    if ([configList count] > 1) {
        [removeLocationButton setEnabled:YES];
    } else {
        [removeLocationButton setEnabled:NO];
    }
    
    [NSApp beginSheet:editLocationsPanel
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(closeEditingLocations:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)finishEditingLocations:(id)sender
{
    /* this ensures that any in-progress cell edits are completed */
    [editLocationsPanel makeFirstResponder:sender];
    
    NSUInteger selectedEntryIndex = [configListController selectionIndex];

    /* when our panel disappears, the location Menu is going to have
     * "Edit Locations" selected; try to set it to something reasonable */
    if (selectedEntryIndex != NSNotFound) {
        [locationMenu selectItemAtIndex:selectedEntryIndex];
    } else {
        [locationMenu selectItemWithTitle:selectedLocationTitle];
    }
    
    /* if all else fails, set it to the first item */
    if ([locationMenu selectedItem] == nil)
        [locationMenu selectItemAtIndex:0];
    
    [NSApp endSheet:editLocationsPanel];
}

- (IBAction)closeEditingLocations:(NSWindow *)sheet
                       returnCode:(NSInteger)rc
                      contextInfo:(void *)contextInfo
{
    [editLocationsPanel removeObserver:self forKeyPath:@"firstResponder"];
    [sheet orderOut:self];
}

- (void)awakeFromNib {
    if (configList == nil) {
        configList = [[NSMutableArray alloc] init];
        
        SKMConfigEntry *entry = [[SKMConfigEntry alloc] init];
        entry.name = @"Default";
        [configList addObject:entry];
        
        [configListController setContent:configList];
    }
    
    [super awakeFromNib];
}

- (void)windowDidLoad
{
    NSMenuItem *selectedLocationItem = [locationMenu selectedItem];
    if (selectedLocationItem == nil ||
        [selectedLocationItem isSeparatorItem] ||
        [[selectedLocationItem title]
         isEqualToString:NSLocalizedString(@"Edit Locations", nil)]) {
        [locationMenu selectItemAtIndex:0];
        selectedLocationItem = [locationMenu selectedItem];
    }
    
    selectedLocationTitle = [selectedLocationItem title];

    /* we want to know when our window closes so we can notify our app */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(processWindowCloseEvent:)
     name:NSWindowWillCloseNotification
     object:self.window];
}

- (void)processWindowCloseEvent:(NSNotification *)windowClosingNotification
{
    /* we're closing, notify ourselves that our window is closing */
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SKMLastWindowClosedNotification
     object:self];
}

/* we implrement this observation for firstResponder so that we can
 * bring any buttons to the front, preventing their highlighting
 * from being truncated by other UI elements
 *
 * http://www.timschroeder.net/2011/01/20/strange-kind-of-focus-ring/ */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"firstResponder"]) {
        [editLocationsView
         sortSubviewsUsingFunction:compareViews
         context:nil];
    }
}

/* support function for our button reorderer observation */
NSInteger compareViews(id firstView, id secondView, void *context)
{
    NSResponder *res = [[firstView window] firstResponder];
    
    /* do no reordering if we don't get back a responder */
    if (!res)
        return NSOrderedSame;

    /* our view is the firstResponder, make sure he's on top */
    if (res == firstView)
        return NSOrderedDescending;
 
    /* our responder is a descendant of our new view, make sure he's on top */
    if ([res respondsToSelector:@selector(isDescendantOf:)]) {
        NSView *testView = (NSView *)res;
        if ([testView isDescendantOf:firstView])
            return NSOrderedDescending;
    }

    /* our new view is neither the firstResponder nor a decscendant of
     * the firstResponder; if it's a scroll view, make it the top
     * this works around an issue with scroll views containing table views */
    if ([firstView isKindOfClass:[NSScrollView class]])
        return NSOrderedDescending;
    
    return NSOrderedSame;
}
 
@end

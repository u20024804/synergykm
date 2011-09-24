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
@property (assign) BOOL hasConfigChanged;

@end

@implementation SKMSettingsWindowController
@synthesize locationMenu;
@synthesize configTabView;
@synthesize clientConfigTab;
@synthesize serverConfigTab;

@synthesize configListController;
@synthesize clientController;

@synthesize editLocationsPanel;
@synthesize editLocationsView;
@synthesize configListTable;
@synthesize addLocationButton;
@synthesize removeLocationButton;

@synthesize selectedLocationTitle;
@synthesize configList;
@synthesize hasConfigChanged;


NSInteger compareViews(id firstView, id secondView, void *context);


- (void)_loadSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger selectedConfigIndex = 0;
    
    NSArray *configArray = nil;
    NSData *encodedConfigList = [defaults objectForKey:@"config.list"];
    
    /* we have a list of configurations, try to decode them */
    if (encodedConfigList != nil)
        configArray = [NSKeyedUnarchiver unarchiveObjectWithData:encodedConfigList];

    /* if we don't have any configurations at all, create a default config
     * and prime the config list with it */
    if (configArray == nil || [configArray count] == 0) {
        SKMConfigEntry *config = [[SKMConfigEntry alloc] init];
        config.name = NSLocalizedString(@"Default", nil);
        
        configList = [NSMutableArray arrayWithCapacity:1];
        [configList addObject:config];
        
        [config release];

    /* we have configurations, create the array and try to pull the
     * previously selected configuration */
    } else {
        configList = [NSMutableArray arrayWithCapacity:[configArray count]];
        [configList addObjectsFromArray:configArray];
        selectedConfigIndex = [defaults integerForKey:@"config.active"];
        
        /* if we couldn't find a selected config (shouldn't happen), then
         * just treat the first item as our selected config */
        if (selectedConfigIndex >= [configList count])
            selectedConfigIndex = 0;
    }

    /* setup the NSArrayController subclass with our list and selection */
    [configListController setContent:configList];
    [configListController setSelectionIndex:selectedConfigIndex];

    /* at this point, we have clean, unchanged configurations */
    hasConfigChanged = FALSE;
}

- (void)_saveSettings
{
    NSData *encodedConfigList =
        [NSKeyedArchiver archivedDataWithRootObject:configList];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:encodedConfigList forKey:@"config.list"];
    [defaults setInteger:[configListController selectionIndex]
                  forKey:@"config.active"];
    [defaults synchronize];

    /* at this point, we have clean, unchanged configurations */
    hasConfigChanged = FALSE;
}

- (void)_setViewState
{
    SKMConfigEntry *config = [configListController selectedConfig];
    if (config == nil || !config.isServerConfig) {
        [configTabView removeTabViewItem:serverConfigTab];
        [configTabView addTabViewItem:clientConfigTab];
    } else {
        [configTabView removeTabViewItem:clientConfigTab];
        [configTabView addTabViewItem:serverConfigTab];
    }
}

#pragma Interface actions

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

    /* we watch the config list for changes to determine whether we
     * need to enable or disable the '-' button */
    [configListController
     addObserver:self
     forKeyPath:@"arrangedObjects"
     options:NSKeyValueObservingOptionNew
     context:nil];

    /* the the initial state for the '-' button */
    if ([[configListController content] count] > 1) {
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
        
- (IBAction)addLocation:(id)sender
{
    if (![editLocationsPanel makeFirstResponder:sender])
        return;
    
    SKMConfigEntry *newLocation =
        (SKMConfigEntry *)[configListController newObject];
    [configListController addObject:newLocation];
    [newLocation release];

    /* if we add a location, we know we can remove it */
    [removeLocationButton setEnabled:YES];

    /* we want to preselect our new entry and make it editable */
    [configListTable
     selectRowIndexes:[NSIndexSet
                       indexSetWithIndex:([[configListController content] count] - 1)]
     byExtendingSelection:NO];
    [configListTable
     editColumn:0
     row:([[configListController content] count] - 1)
     withEvent:nil
     select:YES];
}

- (IBAction)removeLocation:(id)sender
{
    if (![editLocationsPanel makeFirstResponder:sender])
        return;

    NSUInteger rows = [configListTable numberOfRows];
    if (rows <= 1)
        return;
    
    NSUInteger selectedRow = [configListTable selectedRow];
    
    [configListController removeObjectAtArrangedObjectIndex:selectedRow];

    /* if the selected row was the last row in the list, then we
     * need to make the selected row the last row of the new list */
    if (selectedRow == rows - 1)
        selectedRow--;
    
    [configListTable
     selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow]
     byExtendingSelection:NO];

    /* if we only have one row, we can't remove it */
    if ([configListTable numberOfRows] <= 1)
        [removeLocationButton setEnabled:NO];
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

- (IBAction)finishEditingLocations:(id)sender
{
    /* this ensures that any in-progress cell edits are completed */
    if ([editLocationsPanel makeFirstResponder:sender]) {
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
    
    /* if we get here, it means we couldn't take over firstResponder status,
     * which probably means they have an invalid location specified */
}

- (IBAction)closeEditingLocations:(NSWindow *)sheet
                       returnCode:(NSInteger)rc
                      contextInfo:(void *)contextInfo
{
    [configListController removeObserver:self forKeyPath:@"arrangedObjects"];
    [editLocationsPanel removeObserver:self forKeyPath:@"firstResponder"];
    [sheet orderOut:self];
}

- (void)awakeFromNib
{
    /* we watch selection state and config type to trigger view
     * changes based on client/server type */
    [configListController
     addObserver:self
     forKeyPath:@"selectionIndex"
     options:0
     context:nil];
    
    [configListController
     addObserver:self
     forKeyPath:@"arrangedObjects.isServerConfig"
     options:0
     context:nil];
    
    [configTabView removeTabViewItem:serverConfigTab];
    
    [self _loadSettings];
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

    /* this becomes a fallback for when we can't figure out which
     * config entry should be selected in the dropdown */
    selectedLocationTitle = [selectedLocationItem title];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    
    /* the only time we care to listen for configuration changes is when
     * our window is key (the user can't make changes otherwise) */
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(processConfigChangedEvent:)
     name:SKMConfigChangedNotification
     object:nil];
}

- (BOOL)windowShouldClose:(id)sender
{
    BOOL shouldClose = TRUE;
    
    /* if the configuration has changed, we want to present them
     * with a confirmation dialog
     *
     * NOTE: if sender is nil, that means we're being called in a
     *       termination context, in which case, we don't give them an
     *       option to cancel the close action */
    if (hasConfigChanged) {
        NSBeginAlertSheet(
            NSLocalizedString(@"Unsaved Changes", nil),
            NSLocalizedString(@"Save & Apply", nil),
            NSLocalizedString(@"Don't Save", nil),
            sender == nil ? nil : NSLocalizedString(@"Cancel", nil),
            [self window],
            self,
            @selector(saveModalDidEnd:returnCode:contextInfo:),
            nil,
            [self window],
            NSLocalizedString(
                @"Would you like to save and apply your changes before closing the configuration window?",
                nil));
        
        shouldClose = FALSE;
    }
    
    return shouldClose;
}

- (void)windowWillClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:SKMConfigChangedNotification
     object:nil];

    /* we're closing, notify others (mainly, the app delegate)
     * that our window is closing */
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SKMLastWindowClosedNotification
     object:self];
}

- (void)processConfigChangedEvent:(NSNotification *)changeNotification
{
    hasConfigChanged = TRUE;
}

- (void)saveModalDidEnd:(NSWindow *)sheet
             returnCode:(NSInteger)returnCode
            contextInfo:(void *)contextInfo
{
    switch (returnCode) {

        /* default is "Save & Apply" */
        case (NSAlertDefaultReturn):
            [self _saveSettings];
            [(NSWindow *)contextInfo close];
            break;
            
        /* alternate is "Don't Save" */
        case (NSAlertAlternateReturn):
            [self _loadSettings];
            [(NSWindow *)contextInfo close];
            break;
            
        /* other is "Cancel", in which case, we do nothing */
    }
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
    /* we've finished editing a cell in the config list
     * make sure they didn't put in a blank or duplicate config name */
    if (control == configListTable) {
        NSString *value = [fieldEditor string];
        if ([value isEqualToString:@""]) {
            return NO;
        }
        
        NSIndexSet *indexes =
            [[configListController content]
             indexesOfObjectsPassingTest:^(id obj, NSUInteger idx, BOOL *stop) {
                 if ([value isEqualToString:((SKMConfigEntry *)obj).name])
                     return YES;
                 return NO;
             }];

        if ([indexes count] > 0)
            return NO;
    }
        
    return YES;
}

/* we implement this observation for firstResponder so that we can
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

    } else if ([keyPath isEqualToString:@"arrangedObjects"]) {
        if ([[configListController content] count] > 1) {
            [removeLocationButton setEnabled:YES];
        } else {
            [removeLocationButton setEnabled:NO];
        }

    } else if ([keyPath isEqualToString:@"selectionIndex"] ||
               [keyPath isEqualToString:@"arrangedObjects.isServerConfig"]) {
        [self _setViewState];

    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
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

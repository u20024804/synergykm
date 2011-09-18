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
@synthesize locationMenu;
@synthesize clientConfigButton;
@synthesize serverConfigButton;

@synthesize configListController;
@synthesize clientController;

@synthesize editLocationsPanel;
@synthesize editLocationsView;
@synthesize configListTable;
@synthesize addLocationButton;
@synthesize removeLocationButton;

@synthesize selectedLocationTitle;
@synthesize configList;


NSInteger compareViews(id firstView, id secondView, void *context);


- (void)_loadSettings
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSUInteger selectedConfigIndex = 0;
    
    NSArray *configArray = nil;
    NSData *encodedConfigList = [defaults objectForKey:@"config.list"];
    if (encodedConfigList != nil)
        configArray = [NSKeyedUnarchiver unarchiveObjectWithData:encodedConfigList];
    
    if (configArray == nil || [configArray count] == 0) {
        SKMConfigEntry *config = [[SKMConfigEntry alloc] init];
        config.name = NSLocalizedString(@"Default", nil);
        
        configList = [NSMutableArray arrayWithCapacity:1];
        [configList addObject:config];
        
        [config release];
        
    } else {
        configList = [NSMutableArray arrayWithCapacity:[configArray count]];
        [configList addObjectsFromArray:configArray];
        selectedConfigIndex = [defaults integerForKey:@"config.active"];
        if (selectedConfigIndex >= [configList count])
            selectedConfigIndex = 0;
    }
    
    [configListController setContent:configList];
    [configListController setSelectionIndex:selectedConfigIndex];
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
}

- (void)_setViewState
{
    SKMConfigEntry *config = [configListController selectedConfig];
    
    if (config != nil && config.isServerConfig) {
        [clientConfigButton setState:NSOffState];
        [serverConfigButton setState:NSOnState];
    } else {
        [serverConfigButton setState:NSOffState];
        [clientConfigButton setState:NSOnState];
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
    
    [configListController
     addObserver:self
     forKeyPath:@"arrangedObjects"
     options:NSKeyValueObservingOptionNew
     context:nil];
    
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

- (IBAction)changeConfigType:(id)sender
{
    SKMConfigEntry *config = [configListController selectedConfig];
    
    if (sender == clientConfigButton) {
        [serverConfigButton setState:NSOffState];
        if (config != nil)
            config.isServerConfig = FALSE;
    } else {
        [clientConfigButton setState:NSOffState];
        if (config != nil)
            config.isServerConfig = TRUE;
    }
}
        
- (IBAction)addLocation:(id)sender
{
    if (![editLocationsPanel makeFirstResponder:sender])
        return;
    
    SKMConfigEntry *newLocation =
        (SKMConfigEntry *)[configListController newObject];
    [configListController addObject:newLocation];
    [newLocation release];
    
    [removeLocationButton setEnabled:YES];
    
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

    if (selectedRow == rows - 1)
        selectedRow--;
    
    [configListTable
     selectRowIndexes:[NSIndexSet indexSetWithIndex:selectedRow]
     byExtendingSelection:NO];
    
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
    [self _loadSettings];
    [self _setViewState];
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
    [self _saveSettings];
    
    /* we're closing, notify ourselves that our window is closing */
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SKMLastWindowClosedNotification
     object:self];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
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

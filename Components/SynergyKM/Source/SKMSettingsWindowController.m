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
@synthesize editLocationsView;
@synthesize locationMenu;
@synthesize configListController;
@synthesize configListTable;
@synthesize addLocationButton;
@synthesize removeLocationButton;

@synthesize selectedLocationItem;
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
            selectedLocationItem = selectedItem;
        }
}

- (IBAction)addLocation:(id)sender
{
    NSString *newLabel = NSLocalizedString(@"New Location", nil);
    NSUInteger nextNewLocation = 0;
    NSUInteger i = 0;
    
    NSPredicate *match = [NSPredicate 
                          predicateWithFormat:@"SELF MATCHES %@",
                          [NSString
                           stringWithFormat:@"^%@(?: [1-9][0-9]*)?$",
                           newLabel]];
    NSArray *newLocations = [configList filteredArrayUsingPredicate:match];

    if ([newLocations count] > 0) {
        for (i = 0; i < [newLocations count]; i++) {
            NSString *str = (NSString *)[newLocations objectAtIndex:i];
            if ([str length] > [newLabel length]) {
                NSInteger locationId =
                    [[str substringFromIndex:([newLabel length] + 1)]
                     integerValue];
                if (locationId > nextNewLocation) {
                    nextNewLocation = locationId;
                }
            }
        }
        
        nextNewLocation++;
    }
    
    if (nextNewLocation > 0) {
        newLabel = [NSString stringWithFormat:@"%@ %ld", newLabel, nextNewLocation];
    }
    
    [configListController addObject:newLabel];
    [configListTable reloadData];
    
    [configListTable editColumn:0 row:([configList count] - 1) withEvent:nil select:YES];
}

- (IBAction)editLocations:(id)sender
{
    if ([locationMenu numberOfItems] <= 3) {
        [removeLocationButton setEnabled:NO];
    }
    
    [editLocationsPanel
     addObserver:self
     forKeyPath:@"firstResponder"
     options:NSKeyValueObservingOptionOld
     context:nil];
    
    [NSApp beginSheet:editLocationsPanel
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(closeEditingLocations:returnCode:contextInfo:)
          contextInfo:nil];
}

- (IBAction)finishEditingLocations:(id)sender
{
    [editLocationsPanel makeFirstResponder:sender];
    [locationMenu selectItem:selectedLocationItem];
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
        [configList addObject:@"Default"];
        [configList addObject:@"Home"];
        
        [configListController setContent:configList];
    }
    
    [super awakeFromNib];
}

- (void)windowDidLoad
{
    selectedLocationItem = [locationMenu selectedItem];
    if (selectedLocationItem == nil ||
        [selectedLocationItem isSeparatorItem] ||
        [[selectedLocationItem title]
         isEqualToString:NSLocalizedString(@"Edit Locations", nil)]) {
        [locationMenu selectItemAtIndex:0];
        selectedLocationItem = [locationMenu selectedItem];
    }

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

- (void)refreshLocationMenu
{
    while ([locationMenu numberOfItems] > 2) {
        [locationMenu removeItemAtIndex:0];
    }
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [editLocationsView
     sortSubviewsUsingFunction:compareViews
     context:nil];
}

NSInteger compareViews(id firstView, id secondView, void *context)
{
    NSResponder *res = [[firstView window] firstResponder];
    if (!res)
        return NSOrderedSame;
    
    if (res == firstView)
        return NSOrderedDescending;
    
    if ([res respondsToSelector:@selector(isDescendantOf:)]) {
        NSView *testView = (NSView *)res;
        if ([testView isDescendantOf:firstView])
            return NSOrderedDescending;
    }
    
    if ([firstView isKindOfClass:[NSScrollView class]])
        return NSOrderedDescending;
    
    return NSOrderedSame;
}

#pragma NSTableViewDataSource methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [locationMenu numberOfItems] - 2;
}

- (id)tableView:(NSTableView *)tv
objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    return [locationMenu itemTitleAtIndex:row];
}

- (void)tableView:(NSTableView *)tv
   setObjectValue:(id)obj
   forTableColumn:(NSTableColumn *)col
              row:(NSInteger)row
{
    NSLog(@"setObjectValue: called: %@", obj);
    NSMenuItem *item = [locationMenu itemAtIndex:row];
    [item setTitle:[(NSAttributedString *)obj string]];
    [tv reloadData];
}

@end

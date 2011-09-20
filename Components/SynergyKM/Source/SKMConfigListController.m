//
//  SKMConfigListController.m
//  SynergyKM
//
//  Created by Philip Molter on 8/28/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import "SKMConfigListController.h"
#import "SKMCommon.h"

@implementation SKMConfigListController

// TODO: Should this return the object or a copy of the object?
- (SKMConfigEntry *)selectedConfig {
    NSUInteger selectedIndex = [self selectionIndex];
    if (selectedIndex == NSNotFound)
        return nil;
    return (SKMConfigEntry *)[[self content] objectAtIndex:selectedIndex];
}

- (id)newObject {
    SKMConfigEntry *entry = (SKMConfigEntry *)[super newObject];
    
    NSString *newLabel = NSLocalizedString(@"New Location", nil);
    NSUInteger nextNewLocationId = 0;
    NSUInteger i = 0;

    /* match /^New Location(?: [1-9][0-9]*)?$/ to find all current entries
     * that might conflict with the New Location we're about to create */
    NSPredicate *match = [NSPredicate 
                          predicateWithFormat:@"SELF.name MATCHES %@",
                          [NSString
                           stringWithFormat:@"^%@(?: [1-9][0-9]*)?$",
                           newLabel]];
    NSArray *newLocations =
        [[self arrangedObjects] filteredArrayUsingPredicate:match];
    
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
    
    entry.name = newLabel;
    return entry;
}

/* we track this so anyone who cares can detect config changes */
- (void)didChangeValueForKey:(NSString *)key
{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:SKMConfigChangedNotification
     object:self];
    [super didChangeValueForKey:key];
}

@end

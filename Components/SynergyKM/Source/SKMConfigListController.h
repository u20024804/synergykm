//
//  SKMConfigListController.h
//  SynergyKM
//
//  Created by Philip Molter on 8/28/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SKMConfigEntry.h"

@interface SKMConfigListController : NSArrayController { }

- (SKMConfigEntry *)selectedConfig;

@end

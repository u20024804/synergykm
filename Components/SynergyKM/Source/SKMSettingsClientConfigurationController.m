//
//  SKMSettingsClientConfigurationController.m
//  SynergyKM
//
//  Created by Philip Molter on 8/4/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import <SystemConfiguration/SystemConfiguration.h>

#import "SKMSettingsClientConfigurationController.h"

@implementation SKMSettingsClientConfigurationController

@synthesize clientView;
@synthesize configurationTab;
@synthesize serverAddressField;
@synthesize clientNameLabel;

- (void)awakeFromNib
{
    NSLog(@"SKMSettingsClientConfigurationController awakeFromNib called");
    
    NSString *machineName = nil;
    machineName = (NSString *)SCDynamicStoreCopyLocalHostName(NULL);
    if (machineName != nil) {
        [clientNameLabel setStringValue:machineName];
    } else {
        [clientNameLabel setStringValue:NSLocalizedString(@"(not set)", nil)];
    }
    [machineName release];
}

@end

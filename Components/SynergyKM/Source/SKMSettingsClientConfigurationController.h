//
//  SKMSettingsClientConfigurationController.h
//  SynergyKM
//
//  Created by Philip Molter on 8/4/11.
//  Copyright 2011 Philip Molter. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SKMSettingsClientConfigurationController : NSObject {
    NSView *clientView;
    NSTabViewItem *configurationTab;
    NSTextField *serverAddressField;
    NSTextField *clientNameLabel;
}

@property (retain) IBOutlet NSView *clientView;
@property (retain) IBOutlet NSTabViewItem *configurationTab;
@property (retain) IBOutlet NSTextField *serverAddressField;
@property (retain) IBOutlet NSTextField *clientNameLabel;

- (void)updateMachineName;

@end

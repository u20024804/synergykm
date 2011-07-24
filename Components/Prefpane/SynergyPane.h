//
//  SynergyPane.h
//  SynergyPane
//
//Copyright (c) 2005, Bertrand Landry-Hetu
// All rights reserved.
//
//Redistribution and use in source and binary forms, with or without modification, 
//are permitted provided that the following conditions are met:
//
//	� 	Redistributions of source code must retain the above copyright notice, 
//      this list of conditions and the following disclaimer.
//	� 	Redistributions in binary form must reproduce the above copyright notice,
//      this list of conditions and the following disclaimer in the documentation 
//      and/or other materials provided with the distribution.
//	� 	Neither the name of the Bertrand Landry-Hetu nor the names of its 
//      contributors may be used to endorse or promote products derived from 
//      this software without specific prior written permission.
//
//THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
//"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
//LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
//A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
//OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
//TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, 
//OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
//OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
//(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
//USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import <PreferencePanes/PreferencePanes.h>

@class SPConfigurationManager;
@class SPNewLocationController;
@class SPEditLocationController;
@class SPClientTabController;
@class SPServerTabController;

@interface SynergyPane : NSPreferencePane 
{
    IBOutlet NSPopUpButton * locationPopup;
    IBOutlet NSPopUpButton * logLevelPopup;

    IBOutlet NSButton * applyBtn;

    IBOutlet NSButton * launchBtn;

    IBOutlet NSTextField * clientVersionInfo;
    IBOutlet NSTextField * serverVersionInfo;

    IBOutlet NSTextField * synergyStatus;
    
    IBOutlet NSMatrix * configTypeRadioBtn;

    IBOutlet NSButton * bonjourBtn;

    IBOutlet NSButton * menuVisibilityBtn;
    
    IBOutlet SPNewLocationController * newLocationController;
    IBOutlet SPEditLocationController * editLocationsController;
    IBOutlet SPClientTabController * clientTabController;
    IBOutlet SPServerTabController * serverTabController;
    
    SPConfigurationManager * configManager;
    
    NSBundle * thisBundle;
}

-(IBAction)launchAtLoginToggled: (id)sender;
-(IBAction)locationPopupChanged:(id)sender;
-(IBAction)bonjourToggled:(id)sender;
-(IBAction)menuVisibilityToggled:(id)sender;
-(IBAction)loggingLevelPopupChanged:(id)sender;
-(IBAction)openLogFile:(id)sender;

-(IBAction)apply:(id)sender;

-(IBAction)configurationTypeToggled:(id)sender;

-(SPConfigurationManager *)configManager;

@end

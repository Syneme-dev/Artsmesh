//
//  AMOSCMessageViewController.m
//  DemoUI
//
//  Created by xujian on 6/25/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMOSCMessageViewController.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "UIFramework/AMButtonHandler.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMPopUpView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMCoreData/AMCoreData.h"

@interface AMOSCMessageViewController ()<NSTextFieldDelegate, AMCheckBoxDelegeate, AMPopUpViewDelegeate>
@property (weak) IBOutlet AMFoundryFontView *searchField;
@property (weak) IBOutlet AMCheckBoxView *oscOnOff;
@property (weak) IBOutlet AMPopUpView *oscServerPopup;
@property (weak) IBOutlet NSTextField *selfdefServer;
@property (weak) IBOutlet NSButton *pinToTop;

@end

@implementation AMOSCMessageViewController
{
    NSViewController* _controller;
    NSMutableArray *_usersRunOscSrv;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    _controller = [[AMOSCGroups sharedInstance] getOSCMonitorUI];
    if (_controller != nil) {
        NSView* contentView = _controller.view;
        [self.view addSubview:_controller.view];
        NSRect rect = self.view.bounds;
        rect.size.height -= 21;
        _controller.view.frame = rect;
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        
        //Set search field
        self.searchField.delegate = self;
        
        //Ser OnOff Checkbox
        self.oscOnOff.title = @"On";
        self.oscOnOff.delegate = self;
        
        //Set Server Selection
        [self updateOSCServer];
        
        //set self define server
        [self.selfdefServer setEnabled:NO];
        
        //Set OnTop Button
        [AMButtonHandler changeTabTextColor:self.pinToTop toColor:UI_Color_blue];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(userGroupChanged:)
                                                     name:AM_LIVE_GROUP_CHANDED
                                                   object:nil];
    }
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)updateOSCServer
{
    [self.oscServerPopup removeAllItems];
    NSString *selectedServer = self.oscServerPopup.stringValue;
    
    _usersRunOscSrv = [[NSMutableArray alloc] init];
    BOOL online = [AMCoreData shareInstance].mySelf.isOnline;
    if (online) {
        AMLiveGroup *myLiveGroup = [[AMCoreData shareInstance] mergedGroup];
        NSArray *allUsers = [myLiveGroup usersIncludeSubGroup];
        
        for (AMLiveUser *user in allUsers) {
            if (user.oscServer) {
                [_usersRunOscSrv addObject:user];
            }
        }
    }else{
        AMLiveGroup *myLocalGroup = [[AMCoreData shareInstance] myLocalLiveGroup];
        
        for (AMLiveUser *user in myLocalGroup.users) {
            if (user.oscServer) {
                [_usersRunOscSrv addObject:user];
            }
        }
    }
    
    self.oscServerPopup.textColor = [NSColor grayColor];
    [self.oscServerPopup addItemWithTitle:@"Artsmesh.io"];
    [self.oscServerPopup addItemWithTitle:@"Self Define"];
    for (AMLiveUser *user in _usersRunOscSrv) {
        [self.oscServerPopup addItemWithTitle:user.nickName];
    }

    if (![selectedServer isEqualToString:@""]) {
        [self.oscServerPopup selectItemWithTitle:selectedServer];
    }else{
        [self.oscServerPopup selectItemAtIndex:0];
    }

    self.oscServerPopup.delegate = self;
}


-(void)userGroupChanged:(NSNotification *)notification
{
    [self updateOSCServer];
}

-(void)onChecked:(AMCheckBoxView *)sender
{
    if(self.oscOnOff.checked == YES)
    {
        if (self.oscServerPopup.stringValue ) {
            if ([self.oscServerPopup.stringValue isEqualToString:@""]) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"NO OSC Server"
                                                 defaultButton:@"Ok"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"Maybe the user running osc server quit, please select another one!"];
                [alert runModal];
                return;
            }
        }
        
        NSString *serverAddr;
        if ([self.oscServerPopup.stringValue isEqualToString:@"Self Define"]) {
            serverAddr = self.selfdefServer.stringValue;
            
        }else if ([self.oscServerPopup.stringValue isEqualToString:@"Artsmesh.io"]){
            serverAddr = [[NSUserDefaults standardUserDefaults]
                          stringForKey:Preference_General_GlobalServerAddr];
            
        }else{
            for (AMLiveUser *user in _usersRunOscSrv) {
                if ([user.nickName isEqualToString:self.oscServerPopup.stringValue]) {
                    
                    AMLiveGroup *myCluster = [[AMCoreData shareInstance] myLocalLiveGroup];
                    BOOL bFind = NO;
                    for (AMLiveUser *localUser in myCluster.users) {
                        if ([localUser.nickName isEqualToString:user.nickName]) {
                            bFind = true;
                        }
                    }
                    
                    if (bFind) {
                        serverAddr = user.privateIp;
                    }else{
                        serverAddr = user.publicIp;
                    }
                }
            }
        }
        
        [[AMOSCGroups sharedInstance] startOSCGroupClient:serverAddr];
        [self.oscServerPopup setEnabled:NO];
        [self.selfdefServer setEnabled:NO];
        
        self.oscOnOff.title = @"Off";
    }else{
        
        [[AMOSCGroups sharedInstance] stopOSCGroupClient];
        self.oscOnOff.title = @"On";
        
        [self.oscServerPopup setEnabled:YES];
        [self.selfdefServer setEnabled:YES];
    }
}

-(void)itemSelected:(AMPopUpView *)sender
{
    if ([self.oscServerPopup.stringValue isEqualToString:@"Self Define"]) {
        [self.selfdefServer setEnabled:YES];
        self.selfdefServer.stringValue = [[NSUserDefaults  standardUserDefaults]
                                          stringForKey:Preference_OSC_Client_ServerAddr];
    }else{
        [self.selfdefServer setEnabled:NO];
        self.selfdefServer.stringValue = @"";
    }
}

- (IBAction)searchTextChanged:(id)sender
{
//    [self.searchField resignFirstResponder];
//    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:self.searchField.stringValue];
}


-(void)controlTextDidChange:(NSNotification *)obj
{
    [self.searchField resignFirstResponder];
    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:self.searchField.stringValue];
}

-(void)cancelOperation:(id)sender
{
    self.searchField.stringValue = @"";
    [self.searchField resignFirstResponder];
    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:@""];
}

@end

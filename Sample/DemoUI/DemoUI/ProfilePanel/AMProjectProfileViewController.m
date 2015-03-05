//
//  AMProjectProfileViewController.m
//  DemoUI
//
//  Created by 王为 on 23/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMProjectProfileViewController.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMCoreData/AMCoredata.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMMesher/AMMesher.h"

@interface AMProjectProfileViewController ()<AMCheckBoxDelegeate>

@property (weak) IBOutlet AMFoundryFontView *projectNameField;
@property (weak) IBOutlet NSImageView *projectAvatar;
@property (weak) IBOutlet AMCheckBoxView *broadcastBox;
@property (weak) IBOutlet AMFoundryFontView *broadcastURLField;
@property (weak) IBOutlet AMFoundryFontView *projectDescription;
@property (weak) IBOutlet NSImageView *statusLight;

@end

@implementation AMProjectProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self loadProject:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProject:) name:AM_LIVE_GROUP_CHANDED object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadAvatar
{
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if (myGroup.broadcasting) {
        [self.projectAvatar setImage:[NSImage imageNamed:@"group_broadcast_med"]];
        
    }else{
        
        [self.projectAvatar setImage:[NSImage imageNamed:@"clipboard"]];
    }
}


-(void)setBroadcastBox
{
    self.broadcastBox.title = @"STREAM";
    self.broadcastBox.delegate  = self;
    
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    self.broadcastBox.checked = myGroup.broadcasting;
}


-(void)setStatus
{
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if (localGroup.broadcasting) {
        [self.statusLight setImage:[NSImage imageNamed:@"project_broadcast"]];
    }else{
        [self.statusLight setImage:[NSImage imageNamed:@"group_unmeshed_icon"]];
    }
}

-(void)setBroadcastURL
{
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    if ( [localGroup.broadcastingURL length] > 0 ) {
        [self.broadcastURLField setStringValue:localGroup.broadcastingURL];
    }
}


-(void)loadProject:(NSNotification *)notification
{
    [self setStatus];
    [self loadAvatar];
    [self setBroadcastBox];
    [self setBroadcastURL];
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    NSUserDefaults *defaults = [AMPreferenceManager standardUserDefaults];
    [defaults setObject:myGroup.project forKey:Preference_Key_Cluster_Project];
    [defaults setObject:myGroup.projectDescription forKey:Preference_Key_Cluster_Project_Descrition];
    [defaults setObject:myGroup.broadcastingURL forKey:Preference_Key_Cluster_BroadcastURL];
}

-(void)onChecked:(AMCheckBoxView*)sender
{
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    myGroup.broadcasting = sender.checked;
    
    [[AMMesher sharedAMMesher] updateGroup];
    [self startBlickingStatus];
}

- (IBAction)projectNameChanged:(NSTextField *)sender
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.project isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_Project];
    }
    
    group.project= sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}

- (IBAction)broadcastURLChanged:(NSTextField *)sender
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.broadcastingURL isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_BroadcastURL];
    }
    
    group.broadcastingURL= sender.stringValue;
    
    if (group.broadcasting) {
        [[AMMesher sharedAMMesher] updateGroup];
        [self startBlickingStatus];
    }
}

- (IBAction)projectDesctiptionChanged:(NSTextField *)sender
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.projectDescription isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_Project_Descrition];
    }
    
    group.projectDescription= sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}


-(void)startBlickingStatus
{
    [self.statusLight setImage:[NSImage imageNamed:@"synchronizing_icon"]];
    [self performSelector:@selector(setStatus) withObject:nil afterDelay:1];
}


@end

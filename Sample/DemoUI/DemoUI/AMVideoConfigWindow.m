//  AMVideoConfigWindow.m
//  RoutingPanel
//
//  Created by whiskyzed on 12/3/15.
//  Copyright (c) 2015 AM. All rights reserved.


#import "AMVideoConfigWindow.h"
#import "AMCoreData/AMCoreData.h"
#import "AMVideoRouteViewController.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMAudio/AMAudio.h"
#import "UIFramework/AMWindow.h"


@interface AMVideoConfigWindow ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>

@property (weak) IBOutlet AMPopUpView *roleSelecter;
@property (weak) IBOutlet AMPopUpView *peerSelecter;
@property (weak) IBOutlet AMFoundryFontView *peerAddress;
@property (weak) IBOutlet AMFoundryFontView *peerName;
@property (weak) IBOutlet AMPopUpView *portOffsetSelector;
//@property (weak) IBOutlet NSTextField *rCount;

@property (weak) IBOutlet AMPopUpView *deviceSelector;
@property (weak) IBOutlet NSTextField *bitRateRes;
@property (weak) IBOutlet NSButton *createBtn;
@property (weak) IBOutlet NSTextField *channeCount;
@property (weak) IBOutlet NSButton *closeBtn;
@property NSArray* allUsers;
@property  AMLiveUser* curPeer;
@end


@implementation AMVideoConfigWindow {
    NSTask *_ffmpegTask;
}

-(instancetype) init{
    if (self = [super init]) {
        _videoConfig = [[AMVideoConfig alloc] init];
    }
    
    return self;
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self setUpUI];
    [self loadDefaultPref];
    [self setPeerList];
    [self initPortOffset];
    [self populateDevicesList];
}

-(void)setUpUI
{
    [AMButtonHandler changeTabTextColor:self.createBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.closeBtn toColor:UI_Color_blue];
    [self.createBtn.layer setBorderWidth:1.0];
    [self.createBtn.layer setBorderColor: UI_Color_blue.CGColor];
    [self.closeBtn.layer  setBorderWidth:1.0];
    [self.closeBtn.layer  setBorderColor: UI_Color_blue.CGColor];

    
    [self.roleSelecter addItemWithTitle:@"SENDER"];
    [self.roleSelecter addItemWithTitle:@"RECEIVER"];
    
    [self.peerAddress setEnabled:NO];
    [self.peerName setEnabled:NO];
    
    self.portOffsetSelector.delegate = self;
    self.deviceSelector.delegate = self;
    self.roleSelecter.delegate = self;
    self.peerSelecter.delegate = self;
}


-(void)setPeerList
{
    AMCoreData* dataStore = [AMCoreData shareInstance];
    AMLiveUser* mySelf = dataStore.mySelf;
    
    if (!mySelf.isOnline)
    {
        self.allUsers = dataStore.myLocalLiveGroup.users;
    }else{
        AMLiveGroup* mergedGroup = [dataStore mergedGroup];
        self.allUsers = [mergedGroup usersIncludeSubGroup];
    }
    
    int firstIndexInUserlist = -1;
    for (int i = 0; i < [self.allUsers count]; i++) {
        
        AMLiveUser* user = self.allUsers[i];
        
        //Two User at most have one connection
        BOOL alreadyConnect = NO;
        for(AMJacktripInstance* jacktrip in [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances){
            if ([user.nickName isEqualToString:jacktrip.instanceName]){
                alreadyConnect = YES;
                break;
            }
        }
        
        if (alreadyConnect) {
            continue;
        }
        
        if([user.userid isNotEqualTo:mySelf.userid]){
            [self.peerSelecter addItemWithTitle:user.nickName];
            firstIndexInUserlist = (firstIndexInUserlist == -1)?i:firstIndexInUserlist;
        }
    }
    
    [self.peerSelecter addItemWithTitle:@"ip address"];
    
    if (firstIndexInUserlist == -1) {
        //no one add to list except ip address
        [self.peerAddress setEnabled:YES];
        self.peerAddress.stringValue = @"";
        
        [self.peerName setEnabled:YES];
        self.peerName.stringValue = @"";
        
    }else{
        //auto select a user
        if (!mySelf.isOnline) {
            self.peerAddress.stringValue = [self.allUsers[firstIndexInUserlist]
                                            privateIp];
        }else{
            
            //TODO: bug! if local groupmates meshed, can not use private ip
            self.peerAddress.stringValue = [self.allUsers[firstIndexInUserlist]
                                            publicIp];
        }
        
        self.peerName.stringValue = [self.allUsers [firstIndexInUserlist]
                                     nickName];
        [self.peerAddress setEnabled:NO];
        [self.peerName setEnabled:NO];
    }
    
    [self.peerSelecter selectItemAtIndex:0];
}


-(void)itemSelected:(AMPopUpView*)sender
{
    if ([sender isEqual:self.peerSelecter]) {
        [self peerSelectedChanged:sender];
    }
}


-(void)initPortOffset
{
    [self.portOffsetSelector removeAllItems];
    
    for (NSUInteger i = 0; i <10; i++) {
        
        BOOL inUse = NO;
        for (AMJacktripInstance* jacktrip in [[AMAudio sharedInstance] audioJacktripManager].jackTripInstances) {
            if(jacktrip.portOffset == i){
                inUse = YES;
                break;
            }
        }
        
        if(!inUse){
            NSString* str = [NSString stringWithFormat:@"%lu", (unsigned long)i];
            [self.portOffsetSelector addItemWithTitle:str];
        }
    }
    
    [self.portOffsetSelector selectItemAtIndex:0];
}


-(void)loadDefaultPref
{
    NSString *roleStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_Role];
    [self.roleSelecter selectItemWithTitle:roleStr];
    
    NSString *chanCountStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_ChannelCount];
    self.channeCount.stringValue = chanCountStr;
    
    //NSString *prStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_PR];
    //self.rCount.stringValue = prStr;
    
    NSString *brrStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_BRR];
    self.bitRateRes.stringValue = brrStr;
    
}

/** Start FFMPEG Related Functions **/

// Make FFMPEG call to find AVFoundation Devices on machine
-(void)populateDevicesList {
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSString* launchPath =[mainBundle pathForAuxiliaryExecutable:@"ffmpeg"];
    launchPath = [NSString stringWithFormat:@"\"%@\"",launchPath];
    
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"%@ -f avfoundation -list_devices true -i \"\"",
                                launchPath];
    _ffmpegTask = [[NSTask alloc] init];
    _ffmpegTask.launchPath = @"/bin/bash";
    _ffmpegTask.arguments = @[@"-c", [command copy]];
    _ffmpegTask.terminationHandler = ^(NSTask* t){
        
    };
    
    [_ffmpegTask setStandardOutput:pipe];
    [_ffmpegTask setStandardError: [_ffmpegTask standardOutput]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotDeviceList:) name:NSFileHandleDataAvailableNotification object:file];
    
    
    [_ffmpegTask launch];
    
    [file waitForDataInBackgroundAndNotify];
}

// Devices list returned from FFMPEG
// Now throw the video options in the device dropdown
- (void) gotDeviceList : (NSNotification*)notification
{
    //We have data from ffmpeg devices_list command
    //Need to pull out the relevant devices & populate the device dropdown
    
    NSFileHandle *outputFile = (NSFileHandle *) [notification object];
    NSData *data = [outputFile availableData];
    
    if([data length]) {
        NSMutableArray *tempVidDevices = [[NSMutableArray alloc] init];
        
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSArray *brokenByLines=[temp componentsSeparatedByString:@"\n"];
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.\\] "
                                                                               options:NSRegularExpressionCaseInsensitive error:nil];
        BOOL isVideoDeviceLine = NO;
        BOOL isAudioDeviceLine = NO;
        
        for (NSString *line in brokenByLines) {
            
            if ([line rangeOfString:@"[AVFoundation input device"].location != NSNotFound) {
                NSString *modifiedString = [regex stringByReplacingMatchesInString:line options:0 range:NSMakeRange(0, [line length]) withTemplate:@"||"];
                if(isVideoDeviceLine == YES && [line rangeOfString:@"devices:"].location == NSNotFound) {
                    //Handle the video device string
                    NSString *deviceString = [[modifiedString componentsSeparatedByString:@"||"] lastObject];
                    
                    [tempVidDevices addObject:deviceString];
                    
                }
                
                //Find video device line
                if ([line rangeOfString:@"video devices:"].location != NSNotFound) {
                    isVideoDeviceLine = YES;
                    isAudioDeviceLine = NO;
                }
                //Find audio device line
                if ([line rangeOfString:@"audio devices:"].location != NSNotFound) {
                    isVideoDeviceLine = NO;
                    isAudioDeviceLine = YES;
                }
            }
        }
        
        if ([tempVidDevices count] > 0) {
            NSArray *videoDevicesToInsert = [tempVidDevices copy];
            
            [self.deviceSelector removeAllItems];
            [self.deviceSelector addItemsWithTitles:videoDevicesToInsert];
            
            [self selectDevice:self.deviceSelector :[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_In_Device]];
        }
        
        [outputFile waitForDataInBackgroundAndNotify];
    }
}

// Select a new device option
-(void) selectDevice :(AMPopUpView *)theDropDown :(NSString *)deviceName {
    [theDropDown selectItemAtIndex:0];
    
    [theDropDown selectItemWithTitle:deviceName];
}


/** End FFMPEG Related Functions **/

- (void)peerSelectedChanged:(AMPopUpView *)sender
{
    if ([self.peerSelecter.stringValue isEqualToString:@"ip address"]) {
        
        [self.peerAddress setEnabled:YES];
        [self.peerName setEnabled:YES];
        
        self.peerAddress.stringValue = @"";
        self.peerName.stringValue = @"";
        
    }else{
        [self.peerAddress setEnabled:NO];
        [self.peerName setEnabled:NO];
        
        AMCoreData* sharedStore = [AMCoreData shareInstance];
        AMLiveUser* mySelf = sharedStore.mySelf;
        
        for (AMLiveUser* user in self.allUsers) {
            
            if([user.nickName isEqualToString:self.peerSelecter.stringValue]){
              // We just distingush the private/public ip on ipv4
                if(!mySelf.isOnline){
                    self.peerAddress.stringValue = user.privateIp;
                }else{
                    self.peerAddress.stringValue = user.publicIp;
                }
                break;
            }
        }
        
        self.peerName.stringValue = self.peerSelecter.stringValue;
    }
}


-(BOOL)checkouJacktripParams
{
    if ([self.roleSelecter.stringValue isNotEqualTo:@"SERVER"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"CLIENT"]) {
        return NO;
    }
    
    if ([self.roleSelecter.stringValue isEqualTo:@"SERVER"]){
        if ([self.peerName.stringValue isEqualTo:@""]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a jacktrip server role you must enter clientname."];
            [alert runModal];
            return NO;
        }
        
    }else if([self.roleSelecter.stringValue isEqualTo:@"CLIENT"]||
             [self.peerAddress.stringValue isEqualTo:@""]){
        if([self.peerName.stringValue isEqualTo:@""]){
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a jacktrip client role you must enter both ip address and clientname "];
            [alert runModal];
            return NO;
        }
    }
    
    if ([self.channeCount.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"channel count parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }
    
    /**
    if ([self.rCount.stringValue intValue] <= 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"rcount parameter can not be less than zero"];
        [alert runModal];
        return NO;
    }**/
    
    return YES;
}

- (BOOL)checkP2PVideoParams {
    if ([self.roleSelecter.stringValue isNotEqualTo:@"SERVER"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"CLIENT"]) {
        return NO;
    }
    
    return YES;
}

- (IBAction)startP2PVideo:(NSButton *)sender {
    if (![self checkP2PVideoParams]) {
        return;
    }
    
    [self.window close];
}


- (IBAction)closeClicked:(NSButton *)sender
{
    [self.window close];
}


- (void) onChecked:(AMCheckBoxView *)sender
{
    
}
@end

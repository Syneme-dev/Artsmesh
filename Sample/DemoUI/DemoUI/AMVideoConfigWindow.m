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
#import "AMFFmpegConfigs.h"
#import "AMFFmpeg.h"


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
@property (weak) IBOutlet NSButton *closeBtn;
@property NSArray* allUsers;
@property  AMLiveUser* curPeer;

@property (weak) IBOutlet AMFoundryFontView *vidOutSizeTextField;
@property (weak) IBOutlet AMFoundryFontView *vidFrameRateTextField;
@property (weak) IBOutlet AMFoundryFontView *vidBitRateTextField;
@property (weak) IBOutlet AMPopUpView *vidCodec;
@property (strong) IBOutlet AMCheckBoxView *useIpv6CheckboxView;

@end


@implementation AMVideoConfigWindow {
    NSTask *_ffmpegTask;
}

-(instancetype) init{
    if (self = [super init]) {

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
    
    _videoConfig = [[AMVideoConfig alloc] init];
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
    [self.roleSelecter addItemWithTitle:@"DUAL"];
    [self.roleSelecter addItemWithTitle:@"YOUTUBE"];
    [self.roleSelecter selectItemWithTitle:@"SENDER"];
    
    [self.vidCodec addItemWithTitle:@"H.264"];
    [self.vidCodec addItemWithTitle:@"MPEG2"];
    [self.vidCodec addItemWithTitle:@"VP6"];
    [self.vidCodec selectItemWithTitle:@"H.264"];
    
    [self.peerAddress setEnabled:NO];
    [self.peerName setEnabled:NO];
    
    self.portOffsetSelector.delegate = self;
    self.deviceSelector.delegate = self;
    self.roleSelecter.delegate = self;
    self.peerSelecter.delegate = self;
    self.vidCodec.delegate = self;
    
    self.useIpv6CheckboxView.title = @"USE IPV6";
    self.useIpv6CheckboxView.delegate = self;
    
    [self loadVidSettingsValues];
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
        
        if([user.userid isNotEqualTo:mySelf.userid]){
            [self.peerSelecter addItemWithTitle:user.nickName];
            firstIndexInUserlist = (firstIndexInUserlist == -1)?i:firstIndexInUserlist;
        }
    }
    
    [self.peerSelecter addItemWithTitle:@"ip address"];
    [self.peerSelecter addItemWithTitle:@"self"];
    
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
    
    //NSString *chanCountStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_ChannelCount];
    //self.channeCount.stringValue = chanCountStr;
    
    //NSString *prStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_PR];
    //self.rCount.stringValue = prStr;
    
    NSString *brrStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jacktrip_BRR];
    self.bitRateRes.stringValue = brrStr;
    
}

/** Start FFMPEG Related Functions **/

// Make FFMPEG call to find AVFoundation Devices on machine
-(void)populateDevicesList {
    AMFFmpeg *ffmpeg = [[AMFFmpeg alloc] init];
    NSFileHandle *file = [ffmpeg populateDevicesList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotDeviceList:) name:NSFileHandleDataAvailableNotification object:file];
    
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

// Send video to a second machine using FFMPEG
-(void)sendP2P {
    
    /** TO-DO either add buffsize as a selectable field **/
    
    NSString *vidFrameRate = [self.vidFrameRateTextField stringValue];
    if ([vidFrameRate length] < 1) {
        vidFrameRate = @"30";
    }
    NSString *vidBitRate = [self.vidBitRateTextField stringValue];
    if ([vidBitRate length] < 1) {
        vidBitRate = @"800k";
    }
    
    NSString *vidOutSize = [self.vidOutSizeTextField stringValue];
    if ([vidOutSize length] < 1) {
        vidOutSize = @"1280x720";
    }

    //Check Address for ipv6 & convert to that format, if desired
    int selectedVidDevice = (int) self.deviceSelector.indexOfSelectedItem;
    NSString *peerAddr = [self.peerAddress stringValue];
    if (self.useIpv6CheckboxView.checked) {
        peerAddr = [NSString stringWithFormat:@"[%@]", self.peerAddress.stringValue];
    }
    
    //Set up ffmpeg configs
    AMFFmpegConfigs *cfgs = [[AMFFmpegConfigs alloc] init];
    [cfgs setSending:YES];
    cfgs.videoOutSize = vidOutSize;
    cfgs.videoFrameRate = vidFrameRate;
    cfgs.videoBitRate = vidBitRate;
    cfgs.videoDevice = [NSString stringWithFormat:@"%d", selectedVidDevice];
    cfgs.portOffset = self.portOffsetSelector.stringValue;
    cfgs.videoCodec = self.vidCodec.stringValue;
    cfgs.serverAddr = peerAddr;
    
    AMFFmpeg *ffmpeg = [[AMFFmpeg alloc] init];
    
    if(![ffmpeg sendP2P:cfgs]){
        NSAlert *alert = [NSAlert alertWithMessageText:@"ffmpeg stream failed!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"maybe port conflict!"];
        [alert runModal];
    };
     
    [self.window close];
}

// Receive sent p2p video from ffmpeg via ffplay (potentially mplayer also)
- (void)receiveP2P {
    
    NSString *peerAddr = [self.peerAddress stringValue];
    if (self.useIpv6CheckboxView.checked) {
        peerAddr = [NSString stringWithFormat:@"[%@]", [self.peerAddress stringValue]];
    }
    
    //Set up ffmpeg configs
    AMFFmpegConfigs *cfgs = [[AMFFmpegConfigs alloc] init];
    [cfgs setSending:NO];
    cfgs.serverAddr = peerAddr;
    cfgs.portOffset = [self.portOffsetSelector stringValue];
    
    if ([self.roleSelecter.stringValue isEqualTo:@"DUAL"]) {
        //Iterate portOffset by +1 to avoid conflict with concurrent P2P
        //send command, if sending to self
         
        //Address needs to be myself, if dual selected
        AMCoreData* sharedStore = [AMCoreData shareInstance];
        AMLiveUser* mySelf = sharedStore.mySelf;
        
        for (AMLiveUser* user in self.allUsers) {
            if([user.nickName isEqualToString:self.peerSelecter.stringValue]){
                // We just distingush the private/public ip on ipv4
                if (!self.useIpv6CheckboxView.checked) {
                    if(!mySelf.isOnline){
                        cfgs.serverAddr = user.privateIp;
                    }else{
                        //self.peerAddress.stringValue = user.publicIp;
                        cfgs.serverAddr = user.privateIp;
                    }
                }else{ //when the ipv6 checked, we just use
                    cfgs.serverAddr = user.ipv6Address;
                }
                break;
            }
        }
    }
    
    AMFFmpeg *ffmpeg = [[AMFFmpeg alloc] init];
    
    if(![ffmpeg receiveP2P:cfgs]){
        NSAlert *alert = [NSAlert alertWithMessageText:@"ffplay failed to play stream!" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"maybe port conflict!"];
        [alert runModal];
    };
    
    [self.window close];
}

/** End FFMPEG Related Functions **/

- (void)peerSelectedChanged:(AMPopUpView *)sender
{
    if ([self.peerSelecter.stringValue isEqualToString:@"ip address"]) {
        
        [self.peerAddress setEnabled:YES];
        [self.peerName setEnabled:YES];
        
        self.peerAddress.stringValue = @"";
        self.peerName.stringValue = @"";
        
    }else if (![self.peerSelecter.stringValue isEqualToString:@"self"]) {
        [self.peerAddress setEnabled:NO];
        [self.peerName setEnabled:NO];
        
        AMCoreData* sharedStore = [AMCoreData shareInstance];
        AMLiveUser* mySelf = sharedStore.mySelf;
        
        for (AMLiveUser* user in self.allUsers) {
            if([user.nickName isEqualToString:self.peerSelecter.stringValue]){
              // We just distingush the private/public ip on ipv4
              if (!self.useIpv6CheckboxView.checked) {
                  if(!mySelf.isOnline){
                    self.peerAddress.stringValue = user.privateIp;
                  }else{
                    //self.peerAddress.stringValue = user.publicIp;
                    self.peerAddress.stringValue = user.privateIp;
                  }
                }else{ //when the ipv6 checked, we just use
                    self.peerAddress.stringValue = user.ipv6Address;
                }
                break;
            }
        }
        
        self.peerName.stringValue = self.peerSelecter.stringValue;
    } else {
        //self selected
        AMCoreData* sharedStore = [AMCoreData shareInstance];
        AMLiveUser* mySelf = sharedStore.mySelf;
        
        [self.peerAddress setEnabled:NO];
        [self.peerName setEnabled:NO];
        
        self.peerName.stringValue = mySelf.nickName;
        
        if (!self.useIpv6CheckboxView.checked) {
            self.peerAddress.stringValue = mySelf.privateIp;
        } else {
            self.peerAddress.stringValue = mySelf.ipv6Address;
        }
    }
}

- (void)loadVidSettingsValues {
    [self.vidOutSizeTextField setStringValue:[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Out_Size]];
    [self.vidFrameRateTextField setStringValue:[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Frame_Rate]];
    [self.vidBitRateTextField setStringValue:[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Bit_Rate]];
    [self.vidCodec selectItemWithTitle:[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Format]];
}


-(void)saveVideoConfig
{
    AMCoreData* sharedStore = [AMCoreData shareInstance];
    _videoConfig.myself = sharedStore.mySelf;
 
    _videoConfig.peerIP = [self.peerAddress stringValue];
    
    if (self.useIpv6CheckboxView.checked) {
        _videoConfig.peerIP = [NSString stringWithFormat:@"[%@]", self.peerAddress.stringValue];
    }
    int portOffset = (int) [[self.portOffsetSelector stringValue] integerValue];
    _videoConfig.peerPort = 5564 + portOffset;
    
    _videoConfig.role = self.roleSelecter.stringValue;
    return;
}


- (BOOL)checkP2PVideoParams {
    AMCoreData* sharedStore = [AMCoreData shareInstance];
    if ([self.roleSelecter.stringValue isNotEqualTo:@"SENDER"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"RECEIVER"] &&
        [self.roleSelecter.stringValue isNotEqualTo:@"DUAL"]) {
        return NO;
    }
    if([self.roleSelecter.stringValue isEqualTo:@"CLIENT"]||
       [self.peerAddress.stringValue isEqualTo:@""]){
        if([self.peerName.stringValue isEqualTo:@""]){
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"For a P2P video client role you must enter an IP Address"];
            [alert runModal];
            return NO;
        }
    }
    if ([self.roleSelecter.stringValue isEqualTo:@"DUAL"]) {
        if([self.peerName.stringValue isEqualTo:sharedStore.mySelf.nickName]) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Dual mode cannot be utilized on self."];
            [alert runModal];
            return NO;
        }
    }
    
    return YES;
}

- (IBAction)startP2PVideo:(NSButton *)sender {
    if (![self checkP2PVideoParams]) {
        return;
    }
    
    if ([self.roleSelecter.stringValue isEqualTo:@"SENDER"]) {
        // Run FFMPEG to a second machine, given set params
        [self sendP2P];
        
    } else if ([self.roleSelecter.stringValue isEqualTo:@"RECEIVER"]) {
        // Run FFPLAY on local machine to capture sent UDP video
        [self receiveP2P];
    } else if ([self.roleSelecter.stringValue isEqualTo:@"DUAL"]) {
        // Do both!
        [self sendP2P];
        [self receiveP2P];
    }
    
    [self saveVideoConfig];
    [[NSNotificationCenter defaultCenter] postNotificationName:AMVideoDeviceNotification object:nil];
}


- (IBAction)closeClicked:(NSButton *)sender
{
    //AMFFmpeg *ffmpeg = [[AMFFmpeg alloc] init];
    //[ffmpeg stopFFmpeg];
    
    [self.window close];
}


- (void) onChecked:(AMCheckBoxView *)sender
{
    
    if (sender == self.useIpv6CheckboxView) {
        [self peerSelectedChanged:self.peerSelecter];
    }
}
@end

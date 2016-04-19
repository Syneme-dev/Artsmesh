//
//  AMGPlusViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMVideoSettingsVC.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMCoreData/AMCoreData.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMMesher/AMMesher.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/NSView_Constrains.h"


@interface AMVideoSettingsVC ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>

@property (strong) GTLServiceYouTube *youTubeService;
@property (strong) GTLServiceTicket *channelIdTicket;
@property (strong) GTLServiceTicket *channelCurrentEventsTicket;
@property (strong) GTLServiceTicket *broadcastTicket;
@property (strong) GTLServiceTicket *liveStreamTicket;
@property (strong) GTLServiceTicket *broadcastBindTicket;
@property (strong) NSString *channelId;
@property (strong) NSString *broadcastTitle;
@property (strong) NSString *broadcastDesc;
@property (strong) NSString *broadcastURL;
@property (strong) NSString *broadcastPrivacy;
@property (strong) NSDate *broadcastSchedStart;
@property (strong) NSDate *broadcastSchedEnd;


@end

@implementation AMVideoSettingsVC
{
    AMFFmpeg *ffmpeg;
    AMFFmpegConfigs *cfgs;
    
    NSString *statusNetEventURLString;
    Boolean needsToConfirmCreate;
    Boolean needsToConfirmDelete;
    Boolean needsToConfirmEdit;
    Boolean needsToConfirmGoLive;
    NSString *statusNetURL;
    NSString *myUserName;
    NSString *infoUrl;
    NSString *myBlogUrl;
    NSString *publicBlogUrl;
    Boolean isInfoPage;
    NSString *loginURL;
    NSString *eventURL;
    
    NSString *kKeychainItemName;
    NSString *scope;
    NSString *kMyClientID;
    NSString *kMyClientSecret;
    
    NSViewController* _detailViewController;
    NSMutableArray *_tabControllers;
    
    AMEventsManagerViewController *eventsManagerVC;
    
    // Settings Tab Initial Variables
    NSMutableArray *videoDevices;
    NSArray *videoFrameRates;
    NSArray *videoInputSizes;
    NSArray *videoOutputSizes;
    NSArray *videoFormats;
    NSMutableArray *audioDevices;
    NSArray *audioFormats;
    NSArray *audioBitRates;
    NSArray *audioSampleRates;
    
    NSString *vidInSizePref;
    NSString *vidInSizeCustomWPref;
    NSString *vidInSizeCustomHPref;
    NSString *vidInSizeUseCustomPref;
    NSString *vidOutSizePref;
    NSString *vidOutSizeCustomWPref;
    NSString *vidOutSizeCustomHPref;
    NSString *vidOutSizeUseCustomPref;
    NSString *vidDevicePref;
    NSString *vidFormatPref;
    NSString *vidFrameRatePref;
    NSString *vidBitRatePref;
    NSString *audDevicePref;
    NSString *audFormatPref;
    NSString *audSampleRatePref;
    NSString *audBitRatePref;
    NSString *baseUrlPref;
    NSString *streamKeyPref;
    
    int vidSelectedDeviceIndexPref;
    int audSelectedDeviceIndexPref;
    
    NSTask *_ffmpegTask;
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
    ffmpeg = [[AMFFmpeg alloc] init];
    cfgs = [[AMFFmpegConfigs alloc] init];
    
    //Set up UI Elements and theme stuff
    
    [self.settingsCancelBtn setButtonTitle:@"CANCEL"];
    [self.settingsSaveBtn setButtonTitle:@"SAVE"];
    [self.settingsRefreshBtn setButtonTitle:@"REFRESH"];
    
    [self updateAMStandardButtons];
    
    
    [self establishYouTubeVars];
    [self initYoutubeService];
    
    needsToConfirmCreate = TRUE;
    needsToConfirmDelete = TRUE;
    needsToConfirmEdit = TRUE;
    needsToConfirmGoLive = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBoxChanged:) name:AM_CHECKBOX_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(googleAccountChanged:) name:AM_GOOGLE_ACCOUNT_CHANGED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpResignKeyWindow:) name:
     NSWindowDidResignKeyNotification object:nil];
    
    [self updateUI];
    
    
    // Configure Settings Stuff
    
    [self setupSettingsTab];
}

-(void)registerTabButtons
{
    super.tabs=self.groupTabView;
    self.tabButtons =[[NSMutableArray alloc]init];
    self.showingTabsCount=1;
}

-(void)viewDidLoad
{
    [self loadTabViews];
}

-(void)loadTabViews
{
    for (NSTabViewItem* tabItem in [self.groupTabView tabViewItems]) {
        
        /*Here we use the class name to load the controller so the
         tab identifier must equal to the tabview's subview controller's name*/
        if (_tabControllers == nil) {
            _tabControllers = [[NSMutableArray alloc] init];
        }
        
        NSString *tabViewControllerName = tabItem.identifier;
        id obj = [[NSClassFromString(tabViewControllerName) alloc] init];
        if ([obj isKindOfClass:[NSViewController class]]) {
            NSViewController *controller = (NSViewController *)obj;
            
            [tabItem.view addFullConstrainsToSubview:controller.view];
            [_tabControllers addObject:controller];
        }
    }
}


- (NSDate *)getDate : (NSString *)dateString withFormat : (NSString *)dateFormat {
    NSDateFormatter *getDateFormatter = [[NSDateFormatter alloc] init];
    
    [getDateFormatter setDateFormat:dateFormat];
    
    NSDate *date = [getDateFormatter dateFromString: dateString];
    
    return date;
}


/***** YouTube Query Functions ******/

- (void)getYouTubeChannelId {
    //This function grabs the YouTube channel that we need to work with
    
    GTLServiceYouTube *service = self.youTubeService;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForChannelsListWithPart:@"snippet"];
    query.mine = YES;
    query.maxResults = 1;
    
    self.channelIdTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLYouTubeChannelListResponse *channelList,
                                                   NSError *error) {
                                   _channelIdTicket = nil;
                                   if (error == nil) {
                                       if ([[channelList items] count] > 0) {
                                           GTLYouTubeChannel *channel = channelList[0];
                                           self.channelId = channel.identifier;
                                           
                                           // Create the Broadcast now
                                           if ( self.selectedBroadcast == nil ) {
                                               //[self insertLiveYouTubeBroadcast];
                                           } else {
                                               //[self editLiveYouTubeBroadcast:self.selectedBroadcast];
                                           }
                                
                                        }
                                   } else {
                                       NSLog(@"Error: %@", error.description);
                                   }
                                   // Query Finished
                                   
                               }];
}


-(GTLYouTubeLiveBroadcastSnippet *)createLiveBroadcastSnippet {
    // Create an object for the liveBroadcast resource's snippet. Specify values
    // for the snippet's title, scheduled start time, and scheduled end time.
    
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    GTLYouTubeLiveBroadcastSnippet *newBroadcastSnippet = [[GTLYouTubeLiveBroadcastSnippet alloc] init];
    newBroadcastSnippet.title = self.broadcastTitle;
    newBroadcastSnippet.descriptionProperty = self.broadcastDesc;
    newBroadcastSnippet.scheduledStartTime = [GTLDateTime dateTimeWithDate:self.broadcastSchedStart timeZone:timeZone];
    newBroadcastSnippet.scheduledEndTime = [GTLDateTime dateTimeWithDate:self.broadcastSchedEnd timeZone:timeZone];
    
    return newBroadcastSnippet;
}


- (void)changeBroadcastURL : (NSString *)newURL {
    NSUserDefaults *defaults = [AMPreferenceManager standardUserDefaults];
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.broadcastingURL isEqualToString:newURL]) {
        return;
    }
    
    if ([newURL isEqualToString:@""]) {
        newURL = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_BroadcastURL];
    }
    
    group.broadcastingURL= newURL;
    
    //if (group.broadcasting) {
    [[AMMesher sharedAMMesher] updateGroup];
    //}
    [defaults setObject:group.broadcastingURL forKey:Preference_Key_Cluster_BroadcastURL];
    //[defaults synchronize];
    
}


/*** Notifications **/
- (void)popUpResignKeyWindow:(NSNotification *)notification {
    
    //Grab currently selected device from video input list & store
    vidSelectedDeviceIndexPref = (int) self.videoDevicePopupView.indexOfSelectedItem;
    [[AMPreferenceManager standardUserDefaults] setObject:[self.videoDevicePopupView stringValue] forKey:Preference_Key_ffmpeg_Video_In_Device];
    
    //Grab currently selected device from video input list & store
    audSelectedDeviceIndexPref = (int) self.audioDevicePopupView.indexOfSelectedItem;
    [[AMPreferenceManager standardUserDefaults] setObject:[self.audioDevicePopupView stringValue] forKey:Preference_Key_ffmpeg_Audio_In_Device];
}
                                                                               
- (void)googleAccountChanged:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[GTMOAuth2Authentication class]]){
        // User just signed in, let's handle business
        GTMOAuth2Authentication *auth = notification.object;
        
        [self setAuthentication:auth];
        [self initYoutubeService];
        
        [self updateUI];
    } else {
        // User just signed out, let's update YouTube Tab display and clear out
        [self setAuthentication:nil];
        [self updateUI];
    }
}


-(void)groupChanged:(NSNotification *)notification
{
    /**
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    NSLog(@"Group changed! New broadcastURL is: %@", group.broadcastingURL);
    
    NSUserDefaults *defaults = [AMPreferenceManager standardUserDefaults];
    NSLog(@"broadcast url default prefs is: %@", [defaults objectForKey:Preference_Key_Cluster_BroadcastURL]);
     **/
    
}

- (void)checkBoxChanged:(NSNotification *)notification
{
}


- (void)updateAMStandardButtons {
    [self.settingsSaveBtn setActiveStateWithText:@"SAVE"];
    [self.settingsCancelBtn setActiveStateWithText:@"CANCEL"];
    [self.settingsRefreshBtn setActiveStateWithText:@"REFRESH"];
}


- (void)dealloc {
    //To avoid a error when closing
    //[AMN_NOTIFICATION_MANAGER unlistenMessageType:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}


- (void)webViewClose:(WebView *)sender {
    //[super webViewClose:sender];
    
    [sender close];
}

- (void)establishYouTubeVars {
    kKeychainItemName = @"ArtsMesh: YouTube";
    
    scope = @"https://www.googleapis.com/auth/youtube";
    kMyClientID = @"998042950112-nf0sggo2f56tvt8bcord9kn0qe528mqv.apps.googleusercontent.com";
    kMyClientSecret = @"P1QKHOBVo-1RTzpz9sOde4JP";
    
    // Get the saved authentication, if any, from the keychain.
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2WindowController authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:kMyClientID
                                                          clientSecret:kMyClientSecret];
    
    [self setAuthentication:auth];
}

- (void)setAuthentication:(GTMOAuth2Authentication *)auth {
    mAuth = auth;
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = mAuth.canAuthorize;
    return isSignedIn;
}

-(void) updateUI {
    [self.view setNeedsDisplay:true];
}

- (void)initYoutubeService {
    /** This function gets us authenticated with YouTube to make some queries! **/
    
    self.youTubeService = [[GTLServiceYouTube alloc] init];
    //_youTubeService.shouldFetchNextPages = YES;
    _youTubeService.retryEnabled = YES;
    if ([self isSignedIn]) {
        
        _youTubeService.authorizer = mAuth;
        
    }
}

#pragma mark AMPopUpViewDelegeate
-(void)itemSelected:(AMPopUpView*)sender {
}


#pragma mark AMCheckBoxDelegeate
-(void)onChecked:(AMCheckBoxView*)sender {
}

-(void)populateDevicesList {
    
    AMFFmpeg *ffmpegInstance = [[AMFFmpeg alloc] init];
    NSFileHandle *file = [ffmpegInstance populateDevicesList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotDeviceList:) name:NSFileHandleDataAvailableNotification object:file];
    
    [file waitForDataInBackgroundAndNotify];
}

-(void)goLive {
    //[[AMPreferenceManager standardUserDefaults] setObject:self.streamNameTextField.stringValue forKey:Preference_Key_ffmpeg_Cur_Stream];
    
    //Set up ffmpeg configs
    
    NSString *audioCodecFlag = @"libmp3lame";
    if ([audFormatPref isEqualToString:@"AAC"]) {
        audioCodecFlag = @"libvo_aacenc";
    }
    NSString *ffmpegVidOutDimensions = vidOutSizePref;
    
    cfgs.videoFrameRate = vidFrameRatePref;
    cfgs.videoDevice = [NSString stringWithFormat:@"%d", vidSelectedDeviceIndexPref];
    cfgs.audioDevice = [NSString stringWithFormat:@"%d", audSelectedDeviceIndexPref];
    cfgs.videoBitRate = vidBitRatePref;
    cfgs.audioCodec = audioCodecFlag;
    cfgs.audioBitRate = audBitRatePref;
    cfgs.audioSampleRate = audSampleRatePref;
    cfgs.videoOutSize = ffmpegVidOutDimensions;
    cfgs.serverAddr = baseUrlPref;
    cfgs.streamName = streamKeyPref;
    
    [ffmpeg streamToYouTube:cfgs];
    
    
    //[self.eventGoLiveButton setSuccessStateWithText:@"SENDING" andResetText:@"STOP"];
}

- (void)endLive {
    
    [[AMPreferenceManager standardUserDefaults] setObject:nil forKey:Preference_Key_ffmpeg_Cur_Stream];
    
    [ffmpeg stopFFmpeg];
}

// Mouse Events (mainly for buttons)
- (void)mouseDown:(NSEvent *)theEvent {
}
- (void)mouseUp:(NSEvent *)theEvent {

    if (self.settingsCancelBtn.triggerPressed == YES) {
        //SETTINGS CANCEL BUTTON PRESSED
        [self resetSettingsTab];
    } else if (self.settingsSaveBtn.triggerPressed == YES) {
        //SETTINGS SAVE BUTTON PRESSED
        [self saveSettings];
    } else if (self.settingsRefreshBtn.triggerPressed == YES) {
        //SETTINGS REFRESH BUTTON PRESSED
        [self refreshSettings];
    }
    
}



// Settings Tab Functions
-(void)updateSettingsVars {
    vidInSizePref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_In_Size];
    vidInSizeCustomWPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_In_Size_Custom_W];
    vidInSizeCustomHPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_In_Size_Custom_H];
    vidInSizeUseCustomPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Use_Custom_In];
    
    vidOutSizePref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Out_Size];
    vidOutSizeCustomWPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Out_Size_Custom_W];
    vidOutSizeCustomHPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Out_Size_Custom_H];
    vidOutSizeUseCustomPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Use_Custom_Out];
    
    vidFormatPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Format];
    vidFrameRatePref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Frame_Rate];
    vidBitRatePref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_Bit_Rate];
    
    audFormatPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Audio_Format];
    audSampleRatePref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Audio_Sample_Rate];
    audBitRatePref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Audio_Bit_Rate];
    
    baseUrlPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Base_Url];
    streamKeyPref = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Stream_Key];
}

-(void)loadSettingsValues {
    [self populateDevicesList];
    
    videoOutputSizes = [[NSArray alloc] initWithObjects:@"1920x1080",@"1280x720",@"720x480",@"480x360", nil];
    videoOutputSizes = [[NSArray alloc] initWithArray:videoOutputSizes];
    videoFrameRates = [[NSArray alloc] initWithObjects:@"60.00",@"59.94",@"30.00",@"29.97",@"25.00",@"24.00",@"20.00",@"15.00", nil];
    videoFormats = [[NSArray alloc] initWithObjects:@"H.264", @"MPEG2", nil];
    audioFormats = [[NSArray alloc] initWithObjects:@"MP3", @"AAC", nil];
    audioSampleRates = [[NSArray alloc] initWithObjects:@"48000", @"44100", nil];
    audioBitRates = [[NSArray alloc] initWithObjects:@"320", @"256", @"224", @"192", @"160", @"128", nil];
    
    [self.videoOutputSizePopupView removeAllItems];
    [self.videoOutputSizePopupView addItemsWithTitles:videoOutputSizes];
    [self.videoFrameRatePopupView removeAllItems];
    [self.videoFrameRatePopupView addItemsWithTitles:videoFrameRates];
    [self.videoFormatPopupView removeAllItems];
    [self.videoFormatPopupView addItemsWithTitles:videoFormats];
    
    [self.audioFormatPopupView removeAllItems];
    [self.audioFormatPopupView addItemsWithTitles:audioFormats];
    [self.audioSampleRatePopupView removeAllItems];
    [self.audioSampleRatePopupView addItemsWithTitles:audioSampleRates];
    [self.audioBitRatePopupView removeAllItems];
    [self.audioBitRatePopupView addItemsWithTitles:audioBitRates];
    
}
-(void)resetSettingsTab {
    
    //Reset Settings Tab and store default values
    [self loadSettingsValues];
    
    [self.videoDevicePopupView selectItemAtIndex:0];
    [self.videoOutputSizePopupView selectItemAtIndex:0];
    [self.videoFrameRatePopupView selectItemAtIndex:2];
    [self.videoFormatPopupView selectItemAtIndex:0];
    
    [self.audioDevicePopupView selectItemAtIndex:0];
    [self.audioFormatPopupView selectItemAtIndex:1];
    [self.audioSampleRatePopupView selectItemAtIndex:1];
    [self.audioBitRatePopupView selectItemAtIndex:5];
    
    [self.videoBitRateTextField setStringValue:@"4000"];
    [self.baseUrlTextField setStringValue:@"rtmp://a.rtmp.youtube.com/live2"];
    [self.streamKeyTextField setStringValue:@""];
    
    [self saveSettings];
    
    [self.videoOutputSizePopupView setNeedsDisplay:true];
}
-(void)setupSettingsTab {
    videoDevices = [[NSMutableArray alloc] init];
    audioDevices = [[NSMutableArray alloc] init];
    
    // Configure Settings Tab Options
    [self updateSettingsVars];
    [self loadSettingsValues];
    
    if( [vidOutSizePref length] != 0 ) {
        [self.videoOutputSizePopupView selectItemWithTitle:vidOutSizePref];
    } else {
        [self.videoOutputSizePopupView selectItemAtIndex:0]; }
    
    if ( [vidFrameRatePref length] != 0 ) {
        [self.videoFrameRatePopupView selectItemWithTitle:vidFrameRatePref];
    } else {
        [self.videoFrameRatePopupView selectItemAtIndex:2]; }
    
    if ( [vidFormatPref length] != 0 ) {
        [self.videoFormatPopupView selectItemWithTitle:vidFormatPref];
    } else {
        [self.videoFormatPopupView selectItemAtIndex:0]; }
    
    if ( [audFormatPref length] != 0 ) {
        [self.audioFormatPopupView selectItemWithTitle:audFormatPref];
    } else {
        [self.audioFormatPopupView selectItemAtIndex:1]; }
    
    if ( [audSampleRatePref length] != 0 ) {
        [self.audioSampleRatePopupView selectItemWithTitle:audSampleRatePref];
    } else {
        [self.audioSampleRatePopupView selectItemAtIndex:1]; }
    
    if ( [audBitRatePref length] != 0 ) {
        [self.audioBitRatePopupView selectItemWithTitle:audBitRatePref];
    } else {
        [self.audioBitRatePopupView selectItemAtIndex:5]; }
    
    if ( [vidBitRatePref length] != 0 ) {
        [self.videoBitRateTextField setStringValue:vidBitRatePref];
    } else {
        [self.videoBitRateTextField setStringValue:@"4000"]; }
    
    if ([baseUrlPref length] != 0) {
        [self.baseUrlTextField setStringValue:baseUrlPref];
    } else {
        [self.baseUrlTextField setStringValue:@"rtmp://a.rtmp.youtube.com/live2"];
    }
    
    if ([streamKeyPref length] != 0) {
        [self.streamKeyTextField setStringValue:streamKeyPref];
    } else {
        [self.streamKeyTextField setStringValue:@""];
    }
    
    [self.videoOutputSizePopupView setNeedsDisplay:true];
    
}

-(void)saveSettings {
    // Save Video Settings
    
    [[AMPreferenceManager standardUserDefaults] setObject:self.videoOutputSizePopupView.stringValue forKey:Preference_Key_ffmpeg_Video_Out_Size];
    
    [[AMPreferenceManager standardUserDefaults] setObject:self.videoFormatPopupView.stringValue forKey:Preference_Key_ffmpeg_Video_Format];
    [[AMPreferenceManager standardUserDefaults] setObject:self.videoFrameRatePopupView.stringValue forKey:Preference_Key_ffmpeg_Video_Frame_Rate];
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.videoBitRateTextField.stringValue
     forKey:Preference_Key_ffmpeg_Video_Bit_Rate];
    
    //Save Audio Settings
    [[AMPreferenceManager standardUserDefaults] setObject:self.audioFormatPopupView.stringValue forKey:Preference_Key_ffmpeg_Audio_Format];
    [[AMPreferenceManager standardUserDefaults] setObject:self.audioSampleRatePopupView.stringValue forKey:Preference_Key_ffmpeg_Audio_Sample_Rate];
    [[AMPreferenceManager standardUserDefaults] setObject:self.audioBitRatePopupView.stringValue forKey:Preference_Key_ffmpeg_Audio_Bit_Rate];
    
    
    //Save YouTube Details
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.baseUrlTextField.stringValue
     forKey:Preference_Key_ffmpeg_Base_Url];
    
    [[AMPreferenceManager standardUserDefaults] setObject:self.streamKeyTextField.stringValue forKey:Preference_Key_ffmpeg_Stream_Key];
    
    [self updateSettingsVars];
}

- (void) refreshSettings {
    // Refresh Devices dropdowns
    [self populateDevicesList];
}

- (void) gotDeviceList : (NSNotification*)notification
{
    //We have data from ffmpeg devices_list command
    //Need to pull out the relevant devices & populate the dropdowns
    
    NSFileHandle *outputFile = (NSFileHandle *) [notification object];
    NSData *data = [outputFile availableData];
    
    if([data length]) {
        NSMutableArray *tempVidDevices = [[NSMutableArray alloc] init];
        NSMutableArray *tempAudioDevices = [[NSMutableArray alloc] init];
        
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        //NSLog(@"Here: %@", temp);
        //NSLog(@"ffmpeg device data returned: %@", temp);
        
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
                    
                } else if (isAudioDeviceLine == YES && [line rangeOfString:@"devices:"].location == NSNotFound) {
                    //Handle the audio device string
                    NSString *deviceString = [[modifiedString componentsSeparatedByString:@"||"] lastObject];
                    
                    [tempAudioDevices addObject:deviceString];
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
        
            [self.videoDevicePopupView removeAllItems];
            [self.videoDevicePopupView addItemsWithTitles:videoDevicesToInsert];
            
            /**
            vidSelectedDeviceIndexPref = 0;
            [self.videoDevicePopupView selectItemAtIndex:vidSelectedDeviceIndexPref];
            **/
            [self selectDevice:self.videoDevicePopupView :[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Video_In_Device]];
        }
        
        if ([tempAudioDevices count] > 0) {
            NSArray *audioDevicesToInsert = [tempAudioDevices copy];
            
            [self.audioDevicePopupView removeAllItems];
            [self.audioDevicePopupView addItemsWithTitles:audioDevicesToInsert];
            
            [self selectDevice:self.audioDevicePopupView :[[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Key_ffmpeg_Audio_In_Device]];
        }
        
        
        [outputFile waitForDataInBackgroundAndNotify];
    }
}

-(void) selectDevice :(AMPopUpView *)theDropDown :(NSString *)deviceName {
    [theDropDown selectItemAtIndex:0];
    
    [theDropDown selectItemWithTitle:deviceName];
}


@end

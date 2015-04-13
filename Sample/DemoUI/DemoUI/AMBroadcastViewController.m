//
//  AMGPlusViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBroadcastViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMCoreData/AMCoreData.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMMesher/AMMesher.h"
#import "UIFramework/NSView_Constrains.h"

@interface AMBroadcastViewController ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>

@property (strong) GTLServiceYouTube *youTubeService;
@property (strong) GTLServiceTicket *channelIdTicket;
@property (strong) NSString *channelId;
@property (strong) NSString *broadcastTitle;
@property (strong) NSString *broadcastDesc;

@end

@implementation AMBroadcastViewController 
{
    NSString* statusNetEventURLString;
    Boolean isLogin;
    NSString *statusNetURL;
    NSString *myUserName;
    NSString *infoUrl;
    NSString *myBlogUrl;
    NSString *publicBlogUrl;
    Boolean isInfoPage;
    NSString *loginURL;
    NSString *eventURL;
    NSString *broadcastURL;
    
    NSString *kKeychainItemName;
    NSString *scope;
    NSString *kMyClientID;
    NSString *kMyClientSecret;
    
    NSViewController* _detailViewController;
    NSMutableArray *_tabControllers;
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
    [self initYoutubeService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    [self updateUI];
    
    //[AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
    //[AMButtonHandler changeTabTextColor:self.goBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.oAuthSignInBtn toColor:UI_Color_blue];
    
    [self.groupTabView setAutoresizesSubviews:YES];
    [AMButtonHandler changeTabTextColor:self.youtubeBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.settingsBtn toColor:UI_Color_blue];
    
}

-(void)registerTabButtons
{
    super.tabs=self.groupTabView;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.youtubeBtn];
    [self.tabButtons addObject:self.settingsBtn];
    self.showingTabsCount=2;
}

-(void)viewDidLoad
{
    [self loadTabViews];
    
    self.eventStartTimeDropDown.delegate = self;
    self.eventEndTimeDropDown.delegate = self;
    
    self.privateCheck.delegate = self;
    self.privateCheck.title = @"PRIVATE";
    
    [self loadEventTimes];
    
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

- (void)loadOAuthWindow {
    NSApplication *myApp = [NSApplication sharedApplication];
    NSWindow *curWindow = [myApp keyWindow];
    
    GTMOAuth2WindowController *windowController;
    windowController = [[GTMOAuth2WindowController alloc] initWithScope:scope
                                                               clientID:kMyClientID
                                                           clientSecret:kMyClientSecret
                                                       keychainItemName:kKeychainItemName
                                                         resourceBundle:nil];
    
    [windowController signInSheetModalForWindow:curWindow
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)createYouTubeLiveEvent {
    NSLog(@"Create the Live Event, now!");
    
    /** Grab the relevant data from the form **/
    
    // Broadcast Title
    self.broadcastTitle = @"Test Event from ArtsMesh App";
    
    
    // Broadcast Description
    self.broadcastDesc = @"Here's my live event!"
    
    
    // Broadcast Scheduled Start/End Times
    
    NSDate *broadcastSchedStart = [self getDate:@"2016-01-02 19:59:59" withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *broadcastSchedEnd = [self getDate:@"2016-01-02 20:59:59" withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    // Get channelID
    
    [self getYouTubeChannelId];
    
    if ([self.channelId length] > 0) {
        // All set, let's create an event!
        
        // Create an object for the liveBroadcast resource's snippet. Specify values
        // for the snippet's title, scheduled start time, and scheduled end time.
        GTLYouTubeLiveBroadcastSnippet *newBroadcastSnippet = [[GTLYouTubeLiveBroadcastSnippet alloc] init];
        newBroadcastSnippet.title = self.broadcastTitle;
        newBroadcastSnippet.scheduledStartTime = [GTLDateTime dateTimeWithDate:broadcastSchedStart timeZone:nil];
        newBroadcastSnippet.scheduledEndTime = [GTLDateTime dateTimeWithDate:broadcastSchedEnd timeZone:nil];
        
        // Create an object for the liveBroadcast resource's status, and set the
        // broadcast's status to "private".
        GTLYouTubeLiveBroadcastStatus *newBroadcastStatus = [[GTLYouTubeLiveBroadcastStatus alloc] init];
        newBroadcastStatus.privacyStatus = @"private";
        
        // Create the API request that inserts the liveBroadcast resource.
        GTLYouTubeLiveBroadcast *newBroadcast = [[GTLYouTubeLiveBroadcast alloc] init];
        newBroadcast.snippet = newBroadcastSnippet;
        newBroadcast.status = newBroadcastStatus;
        newBroadcast.kind = @"youtube#liveBroadcast";
        
        // Execute the request and return an object that contains information
        // about the new broadcast.
        GTLQueryYouTube *createEventQuery = [GTLQueryYouTube queryForLiveBroadcastsInsertWithObject:newBroadcast part:@"snippet,status"];
        
    }
}

- (NSDate *)getDate : (NSString *)dateString withFormat : (NSString *)dateFormat {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja_JP"]];
    NSDate *date = [dateFormatter dateFromString: dateString];
    
    NSLog(@"The date is %@", date);
    
    return date;
}

- (void)getYouTubeChannelId {
    GTLServiceYouTube *service = self.youTubeService;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForChannelsListWithPart:@"snippet"];
    query.mine = YES;
    query.maxResults = 1;
    
    self.channelIdTicket = [service executeQuery:query
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLYouTubeChannelListResponse *channelList,
                                                   NSError *error) {
                                   if (error == nil) {
                                       if ([[channelList items] count] > 0) {
                                           GTLYouTubeChannel *channel = channelList[0];
                                           self.channelId = channel.identifier;
                                           
                                           NSLog(@"channel id is: %@", self.channelId);
                                       }
                                   } else {
                                       NSLog(@"Error: %@", error.description);
                                   }
                                   NSLog(@"finished..");
                                   
                               }];
}

- (void)loadEventTimes {
    NSArray *times = @[@"12:00am", @"1:00am", @"2:00am", @"3:00am", @"4:00am", @"5:00am", @"6:00am", @"7:00am", @"8:00am", @"9:00am", @"10:00am", @"11:00am", @"12:00pm", @"1:00pm", @"2:00pm", @"3:00pm", @"4:00pm", @"5:00pm", @"6:00pm", @"7:00pm", @"8:00pm", @"9:00pm", @"10:00pm", @"11:00pm"];
    
    [self.eventStartTimeDropDown removeAllItems];
    [self.eventStartTimeDropDown addItemsWithTitles: times];
    
    [self.eventEndTimeDropDown removeAllItems];
    [self.eventEndTimeDropDown addItemsWithTitles: times];
    
    [self.eventStartTimeDropDown selectItemAtIndex:0];
    [self.eventEndTimeDropDown selectItemAtIndex:0];
    
    [self.eventStartTimeDropDown setNeedsDisplay];
    [self.eventEndTimeDropDown setNeedsDisplay];
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

- (IBAction)youtubeBtnClick:(id)sender {
    [self pushDownButton:self.youtubeBtn];
    
    [self.groupTabView selectTabViewItemAtIndex:0];
}
- (IBAction)createEventBtnClick:(id)sender {
    if ( [self isSignedIn] ) {
        [self createYouTubeLiveEvent];
    } else {
        NSLog(@"Oops, sign in to YouTube first!");
    }
}

- (IBAction)settingsBtnClick:(id)sender {
    [self pushDownButton:self.settingsBtn];
    
    [self.groupTabView selectTabViewItemAtIndex:1];
}

- (IBAction)oAuthSignInBtnClick:(id)sender {
    if ([self isSignedIn]) {
        [self signOut];
    } else {
        [self loadOAuthWindow];
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


- (void)dealloc {
    //To avoid a error when closing
    //[AMN_NOTIFICATION_MANAGER unlistenMessageType:self];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)webViewClose:(WebView *)sender {
    
    [super webViewClose:sender];
}


- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        NSLog(@"Google authentication Failed..");
        [self setAuthentication:nil];
    } else {
        // Authentication succeeded
        NSLog(@"Google authentication succeeded!");
        [self setAuthentication:auth];
        [self updateUI];
    }
}

- (void)setAuthentication:(GTMOAuth2Authentication *)auth {
    mAuth = auth;
}

- (void)checkSignedInBtn {
    if ( [self isSignedIn] ) {
        [self.oAuthSignInBtn setTitle:@"SIGN OUT"];
    } else {
        [self.oAuthSignInBtn setTitle:@"SIGN IN"];
    }
    
    [AMButtonHandler changeTabTextColor:self.oAuthSignInBtn toColor:UI_Color_blue];
    [self.view setNeedsDisplay:TRUE];
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = mAuth.canAuthorize;
    return isSignedIn;
}

- (void)signOut {
    if ([mAuth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // Remove the token from Google's servers
        [GTMOAuth2WindowController revokeTokenForGoogleAuthentication:mAuth];
    }
    
    // Remove the stored Google authentication from the keychain, if any
    [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainItemName];
    
    // Discard our retained authentication object
    [self setAuthentication:nil];
    
    [self updateUI];
    
}

-(void) updateUI {
    [self checkSignedInBtn];
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



@end

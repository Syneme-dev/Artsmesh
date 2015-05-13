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
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/NSView_Constrains.h"

@interface AMBroadcastViewController ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>

@property (strong) GTLServiceYouTube *youTubeService;
@property (strong) GTLServiceTicket *channelIdTicket;
@property (strong) GTLServiceTicket *channelCurrentEventsTicket;
@property (strong) GTLServiceTicket *broadcastTicket;
@property (strong) NSString *channelId;
@property (strong) NSString *broadcastTitle;
@property (strong) NSString *broadcastDesc;
@property (strong) NSString *broadcastURL;
@property (strong) NSString *broadcastPrivacy;
@property (strong) NSDate *broadcastSchedStart;
@property (strong) NSDate *broadcastSchedEnd;

@end

@implementation AMBroadcastViewController 
{
    NSString *broadcastFormMode;
    
    NSString *statusNetEventURLString;
    Boolean needsToConfirmEvent;
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
    //Set up Events Manager SubView and View Controller
    eventsManagerVC = [[AMEventsManagerViewController alloc] initWithNibName:@"AMEventsManagerViewController" bundle:nil];
    NSView *view = [eventsManagerVC view];
    [self.eventsManagerView addSubview:view];
    
    //Set up YouTube/oAuth stuff
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
    
    [self setBroadcastFormMode:@"CREATE"];
    needsToConfirmEvent = TRUE;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkBoxChanged:) name:AM_CHECKBOX_CHANGED object:nil];
    
    [self getExistingYouTubeLiveEvents];
    [self updateUI];
    
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
    
    self.privateCheck.delegate = self;
    self.privateCheck.title = @"PRIVATE";
    
    self.schedStartPMCheck.delegate = self;
    self.schedStartPMCheck.title = @"PM";
    
    self.schedEndPMCheck.delegate = self;
    self.schedEndPMCheck.title = @"PM";
    
    NSDate *curDate = [NSDate date];
    //[self loadEventTimes:curDate];
    [self loadEventTime:curDate andDayTextField:self.eventStartDayTextField andMonthTextField:self.eventStartMonthTextField andYearTextField:self.eventStartYearTextField andHourTextField:self.eventStartHourTextField andMinuteTextField:self.eventStartMinuteTextField andPMCHeck:self.schedStartPMCheck];
    [self loadEventTime:curDate andDayTextField:self.eventEndDayTextField andMonthTextField:self.eventEndMonthTextField andYearTextField:self.eventEndYearTextField andHourTextField:self.eventEndHourTextField andMinuteTextField:self.eventEndMinuteTextField andPMCHeck:self.schedEndPMCheck];
    
    
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
    // Create the Live Event now!
    
    
    /** Grab the relevant data from the form **/
    
    // Broadcast Title
    self.broadcastTitle = [self.broadcastTItleField stringValue];
    
    
    // Broadcast Description
    //self.broadcastDesc = @"Here's my live event!";
    self.broadcastDesc = [self.broadcastDescField stringValue];
    
    
    // Broadcast Scheduled Start/End Times
    
    NSString *selectedStartDay = self.eventStartDayTextField.stringValue;
    NSString *selectedStartMonth = self.eventStartMonthTextField.stringValue;
    NSString *selectedStartYear = self.eventStartYearTextField.stringValue;
    NSString *selectedStartHour = self.eventStartHourTextField.stringValue;
    if (self.schedStartPMCheck.checked) {
        NSInteger baseHour = [self.eventStartHourTextField.stringValue integerValue] + 12;
        selectedStartHour = [NSString stringWithFormat:@"%ld", baseHour];
    }
    NSString *selectedStartMinute = self.eventStartMinuteTextField.stringValue;
    NSString *selectedEndDay = self.eventEndDayTextField.stringValue;
    NSString *selectedEndMonth = self.eventEndMonthTextField.stringValue;
    NSString *selectedEndYear = self.eventEndYearTextField.stringValue;
    NSString *selectedEndHour = self.eventEndHourTextField.stringValue;
    if (self.schedEndPMCheck.checked) {
        NSInteger baseHour = [self.eventEndHourTextField.stringValue integerValue] + 12;
        selectedEndHour = [NSString stringWithFormat:@"%ld", baseHour];
    }
    NSString *selectedEndMinute = self.eventEndMinuteTextField.stringValue;
    
    //2016-01-02 19:59:59
    //NSSTring *selectedStartDay = [self.eventStartDayDropDown];
    self.broadcastSchedStart = [self getDate:[NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", selectedStartYear, selectedStartMonth, selectedStartDay, selectedStartHour, selectedStartMinute, @"00"] withFormat:@"yyyy-M-d HH:mm:ss"];
    self.broadcastSchedEnd = [self getDate:[NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", selectedEndYear, selectedEndMonth, selectedEndDay, selectedEndHour, selectedEndMinute, @"00"] withFormat:@"yyyy-M-d HH:mm:ss"];
    
    
    // Get channelID
    
    [self getYouTubeChannelId];
    
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
                                           if ( [broadcastFormMode isEqualToString:@"CREATE"] ) {
                                               [self insertLiveYouTubeBroadcast];
                                           } else if ( [broadcastFormMode isEqualToString:@"EDIT"] ) {
                                               [self editLiveYouTubeBroadcast:self.selectedBroadcast];
                                           }
                                        }
                                   } else {
                                       NSLog(@"Error: %@", error.description);
                                   }
                                   // Query Finished
                                   
                               }];
}


- (void)getExistingYouTubeLiveEvents {
    //Find existing YouTube Live Events, if they exist
    
    GTLServiceYouTube *service = self.youTubeService;
    
    GTLQueryYouTube *query = [GTLQueryYouTube queryForLiveBroadcastsListWithPart:@"snippet"];
    query.mine = YES;
    query.maxResults = 50;
    
    self.channelCurrentEventsTicket = [service executeQuery:query
                                          completionHandler:^(GTLServiceTicket *ticket,
                                                              GTLYouTubeChannelListResponse *liveEventsList,
                                                              NSError *error) {
                                              _channelCurrentEventsTicket = nil;
                                              if (error == nil) {
                                                  if ([[liveEventsList items] count] > 0) {
                                                      // Live Events found!
                                                      [eventsManagerVC setTitle:@"EVENTS"];
                                                      [eventsManagerVC insertEvents:liveEventsList];
                                                  } else {
                                                      // No Live Events found..
                                                      [eventsManagerVC.eventsListScrollView.documentView removeAllRows];
                                                  }
                                              } else {
                                                  //No Live Events found or error
                                                  NSLog(@"Error: %@", error.description);
                                              }
                                              
                                          }];
    
}


- (void)insertLiveYouTubeBroadcast {
    /****** TO-DO *******
     
     * Need reset button after Event created.
     
     ********************/
    
    GTLYouTubeLiveBroadcastSnippet *newBroadcastSnippet = [self createLiveBroadcastSnippet];
    
    // Create an object for the liveBroadcast resource's status, and set the
    // broadcast's status to "private".
    GTLYouTubeLiveBroadcastStatus *newBroadcastStatus = [[GTLYouTubeLiveBroadcastStatus alloc] init];
    if ( self.privateCheck.checked ) { self.broadcastPrivacy = @"private"; } else { self.broadcastPrivacy = @"public"; }
    newBroadcastStatus.privacyStatus = self.broadcastPrivacy;
    
    // Create the API request that inserts the liveBroadcast resource.
    GTLYouTubeLiveBroadcast *newBroadcast = [[GTLYouTubeLiveBroadcast alloc] init];
    newBroadcast.identifier = self.channelId;
    newBroadcast.snippet = newBroadcastSnippet;
    newBroadcast.status = newBroadcastStatus;
    newBroadcast.kind = @"youtube#liveBroadcast";
    
    // Execute the request and return an object that contains information
    // about the new broadcast.
    GTLQueryYouTube *createEventQuery = [GTLQueryYouTube queryForLiveBroadcastsInsertWithObject:newBroadcast part:@"snippet,status"];
    createEventQuery.mine = YES;
    
    GTLServiceYouTube *service = self.youTubeService;
    
    self.broadcastTicket = [service executeQuery:createEventQuery
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLYouTubeLiveBroadcast *liveBroadcast,
                                                   NSError *error) {
                                   // Callback
                                   _broadcastTicket = nil;
                                   if (error == nil) {
                                       // Live broadcast successfully created!
                                
                                       self.broadcastURL = [NSString stringWithFormat:@"%@%@", @"https://www.youtube.com/embed?v=", liveBroadcast.identifier];
                                       [self changeBroadcastURL:self.broadcastURL];
                                       
                                       [self getExistingYouTubeLiveEvents];
                                       
                                       [self.createEventBtn setTitle:@"CREATE"];
                                       
                                   } else {
                                       NSLog(@"Error: %@", error.description);
                                   }
                               }];

}

- (void)editLiveYouTubeBroadcast: (GTLYouTubeLiveBroadcast *)theLiveBraoadcast {
    /****** TO-DO *******
    
    * Currently only 'snippet' is editable
    * Need to also enable update of 'status' for public/private switches
    * Also look into CDN part to see if this is necessary
     
    * Need to reset 'CONFIRM' button after Event successfully edited.
     
    ********************/
    
    // Create a new broadcast snippet
    GTLYouTubeLiveBroadcastSnippet *newBroadcastSnippet = [self createLiveBroadcastSnippet];
    
    theLiveBraoadcast.snippet.title = newBroadcastSnippet.title;
    theLiveBraoadcast.snippet.descriptionProperty = newBroadcastSnippet.descriptionProperty;
    theLiveBraoadcast.snippet.scheduledStartTime = newBroadcastSnippet.scheduledStartTime;
    theLiveBraoadcast.snippet.scheduledEndTime = newBroadcastSnippet.scheduledEndTime;

    // Create a new broadcast status;
    GTLYouTubeLiveBroadcastStatus *newBroadcastStatus = [self createLiveBroadcastStatus];
    newBroadcastStatus.lifeCycleStatus = theLiveBraoadcast.status.lifeCycleStatus;
    newBroadcastStatus.recordingStatus = theLiveBraoadcast.status.recordingStatus;
    theLiveBraoadcast.status = newBroadcastStatus;
    
    GTLQueryYouTube *editEventQuery = [GTLQueryYouTube queryForLiveBroadcastsUpdateWithObject:theLiveBraoadcast part:@"snippet, status"];
    editEventQuery.mine = YES;
    
    GTLServiceYouTube *service = self.youTubeService;
    
    self.broadcastTicket = [service executeQuery:editEventQuery
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLYouTubeLiveBroadcast *liveBroadcast,
                                                   NSError *error) {
                                   //Callback
                                   _broadcastTicket = nil;
                                   if (error == nil) {
                                       //Event successfully edited
                                       NSLog(@"Event successfully edited!");
                                       [self getExistingYouTubeLiveEvents];
            
                                   } else {
                                       NSLog(@"Error: %@", error.description);
                                   }
        
                               }];
    
}


- (void)deleteLiveYouTubeBroadcast: (GTLYouTubeLiveBroadcast *)theLiveBroadcast {
    
    GTLQueryYouTube *deleteEventQuery = [GTLQueryYouTube queryForLiveBroadcastsDeleteWithIdentifier:theLiveBroadcast.identifier];
    deleteEventQuery.mine = YES;

    GTLServiceYouTube *service = self.youTubeService;

    self.broadcastTicket = [service executeQuery:deleteEventQuery
                               completionHandler:^(GTLServiceTicket *ticket,
                                                   GTLYouTubeLiveBroadcast *liveBroadcast,
                                                   NSError *error) {
                                   //Callback
                                   _broadcastTicket = nil;
                                   if (error == nil) {
                                       //Event successfully deleted
                                       [self getExistingYouTubeLiveEvents];
                                       
                                   } else {
                                       NSLog(@"Error: %@", error.description);
                                   }
                               
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

-(GTLYouTubeLiveBroadcastStatus *)createLiveBroadcastStatus {
    GTLYouTubeLiveBroadcastStatus *newBroadcastStatus = [[GTLYouTubeLiveBroadcastStatus alloc] init];
    
    NSString *curEventPrivacy = @"public";
    
    if ( self.privateCheck.checked ) { curEventPrivacy = @"private"; }
    newBroadcastStatus.privacyStatus = curEventPrivacy;
    
    return newBroadcastStatus;
}


- (void)loadEventTime: (NSDate *)theDate andDayTextField: (NSTextField *)theDayTextField andMonthTextField: (NSTextField *)theMonthTextField andYearTextField: (NSTextField *)theYearTextField andHourTextField: (NSTextField *)theHourTextField andMinuteTextField: (NSTextField *)theMinuteTextField andPMCHeck: (AMCheckBoxView *)thePMCheck {
    
    NSInteger *selectDay = 0;
    NSInteger *selectMonth = 0;
    
    // Set up days
    NSMutableArray *days = [NSMutableArray array];
    for (NSInteger d = 1; d <= 31; d++) {
        [days addObject:[NSString stringWithFormat:@"%ld", (long)d]];
    }
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"d"];
    NSDate *curDay = theDate;
    selectDay = (NSInteger *)[[NSString stringWithFormat:@"%@", [dayFormatter stringFromDate:curDay]] integerValue];
    
    // Set up months
    NSMutableArray *months = [NSMutableArray array];
    for (NSInteger m = 1; m <= 12; m++) {
        [months addObject:[NSString stringWithFormat:@"%ld", (long)m]];
    }
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    [monthFormatter setDateFormat:@"M"];
    NSDate *curMonth = theDate;
    selectMonth = (NSInteger *)[[NSString stringWithFormat:@"%@", [monthFormatter stringFromDate:curMonth]] integerValue];
    
    
    // Set up years
    NSMutableArray *years = [NSMutableArray array];
    for (NSInteger y = 0; y<=2; y++) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSDate *curYear = theDate;
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:y];
        NSDate *targetDate = [gregorian dateByAddingComponents:dateComponents toDate:curYear  options:0];
        
        [years addObject:[NSString stringWithFormat:@"%@", [formatter stringFromDate:targetDate]]];
    }
    
    //Add Number Formatters to the Text Fields
    NSNumberFormatter *dayNumberFormatter = [[NSNumberFormatter alloc] init];
    dayNumberFormatter.minimum = [NSNumber numberWithInteger:1];
    dayNumberFormatter.maximum = [NSNumber numberWithInteger:31];
    [theDayTextField setFormatter:dayNumberFormatter];
    
    NSNumberFormatter *monthNumberFormatter = [[NSNumberFormatter alloc] init];
    monthNumberFormatter.minimum = [NSNumber numberWithInteger:1];
    monthNumberFormatter.maximum = [NSNumber numberWithInteger:12];
    [theMonthTextField setFormatter:monthNumberFormatter];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumberFormatter *yearNumberFormatter = [[NSNumberFormatter alloc] init];
    yearNumberFormatter.minimum = [f numberFromString:[years objectAtIndex:0]];
    yearNumberFormatter.maximum = [f numberFromString:[years objectAtIndex:2]];
    NSDate *curHour = theDate;
    
    
    NSCalendar *gregorianHour = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponentsHour = [[NSDateComponents alloc] init];
    [dateComponentsHour setHour:1];
    
    NSDateFormatter *hourDateFormatter = [[NSDateFormatter alloc] init];
    [hourDateFormatter setDateFormat:@"HH"];
    NSDate *targetHour = [gregorianHour dateByAddingComponents:dateComponentsHour toDate:curHour options:0];
    
    
    NSDateComponents *dateComponentsEndHour = [[NSDateComponents alloc] init];
    [dateComponentsEndHour setHour:2];
    NSDate *targetEndHour = [gregorianHour dateByAddingComponents:dateComponentsEndHour toDate:curHour options:0];
    
    
    NSDate *curMinute = theDate;
    NSDateFormatter *minuteDateFormatter = [[NSDateFormatter alloc] init];
    [minuteDateFormatter setDateFormat:@"mm"];
    
    NSNumberFormatter *hourNumberFormatter = [[NSNumberFormatter alloc] init];
    hourNumberFormatter.minimum = [NSNumber numberWithInteger:1];
    hourNumberFormatter.maximum = [NSNumber numberWithInteger:12];
    
    NSNumberFormatter *minuteNumberFormatter = [[NSNumberFormatter alloc] init];
    minuteNumberFormatter.minimum = [NSNumber numberWithInteger:1];
    minuteNumberFormatter.maximum = [NSNumber numberWithInteger:59];
    
    
    
    theDayTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)selectDay];
    
    theMonthTextField.stringValue = [NSString stringWithFormat:@"%ld", (long)selectMonth];
    
    theYearTextField.stringValue = [years objectAtIndex:0];
    
    NSDate *finalHour = [[NSDate alloc] init];
    
    if ([broadcastFormMode isEqualToString:@"CREATE"]) {
        if ([theHourTextField isEqualTo:self.eventStartHourTextField]) {
            finalHour = targetHour;
        } else if ([theHourTextField isEqualTo:self.eventEndHourTextField]) {
            finalHour = targetEndHour;
        }
    } else {
        finalHour = curHour;
    }
    
    if ( [[hourDateFormatter stringFromDate:finalHour] intValue] <= 12 ) {
        theHourTextField.stringValue = [hourDateFormatter stringFromDate:finalHour];
    } else {
        int twelveHour = [[hourDateFormatter stringFromDate:finalHour] intValue] - 12;
        theHourTextField.stringValue = [NSString stringWithFormat:@"%i", twelveHour];
        [thePMCheck setChecked:YES];
    }
    
    theMinuteTextField.stringValue = [minuteDateFormatter stringFromDate:curMinute];
    
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
    if (needsToConfirmEvent == FALSE) {
        if ( [self isSignedIn] ) {
            if ( [broadcastFormMode isEqualToString:@"CREATE"] ) {
                // Create new Live YouTube Broadcast
                [self createYouTubeLiveEvent];
            } else if ( [broadcastFormMode isEqualToString:@"EDIT"] ) {
                // Edit existing Live YouTube Broadcast
                [self createYouTubeLiveEvent];
            } else if ([broadcastFormMode isEqualToString:@"DELETE"]) {
                // Delete existing Live YouTube Broadcast
                [self deleteLiveYouTubeBroadcast:self.selectedBroadcast];
            }
        } else {
            //Notify user to sign in to Google to create a Live Event
        }
        
        needsToConfirmEvent = TRUE;
    } else {
        [self.createEventBtn setTitle:@"CONFIRM"];
        
        needsToConfirmEvent = FALSE;
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


/*** Notifications **/
- (void)controlTextDidChange:(NSNotification *)notification {
    if ([notification object] == self.eventStartDayTextField && [self.eventStartDayTextField.stringValue length] > 0 ) {
        self.eventEndDayTextField.stringValue = self.eventStartDayTextField.stringValue;
    }
    else if ([notification object] == self.eventStartMonthTextField && [self.eventStartMonthTextField.stringValue length] > 0 ) {
        self.eventEndMonthTextField.stringValue = self.eventStartMonthTextField.stringValue;
    }
    else if ([notification object] == self.eventStartYearTextField && [self.eventStartYearTextField.stringValue length] > 0 ) {
        self.eventEndYearTextField.stringValue = self.eventStartYearTextField.stringValue;
    }
    else if ([notification object] == self.eventStartHourTextField && [self.eventStartHourTextField.stringValue length] > 0 ) {
        self.eventEndHourTextField.stringValue = self.eventStartHourTextField.stringValue;
    }
    else if ([notification object] == self.eventStartMinuteTextField && [self.eventStartMinuteTextField.stringValue length] > 0 ) {
        self.eventEndMinuteTextField.stringValue = self.eventStartMinuteTextField.stringValue;
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
    //AMCheckBoxView *changedCheckboxView = notification.object;
    
    if ([notification.object isKindOfClass:[AMLiveEventCheckBoxView class]]) {
        AMLiveEventCheckBoxView *theCheckedBoxView = notification.object;
        
        if (theCheckedBoxView.checked && ([theCheckedBoxView.title isEqualToString:@"EDIT"] || [theCheckedBoxView.title isEqualToString:@"DELETE"])) {
            //Event EDIT checkbox has been checked
            self.selectedBroadcast = theCheckedBoxView.liveBroadcast;
            [self setBroadcastFormMode:theCheckedBoxView.title];
            [self loadBrodcastIntoEventForm:theCheckedBoxView.liveBroadcast];
            
        } else if (!theCheckedBoxView.checked) {
            self.selectedBroadcast = nil;
            [self removeBroadcastFromEventForm];
            [self setBroadcastFormMode:@"CREATE"];
        }
        
    }
}

- (void)setBroadcastFormMode:(NSString *)formMode {
    broadcastFormMode = formMode;
    [self.createEventBtn setTitle:formMode];
}

- (void)loadBrodcastIntoEventForm:(GTLYouTubeLiveBroadcast *)theBroadcast {
    // This function loads in a given YouTube Live Event into the Event Form.
    
    [self.broadcastTItleField setStringValue:theBroadcast.snippet.title];
    [self.broadcastDescField setStringValue:theBroadcast.snippet.descriptionProperty];
    
    [self loadEventTime:theBroadcast.snippet.scheduledStartTime.date andDayTextField:self.eventStartDayTextField andMonthTextField:self.eventStartMonthTextField andYearTextField:self.eventStartYearTextField andHourTextField:self.eventStartHourTextField andMinuteTextField:self.eventStartMinuteTextField andPMCHeck:self.schedStartPMCheck];
    [self loadEventTime:theBroadcast.snippet.scheduledEndTime.date andDayTextField:self.eventEndDayTextField andMonthTextField:self.eventEndMonthTextField andYearTextField:self.eventEndYearTextField andHourTextField:self.eventEndHourTextField andMinuteTextField:self.eventEndMinuteTextField andPMCHeck:self.schedEndPMCheck];
    
}

- (void)removeBroadcastFromEventForm {
    [self.broadcastTItleField setStringValue:@"YOUR BROADCAST TITLE"];
    [self.broadcastDescField setStringValue:@"YOUR BROADCAST DESCRIPTION"];
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
        [self setAuthentication:nil];
    } else {
        // Authentication succeeded
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
    [self.schedStartPMCheck setFontSize:10.0f];
    [self.schedEndPMCheck setFontSize:10.0f];
    [self.privateCheck setFontSize:10.0f];
    
    // Test pull current live events list
    if ([self isSignedIn]) { [self getExistingYouTubeLiveEvents]; }
    
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

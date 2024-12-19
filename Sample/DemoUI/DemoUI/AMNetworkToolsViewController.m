//  AMNetworkToolsViewController.m
//  DemoUI
//  Created by lattesir on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMNetworkToolsViewController.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMCoreData/AMCoreData.h"
#import "AMNetworkToolsCommand.h"
#import "AMCommonTools/AMCommonTools.h"
#import "AMLogger/AMLogReader.h"
#import "AMLogger/AMLogger.h"

#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"

#import "AMIPerfTabVC.h"
#import "AMPingTabVC.h"
#import "AMTraceRouteTabVC.h"
#import "AMNetworkingToolVC.h"
#import "AMFFmpeg.h"


NSString * const AMJacktripLogNotification      = @"AMJacktripLogNotification";

@interface AMNetworkToolsViewController ()<NSComboBoxDelegate, AMPopUpViewDelegeate,
                                            AMRatioButtonDelegeate>
{
    NSArray *_users;
    AMNetworkToolsCommand *     _pingCommand;
    AMNetworkToolsCommand *     _tracerouteCommand;
    
    AMLogReader*                _logReader;
    NSTimer*                    _readTimer;
    NSTimer*                    _testTimer;
    
    NSDictionary*               _titleMapLogFile;
    NSString*                   _searchWord;
    Boolean                     _needSearch;
    Boolean                     _ipv6Checked;
    
    NSMutableArray*             _jackTripFiles;
}

@property (weak) IBOutlet AMCheckBoxView    *fullLogCheck;
@property (weak) IBOutlet AMRatioButtonView *ratioOSCServer;
@property (weak) IBOutlet AMRatioButtonView *ratioOSCClient;
@property (weak) IBOutlet AMRatioButtonView *ratioJackAudio;
@property (weak) IBOutlet AMRatioButtonView *ratioAMServer;
@property (weak) IBOutlet AMRatioButtonView *ratioArtsmesh;
@property (weak) IBOutlet AMRatioButtonView *ratioVideo;

@property (weak) IBOutlet AMFoundryFontView *searchField;


@property (nonatomic) NSMutableArray *viewControllers;
@property (nonatomic) NSInteger         index;


@end

@implementation AMNetworkToolsViewController

- (void) onChecked:(AMRatioButtonView *)sender
{
    [self UncheckAllRatioButton];
    [sender setChecked:YES];
    
    NSString* logFile = [_titleMapLogFile objectForKey:sender.title];
    if(logFile == nil){
        NSLog(@"when you push[%@], no %@ file in the Dictionary",
                    sender.title,  logFile);
    }
    
    _logReader = [[AMSystemLogReader alloc] initWithFileName:logFile];
    [self showLog];
}

- (void) UncheckAllRatioButton
{
    [self.ratioOSCServer    setChecked:NO];
    [self.ratioOSCClient    setChecked:NO];
    [self.ratioJackAudio    setChecked:NO];
    [self.ratioAMServer     setChecked:NO];
    [self.ratioArtsmesh     setChecked:NO];
    [self.ratioVideo        setChecked:NO];
}

- (void) enableAllControls:(BOOL)enable
{
    [self.ratioOSCServer    setEnabled:enable];
    [self.ratioOSCClient    setEnabled:enable];
    [self.ratioJackAudio    setEnabled:enable];
    [self.ratioAMServer     setEnabled:enable];
    [self.ratioArtsmesh     setEnabled:enable];
    [self.ratioVideo        setEnabled:enable];
    [self.fullLogCheck      setEnabled:enable];
    [self.searchField       setEnabled:enable];
    [self.logFilePopUp      setEnabled:enable];
    
    if(!enable)
        [self UncheckAllRatioButton];
}

-(void) itemSelected:(AMPopUpView*)sender{
    NSString* fileName = [self.logFilePopUp stringValue];
    _logReader = [[AMSystemLogReader alloc] initWithFileName:fileName];
    [self showLog];
}
- (IBAction)searchKeyWork:(id)sender {
    _searchWord = self.searchField.stringValue;
    if([_searchWord length] == 0)
    {
        //如果已经搜索了，则需要重置内容，显示全部内容
        if(_needSearch){
            [_logReader resetLog];
            [self showLog];
        }
        _needSearch = NO;
        return;
    }
    
    _needSearch  = YES;
    
    [_logReader resetLog];
    [self showLog];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
    }
    return self;
}

-(void) refreshLogFilePopUp
{
    [self.logFilePopUp removeAllItems];
    
    _jackTripFiles = [[NSMutableArray alloc] initWithCapacity:10];
    NSMutableArray* logs = [[NSMutableArray alloc] initWithCapacity:10];
    NSError* err = nil;
    NSArray *filesArray = [[NSFileManager defaultManager]
                                    contentsOfDirectoryAtPath:AMLogDirectory()
                                                        error:&err];
    if(err == nil){
        // sort by creation date
        NSMutableArray* filesAndProperties = [NSMutableArray arrayWithCapacity:[filesArray count]];
        for(NSString* file in filesArray){
            NSString* filePath = [AMLogDirectory() stringByAppendingPathComponent:file];
            NSDictionary* properties = [[NSFileManager defaultManager]
                                            attributesOfItemAtPath:filePath
                                            error:&err];
            NSDate* modDate = [properties objectForKey:NSFileModificationDate];
            if(err == nil)
            {
                [filesAndProperties addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                                   file, @"path",
                                                   modDate, @"lastModDate",
                                                   nil]];
            }
        }
            
        // sort using a block. order inverted as we want latest date first
        NSArray* sortedFiles = [filesAndProperties sortedArrayUsingComparator:
                                ^(id path1, id path2){
            // compare
            NSComparisonResult comp = [[path1 objectForKey:@"lastModDate"] compare:
                                                 [path2 objectForKey:@"lastModDate"]];
            // invert ordering
            if (comp == NSOrderedDescending) {
                comp = NSOrderedAscending;
            }
            else if(comp == NSOrderedAscending){
                      comp = NSOrderedDescending;
            }
                  return comp;
        }];
            
        for (NSDictionary* dic in sortedFiles){
            [logs addObject:[dic objectForKey:@"path"]];
        }
        
        for (NSString* logFile in logs) {
            NSRange searchResult = [logFile rangeOfString:kAMJackTripFile];
            if(searchResult.location != NSNotFound){
                [_jackTripFiles addObject:logFile];
            }
        }
        [self.logFileCombo addItemsWithObjectValues:logs];
    }
    else
        NSLog(@"Error in reading files: %@", [err localizedDescription]);
  
    [self.logFilePopUp addItemsWithTitles:_jackTripFiles];
}


- (void)awakeFromNib
{
    [super awakeFromNib];
 //   _ipv6Checked = FALSE;
    [AMButtonHandler changeTabTextColor:self.pingButton         toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.tracerouteButton   toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.iperfButton        toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.logButton          toColor:UI_Color_blue];
    //[AMButtonHandler changeTabTextColor:self.jacktripButton     toColor:UI_Color_blue];
  
    [self refreshLogFilePopUp];
    
    self.logFileCombo.delegate      = self;
    self.logFilePopUp.delegate      = self;
    self.searchField.delegate       = self;
    self.ratioOSCClient.delegate    = self;
    self.ratioOSCServer.delegate    = self;
    self.ratioJackAudio.delegate    = self;
    self.ratioAMServer.delegate     = self;
    self.ratioArtsmesh.delegate     = self;
    self.ratioVideo.delegate        = self;
    
    [self.logButton performClick:_jackTripFiles];
    
    self.fullLogCheck.title = @"FULL LOG";
   
    
    self.ratioOSCServer.title    = kAMOSCServerTitle;
    self.ratioOSCClient.title    = kAMOSCClientTitle;
    self.ratioJackAudio.title    = kAMJackAudioTitle;
    self.ratioAMServer.title     = kAMAMServerTitle;
    self.ratioArtsmesh.title     = kAMArtsmeshTitle;
    self.ratioVideo.title        = kVideoTitle;
    
    
    _titleMapLogFile             = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAMOSCServerFile,       kAMOSCServerTitle,
                                    kAMOSCClientFile,       kAMOSCClientTitle,
                                    kAMJackAudioFile,       kAMJackAudioTitle,
                                    kAMAMServerFile,        kAMAMServerTitle,
                                    kAMArtsmeshFile,        kAMArtsmeshTitle,
                                    kVideoFile,             kVideoTitle,
                                    nil];

    [self onChecked:self.ratioArtsmesh];
    
    [self addViewController:[AMPingTabVC class]
                    fromNib:@"AMPingTabVC"
                     bundle:nil];
    
    [self addViewController:[AMTraceRouteTabVC class]
                    fromNib:@"AMTraceRouteTabVC"
                     bundle:nil];
    
    [self addViewController:[AMIPerfTabVC class]
                    fromNib:@"AMIPerfTabVC"
                     bundle:nil];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(ipv6CheckedT:)
               name:AMIPV6CHECKTRUENotification
             object:nil];
    [nc addObserver:self
           selector:@selector(ipv6CheckedF:)
               name:AMIPV6CHECKFALSENotification
             object:nil];
    [nc addObserver:self
           selector:@selector(refreshVideoLog:)
               name:AMVIDEOP2PNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(refreshVideoLog:)
               name:AMVIDEOYouTubeStreamNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(showJacktripState:)
               name:AMJacktripLogNotification
             object:nil];

    [self registerTabButtons];
    
    [self.logTabVerticalScrollView.documentView setBackgroundColor:[AMTheme sharedInstance].colorBackground];

}

-(void)registerTabButtons
{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.pingButton];
    [self.tabButtons addObject:self.tracerouteButton];
    [self.tabButtons addObject:self.iperfButton];
    [self.tabButtons addObject:self.logButton];
    //[self.tabButtons addObject:self.jacktripButton];
    self.showingTabsCount=5;
}

- (void)ipv6CheckedT:(NSNotification *)notification
{
    _ipv6Checked = TRUE;
}

- (void)ipv6CheckedF:(NSNotification *)notification
{
    _ipv6Checked = FALSE;
}

- (void)refreshVideoLog:(NSNotification *)notification
{
    NSLog(@"refresh network view..");
    [self onChecked:self.ratioVideo];
    self.logTextView.needsDisplay = YES;
}

- (void) showJacktripState:(NSNotification *)notification
{
    [self refreshLogFilePopUp];
    
   
    NSString* fileName = [notification object];
    _logReader = [[AMSystemLogReader alloc] initWithFileName:fileName];
    [_logReader sendStateNotification];
}


- (IBAction)ping:(id)sender
{
    [self pushDownButton:self.pingButton];
    [self.tabView selectTabViewItemAtIndex:0];
    
    AMPingTabVC* tabVC = [_viewControllers objectAtIndex:0];
    [tabVC ipv6Checked:_ipv6Checked];
}

- (IBAction)traceroute:(id)sender
{
    [self pushDownButton:self.tracerouteButton];
    [self.tabView selectTabViewItemAtIndex:1];
    
    AMTraceRouteTabVC* tabVC = [_viewControllers objectAtIndex:1];
    [tabVC ipv6Checked:_ipv6Checked];
}

- (IBAction)iperf:(id)sender
{
    [self pushDownButton:self.iperfButton];
    [self.tabView selectTabViewItemAtIndex:2];
    
    AMIPerfTabVC* tabVC = [_viewControllers objectAtIndex:2];
    [tabVC ipv6Checked:_ipv6Checked];
}

- (IBAction)log:(id)sender {
    [self enableAllControls:TRUE];
    [self pushDownButton:self.logButton];
    [self.tabView selectTabViewItemWithIdentifier:@"logTab"];
}

//-------------Log---------------//
- (void) writeToLogView:(NSString*) logItem
{
    if(_needSearch && [_searchWord length] > 0)
    {
        if([logItem rangeOfString:_searchWord].location == NSNotFound)
            return;
    }
    
    NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline-Medium" size:11];
    NSDictionary* attr = @{NSForegroundColorAttributeName:  UI_Color_b7b7b7 ,
                           NSFontAttributeName:textViewFont};
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:logItem
                                                                     attributes:attr];
   
    [self.logTextView.textStorage appendAttributedString:attrString];
    self.logTextView.needsDisplay = YES;
    
}


-(void) handleNextLogTimer:(NSTimer*) timer
{
    NSString*   logItem = nil;
    int         _appendStringCount = 0;
    if(_appendStringCount > 10000 && [[self.logTextView textStorage] length] > 1024*1024*5){//when textView larger than 5MB
        NSArray*  logArray = [_logReader lastLogItmes];
        if(logArray){
            for (NSString* logItem in logArray) {
                 NSString* logItemEnter = [NSString stringWithFormat:@"%@", logItem];
                [self writeToLogView:logItemEnter];
            }
        }
        _appendStringCount = 0;
    }
        
    while( (logItem = [_logReader nextLogItem]) != nil) {
            NSString* logItemEnter = [NSString stringWithFormat:@"%@", logItem];
            [self writeToLogView:logItemEnter];
            _appendStringCount++;
    }
}


-(void) showLogFromTail
{
    NSArray*  logArray = [_logReader lastLogItmes];
    if([logArray count] > 0)
    {
        for (NSString* logItem in logArray) {
            NSString* logItemEnter = [NSString stringWithFormat:@"%@\n", logItem];
            [self writeToLogView:logItemEnter];
        }
        
        _readTimer =[NSTimer scheduledTimerWithTimeInterval:2
                                                     target:self
                                                   selector:@selector(handleNextLogTimer:)
                                                   userInfo:nil
                                                    repeats:YES];
    }

}

-(void) showFullLog
{
    [self.logTextView setString:@""];
    NSString* logItem = nil;
    while((logItem = [_logReader nextLogItem]) != nil){
        NSString* logItemEnter = [NSString stringWithFormat:@"%@", logItem];
        [self writeToLogView:logItemEnter];
    }
    
}

-(void) showLog
{
    [_readTimer invalidate];
    [self.logTextView setString:@""];
    
    if([self.fullLogCheck checked]){
        [self showFullLog];
    }
    else{
        [self showLogFromTail];
    }
    [self.logTextView scrollToEndOfDocument:self];
    
    [_logReader sendStateNotification];
}

- (void)addViewController:(Class)aViewControllerClass
                  fromNib:(NSString *)nibName
                   bundle:(NSBundle *)bundle
{
    NSViewController *vc = [[aViewControllerClass alloc] initWithNibName:nibName bundle:bundle];
    NSView* contentView = vc.view;
    NSView *superView = [self.tabView tabViewItemAtIndex:self.viewControllers.count].view;
    [superView addSubview:contentView];
    [self.viewControllers addObject:vc];
    
    [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
}



- (NSMutableArray *)viewControllers
{
    if (!_viewControllers) {
        _viewControllers = [NSMutableArray array];
    }
    return _viewControllers;
}

@end

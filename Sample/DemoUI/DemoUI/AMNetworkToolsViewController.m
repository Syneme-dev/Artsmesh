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

NSString * const kAMOSCServerTitle  = @"OSC SERVER";
NSString * const kAMOSCClientTitle  = @"OSC CLIENT";
NSString * const kAMJackAudioTitle  = @"JACK AUDIO";
NSString * const kAMAMServerTitle   = @"AMSERVER";
NSString * const kAMArtsmeshTitle   = @"ARTSMESH";


NSString * const kAMOSCServerFile   = @"OSC_Server.log";
NSString * const kAMOSCClientFile   = @"OSC_Client.log";
NSString * const kAMJackAudioFile   = @"Jack_Audio.log";
NSString * const kAMAMServerFile    = @"AMServer.log";
NSString * const kAMArtsmeshFile    = @"Artsmesh.log";
NSString * const kAMJackTripFile    = @"Jacktrip";

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
}

@property (weak) IBOutlet AMCheckBoxView    *fullLogCheck;
@property (weak) IBOutlet AMRatioButtonView *ratioOSCServer;
@property (weak) IBOutlet AMRatioButtonView *ratioOSCClient;
@property (weak) IBOutlet AMRatioButtonView *ratioJackAudio;
@property (weak) IBOutlet AMRatioButtonView *ratioAMServer;
@property (weak) IBOutlet AMRatioButtonView *ratioArtsmesh;
@property (weak) IBOutlet AMFoundryFontView *searchField;

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

- (void)awakeFromNib
{
    [super awakeFromNib];
    [AMButtonHandler changeTabTextColor:self.pingButton         toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.tracerouteButton   toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.iperfButton        toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.logButton          toColor:UI_Color_blue];
    
    
    _pingCommand = [[AMNetworkToolsCommand alloc] init];
    _pingCommand.contentView = self.pingContentView;
    
    _tracerouteCommand = [[AMNetworkToolsCommand alloc] init];
    _tracerouteCommand.contentView = self.tracerouteContentView;
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(userGroupsChanged:)
        name: AM_LIVE_GROUP_CHANDED
        object:nil];
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if (mySelf.isOnline) {
        [self userGroupsChanged:nil];
    }
    [self ping:self.pingButton];
    
    NSArray *logs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:AMLogDirectory()
                                                                        error:nil];
    
    logs = [logs pathsMatchingExtensions:@[ @"log" ]];
    [self.logFileCombo addItemsWithObjectValues:logs];
    self.logFileCombo.delegate = self;
    
    NSMutableArray* jackTripFiles = [[NSMutableArray alloc] initWithCapacity:10];
   for (NSString* logFile in logs) {
        NSRange searchResult = [logFile rangeOfString:kAMJackTripFile];
        if(searchResult.location != NSNotFound){
            [jackTripFiles addObject:logFile];
        }
    }
    
 /*    NSArray* jackTripFiles = [NSArray arrayWithArray:logs];*/
    [self.logFilePopUp addItemsWithTitles:jackTripFiles];
    [self.logButton performClick:jackTripFiles];
    
    
    self.fullLogCheck.title = @"FULL LOG";
    
    self.logFilePopUp.delegate  = self;
    self.searchField.delegate   = self;
    
    self.ratioOSCClient.delegate    = self;
    self.ratioOSCServer.delegate    = self;
    self.ratioJackAudio.delegate    = self;
    self.ratioAMServer.delegate     = self;
    self.ratioArtsmesh.delegate     = self;
    
    self.ratioOSCServer.title    = kAMOSCServerTitle;
    self.ratioOSCClient.title    = kAMOSCClientTitle;
    self.ratioJackAudio.title    = kAMJackAudioTitle;
    self.ratioAMServer.title     = kAMAMServerTitle;
    self.ratioArtsmesh.title     = kAMArtsmeshTitle;
    
    _titleMapLogFile             = [NSDictionary dictionaryWithObjectsAndKeys:
                                    kAMOSCServerFile,       kAMOSCServerTitle,
                                    kAMOSCClientFile,       kAMOSCClientTitle,
                                    kAMJackAudioFile,       kAMJackAudioTitle,
                                    kAMAMServerFile,        kAMAMServerTitle,
                                    kAMArtsmeshFile,        kAMArtsmeshTitle,
                                    nil];
    
   /* [self.logTextView setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.logTextView.font.pointSize]];*/

    [self onChecked:self.ratioArtsmesh];
}

-(void)registerTabButtons
{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.pingButton];
    [self.tabButtons addObject:self.tracerouteButton];
    [self.tabButtons addObject:self.iperfButton];
    [self.tabButtons addObject:self.logButton];
    self.showingTabsCount=4;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

-(void)userGroupsChanged:(NSNotification*)notification
{
    AMLiveGroup* mergedGroup = [[AMCoreData shareInstance] mergedGroup];
    _users = [mergedGroup usersIncludeSubGroup];
    
    [self.pingTableView reloadData];
    [self.tracerouteTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_users count];
}

- (id)tableView:(NSTableView *)tableView
viewForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    
    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                          owner:nil];
    AMLiveUser* user = _users[row];
    [result.textField setStringValue:user.nickName];
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    if (tableView.selectedRow == -1)
        return;
    AMLiveUser* user = _users[tableView.selectedRow];
    NSString* ip = user.publicIp;
    if (tableView == self.pingTableView) {
        NSString *command;
        
        if ([AMCommonTools isValidIpv4:ip]){
            command = [NSString stringWithFormat:@"ping -c 5 %@", ip];
        }else{
            command = [NSString stringWithFormat:@"ping6 -c 5 %@", ip];
        }
        
        [_pingCommand stop];
        _pingCommand.command = command;
        [_pingCommand run];
    } else if (tableView == self.tracerouteTableView) {
        
        NSString *command;
        
        if ([AMCommonTools isValidIpv4:ip]){
            command = [NSString stringWithFormat:@"/usr/sbin/traceroute %@", ip];
        }else{
            command = [NSString stringWithFormat:@"/usr/sbin/traceroute6 %@", ip];
        }

        [_tracerouteCommand stop];
        _tracerouteCommand.command = command;
        [_tracerouteCommand run];
    }
}

- (IBAction)ping:(id)sender
{
    [self pushDownButton:self.pingButton];
    [self.tabView selectTabViewItemWithIdentifier:@"pingTab"];
}

- (IBAction)traceroute:(id)sender
{
    [self pushDownButton:self.tracerouteButton];
    [self.tabView selectTabViewItemWithIdentifier:@"tracerouteTab"];
}

- (IBAction)iperf:(id)sender
{
    [self pushDownButton:self.iperfButton];
    [self.tabView selectTabViewItemWithIdentifier:@"iperfTab"];
}

- (IBAction)log:(id)sender {
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
    
    
 //  NSDictionary *attr = @{ NSForegroundColorAttributeName : UI_Color_b7b7b7 };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:logItem
                                                                     attributes:attr];
   
    [self.logTextView.textStorage appendAttributedString:attrString];
    self.logTextView.needsDisplay = YES;
    
  /*   [[[self.logTextView textStorage] mutableString] appendString: logItem];
    self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];*/
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
                /*
                [[[self.logTextView textStorage] mutableString] appendString: logItemEnter];
                self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
                 */
            }
        }
        _appendStringCount = 0;
    }
        
    while( (logItem = [_logReader nextLogItem]) != nil) {
            NSString* logItemEnter = [NSString stringWithFormat:@"%@", logItem];
            [self writeToLogView:logItemEnter];
           /* [[[self.logTextView textStorage] mutableString] appendString: logItemEnter];
            self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];*/
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
//            [[[self.logTextView textStorage] mutableString] appendString: logItemEnter];
//            self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
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
        /*
        [[[self.logTextView textStorage] mutableString] appendString:logItemEnter];
        self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];*/
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
}



@end

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
#import "UIFramework/AMCheckBoxView.h"


@interface AMNetworkToolsViewController ()<NSComboBoxDelegate, AMPopUpViewDelegeate>
{
    NSArray *_users;
    AMNetworkToolsCommand *_pingCommand;
    AMNetworkToolsCommand *_tracerouteCommand;
    
    AMLogReader*            _logReader;
    NSTimer*                _readTimer;
    NSTimer*                _testTimer;
}
@property (weak) IBOutlet NSButton *errorLogButton;
@property (weak) IBOutlet NSButton *warningLogButton;
@property (weak) IBOutlet NSButton *infoLogButton;
@property (weak) IBOutlet AMCheckBoxView *fullLogCheck;

@end

@implementation AMNetworkToolsViewController

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
    [AMButtonHandler changeTabTextColor:self.pingButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.tracerouteButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.iperfButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.logButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.errorLogButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.warningLogButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.infoLogButton toColor:UI_Color_blue];
    
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
    
    [self.logFilePopUp addItemsWithTitles:logs];
    
    
    [self.logButton performClick:self];
    [self.infoLogButton performClick:self];
    
    self.fullLogCheck.title = @"FULL LOG";
    
    self.logFilePopUp.delegate  = self;
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

-(void) handleNextLogTimer:(NSTimer*) timer
{
    NSString*   logItem = nil;
    int         _appendStringCount = 0;
    if(_appendStringCount > 10000 && [[self.logTextView textStorage] length] > 1024*1024*5){//when textView larger than 5MB
        NSArray*  logArray = [_logReader lastLogItmes];
        if(logArray){
            for (NSString* logItem in logArray) {
                 NSString* logItemEnter = [NSString stringWithFormat:@"%@", logItem];
                [[[self.logTextView textStorage] mutableString] appendString: logItemEnter];
                self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
            }
        }
        _appendStringCount = 0;
    }
        
    while( (logItem = [_logReader nextLogItem]) != nil) {
            NSString* logItemEnter = [NSString stringWithFormat:@"%@", logItem];
            [[[self.logTextView textStorage] mutableString] appendString: logItemEnter];
            self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
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
            [[[self.logTextView textStorage] mutableString] appendString: logItemEnter];
            self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
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
        [[[self.logTextView textStorage] mutableString] appendString:logItemEnter];
        self.logTextView.textStorage.foregroundColor = [NSColor lightGrayColor];
    }
    
}

-(void) clearAllButtonColor
{
    [AMButtonHandler changeTabTextColor:self.errorLogButton   toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.warningLogButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.infoLogButton    toColor:UI_Color_blue];
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

- (IBAction)showErrorLog:(id)sender
{
    _logReader = [AMLogReader errorLogReader];
    [self showLog];
    [self clearAllButtonColor];
    [AMButtonHandler changeTabTextColor:self.errorLogButton     toColor:UI_Color_b7b7b7];
}

- (IBAction)showWarningLog:(id)sender {
    _logReader = [AMLogReader warningLogReader];
    [self showLog];
    [self clearAllButtonColor];
    [AMButtonHandler changeTabTextColor:self.warningLogButton   toColor:UI_Color_b7b7b7];
}

- (IBAction)showInfoLog:(id)sender
{
    _logReader = [AMLogReader infoLogReader];
    [self showLog];
    [self clearAllButtonColor];
    [AMButtonHandler changeTabTextColor:self.infoLogButton      toColor:UI_Color_b7b7b7];
}

- (IBAction)logFileComboChanged:(id)sender
{
    NSString* fileName = [self.logFileCombo objectValueOfSelectedItem];
    _logReader = [[AMSystemLogReader alloc] initWithFileName:fileName];
    [self showLog];
}



-(void) itemSelected:(AMPopUpView*)sender{
//    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//    NSString* myPrivateIP = [self.ipPopUpView stringValue];
//    [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
    
    NSString* fileName = [self.logFilePopUp stringValue];
    _logReader = [[AMSystemLogReader alloc] initWithFileName:fileName];
    [self showLog];
    
//    NSString* fileName = [self.logFileCombo objectValueOfSelectedItem];
//    _logReader = [[AMSystemLogReader alloc] initWithFileName:fileName];
//    [self showLog];
}


@end

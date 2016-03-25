//
//  AMIPerfTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMIPerfTabVC.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "AMPingTabVC.h"
#import "AMIPerfConfigWC.h"
#import "AMUserList.h"
#import "AMNetworkingToolVC.h"

@interface AMIPerfTabVC ()<AMUserListDelegate,AMCheckBoxDelegeate>
{
    AMUserList* userList;
    AMIPerfConfigWC* _configController;
}
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet AMCheckBoxView *useIPV6Check;
@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *iperfContentView;
@property (weak) IBOutlet NSView *inputField;
@property (weak) IBOutlet AMCheckBoxView *serverCheck;

@end

@implementation AMIPerfTabVC

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView
                             inputField:_inputField];
    userList.delegate = self;
    userList.pingCommand.contentView = self.iperfContentView;
    
    [userList userGroupsChangedPing:nil];
    
    self.serverCheck.delegate = self;
    self.useIPV6Check.title = @"USE IPV6";
    self.useIPV6Check.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (BOOL) useIPV6
{
    return self.useIPV6Check.checked;
}

-(NSString*) formatCommand:(NSString*) ip
{
    NSMutableString* command;
    NSBundle* mainBundle = [NSBundle mainBundle];
    command = [[NSMutableString alloc] initWithFormat:@"\"%@\"",
                                 [mainBundle pathForAuxiliaryExecutable:@"iperf"]];
        
    AMIPerfConfig* cfg = _configController.iperfConfig;
    
    if (ip == nil) {
        [command appendFormat:@" -s"];
        
        
        if (cfg.useUDP)
        {
            [command appendFormat:@" -u"];
        }
        
        if (cfg.port > 0) {
            [command appendFormat:@" -p %d", (int)cfg.port];
        }
        
        if (cfg.len > 0) {
            [command appendFormat:@" -l %dK", (int)cfg.len];
        }
        
        if (self.useIPV6Check.checked) {
            [command appendFormat:@" -V"];
        }
        
        return command;
    }

    
    
    if ([AMCommonTools isValidIpv4:ip] ||
        [AMCommonTools isValidIpv6:ip]){
        
        [command appendFormat:@" -c"];
       
        [command appendFormat:@" %@", ip];
        
        if (cfg.useUDP) {
            [command appendFormat:@" -u"];
        }
        
        if (cfg.len > 0) {
            [command appendFormat:@" -l %dK", (int)cfg.len];
        }
        
        if (cfg.port > 0) {
            [command appendFormat:@" -p %d", (int)cfg.port];
        }
        
        if (self.useIPV6Check.checked) {
            [command appendFormat:@" -V"];
        }
        
        //Client
        if (cfg.dualtest) {
            [command appendFormat:@" -d"];
        }
        
        if (cfg.tradeoff) {
            [command appendFormat:@" -r"];
        }
        
        if (cfg.bandwith > 0) {
            [command appendFormat:@" -b%dM", (int)cfg.bandwith];
        }
    }
    return command;
}

- (IBAction)setParameters:(id)sender {

    _configController = [[AMIPerfConfigWC alloc] initWithWindowNibName:@"AMIPerfConfigWC"];
    NSWindow* win = _configController.window;
    [win setStyleMask:NSBorderlessWindowMask];
    [win setLevel:NSFloatingWindowLevel];
    [win setHasShadow:YES];
    [win setBackgroundColor : [NSColor colorWithCalibratedRed:38.0/255
                                                        green:38.0/255
                                                         blue:38.0/255
                                                        alpha:1]];
    
    NSRect winRect   = [win frame];
//    NSRect frame = [self.settingButton frame];
//    NSPoint tmpPoint = NSMakePoint(frame.origin.x + frame.size.width + 20,
  //                                 frame.origin.y - winRect.size.height + 120);
    
//    winRect.origin = [self.view convertPoint:tmpPoint toView:nil];;
 //   [win  setFrame:winRect display:YES];
    [win makeKeyAndOrderFront:self];
}


-(void) onChecked:(AMCheckBoxView *)sender
{
    if ([sender isEqual:self.serverCheck]){
        if(self.serverCheck.checked == YES) {

            NSString* command = [self formatCommand:nil];
            [userList executeCommand:command];
        }else{
            //When you unselected the server checkbox, should stop iperf command
            [self stopiPerf];
        }
    }else if ([sender isEqual:self.useIPV6Check]) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        if (self.useIPV6Check.checked) {
            [nc postNotificationName:AMIPV6CHECKTRUENotification object:nil];
        }else
            [nc postNotificationName:AMIPV6CHECKFALSENotification object:nil];
        
    }

}

- (void)viewWillDisappear{
    [self stopiPerf];
}

-(void)stopiPerf
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"iperf", nil]];
}


-(void) ipv6Checked : (Boolean) checked
{
    if (self.useIPV6Check.checked != checked) {
        [self.useIPV6Check setChecked:checked];
    }
}

@end

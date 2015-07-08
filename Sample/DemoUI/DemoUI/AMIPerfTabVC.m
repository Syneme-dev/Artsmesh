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

@interface AMIPerfTabVC ()<AMUserListDelegate,AMCheckBoxDelegeate>
{
    AMUserList* userList;
    AMIPerfConfigWC* _configController;
}
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet AMCheckBoxView *useIPV6;
@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *iperfContentView;
@property (weak) IBOutlet AMCheckBoxView *serverCheck;

@end

@implementation AMIPerfTabVC

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView];
    userList.delegate = self;
    userList.pingCommand.contentView = self.iperfContentView;
    
    [userList userGroupsChangedPing:nil];
    
    self.serverCheck.delegate = self;
    //self.useIPV4.delegate = self;
    self.useIPV6.title = @"USE IPV6";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
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
        
        
  //      if (cfg.useUDP)
        {
            [command appendFormat:@" -u"];
        }
        
        if (cfg.port > 0) {
            [command appendFormat:@" -p"];
        }
        
        
        if (self.useIPV6.checked) {
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
        
        if (cfg.port > 0) {
            [command appendFormat:@" -p"];
        }
        
        if (self.useIPV6.checked) {
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
    if ([sender isEqual:self.serverCheck] &&
            self.serverCheck.checked == YES) {

        NSString* command = [self formatCommand:nil];
        [userList executeCommand:command];
//        self.serverCommand = [serverCommand stop];
//        self.serverCommand.command = command;
//        [self.serverCommand run];
    }
}


@end

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
#import "AMIPerfConfig.h"

@interface AMIPerfTabVC ()<AMUserListDelegate>
{
    AMUserList* userList;
    AMIPerfConfig* _configController;
}
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet AMCheckBoxView *useIPV6;
@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *iperfContentView;

@end

@implementation AMIPerfTabVC

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView];
    userList.delegate = self;
    userList.pingCommand.contentView = self.iperfContentView;
    
    [userList userGroupsChangedPing:nil];
    
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
    
    if ([AMCommonTools isValidIpv4:ip]){
       NSBundle* mainBundle = [NSBundle mainBundle];
        command = [[NSMutableString alloc] initWithFormat:@"\"%@\"",
                                 [mainBundle pathForAuxiliaryExecutable:@"iperf"]];
    
        [command appendFormat:@" -c"];
        [command appendFormat:@" %@", ip];
        [command appendFormat:@"-u -V -b10M"];
    }
    return command;
}
- (IBAction)setParameters:(id)sender {

    _configController = [[AMIPerfConfig alloc] initWithWindowNibName:@"AMIPerfConfig"];
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

@end

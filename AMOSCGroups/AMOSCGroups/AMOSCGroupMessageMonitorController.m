//
//  AMOSCGroupMessageMonitorController.m
//  AMOSCGroups
//
//  Created by 王为 on 19/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroupMessageMonitorController.h"
#import "AMOSCClient.h"
#import "AMOscMsgTableRow.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMPopupView.h"
#import "AMOSCGroups.h"
#import "AMCoreData/AMCoreData.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMButtonHandler.h"

@implementation OSCMessagePack
{
    NSTimer *_timer;
    BOOL _highlight;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.lightView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        self.lightView.image = [NSImage imageNamed:@"osc_msg_highlight"];
        self.msgFields = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        self.paramsFields = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 30, 30)];
        _highlight = YES;
    }
    
    return self;
}

-(void)startBlinking
{
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(onBlinkingTimer:) userInfo:nil repeats:YES];
}

-(void)onBlinkingTimer:(NSTimer*)timer
{
    static int blinkCount = 0;
    
    if (blinkCount >= 2) {
        blinkCount = 0;
        [self stopBlinking];
        return;
    }
    
    NSImage *image = nil;
    if (_highlight) {
        image = [NSImage imageNamed:@"osc_msg_normal"];
        self.lightView.image = image;
        _highlight = NO;
    }else{
        image = [NSImage imageNamed:@"osc_msg_highlight"];
        self.lightView.image = image;
        _highlight = YES;
    }
    
    blinkCount++;
    
    [self.lightView setNeedsDisplay];
}

-(void)stopBlinking
{
    if (_highlight) {
        NSImage *image = [NSImage imageNamed:@"osc_msg_normal"];
        self.lightView.image = image;
        _highlight = NO;
        [self.lightView setNeedsDisplay];
    }
    
    [_timer invalidate];
    _timer = nil;
}

@end

@interface AMOSCGroupMessageMonitorController ()<NSTableViewDataSource, NSTableViewDelegate, AMOSCClientDelegate, AMCheckBoxDelegeate, AMPopUpViewDelegeate, NSTextFieldDelegate>
@property (weak) IBOutlet NSTableView *oscMsgTable;
@property NSMutableArray* oscMessageLogs;
@property NSMutableArray* oscMessageSearchResults;
@property NSMutableDictionary* timerDict;
@property NSString *searchString;
@property (weak) IBOutlet NSButton *topBtn;
@property (weak) IBOutlet NSButton *pauseBtn;
@property (weak) IBOutlet NSButton *thruBtn;
@property (weak) IBOutlet AMCheckBoxView *onOffBox;
@property (weak) IBOutlet AMPopUpView *serverSelector;
@property (weak) IBOutlet AMFoundryFontView *selfDefServer;
@property (weak) IBOutlet AMFoundryFontView *sendToDev;
@property (weak) IBOutlet AMFoundryFontView *searchField;
@property (weak) IBOutlet NSButton *clearAllBtn;
@property (weak) IBOutlet NSBox *seperaterLine;

@end

@implementation AMOSCGroupMessageMonitorController
{
    NSMutableArray *_usersRunOscSrv;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.oscMessageLogs = [[NSMutableArray alloc] init];
    self.oscMessageSearchResults = [[NSMutableArray alloc] init];
    
    self.oscMsgTable.dataSource = self;
    self.oscMsgTable.delegate = self;
    self.oscMsgTable.backgroundColor  = [NSColor colorWithCalibratedHue:0.15 saturation:0.15 brightness:0.15 alpha:0.0];
    [self.oscMsgTable setColumnAutoresizingStyle:NSTableViewNoColumnAutoresizing];
    
    self.timerDict =  [[NSMutableDictionary alloc] init];
    
    //seperatorLine
    self.seperaterLine.borderColor = [NSColor redColor];
    self.seperaterLine.fillColor = [NSColor redColor];
    
    //self define ip field
    [self.selfDefServer setHidden:YES];
    
    //Ser OnOff Checkbox
    self.onOffBox.title = @"On";
    self.onOffBox.delegate = self;
    
    //Set search field
    self.searchField.delegate = self;
    
    //Set Server Selection
    [self updateOSCServer];
    
    //Set Button Color
    [AMButtonHandler changeTabTextColor:self.topBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.thruBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.pauseBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.clearAllBtn toColor:UI_Color_blue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userGroupChanged:)
                                                 name:AM_LIVE_GROUP_CHANDED
                                               object:nil];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)userGroupChanged:(NSNotification *)notification
{
    [self updateOSCServer];
}

-(void)onChecked:(AMCheckBoxView *)sender
{
    if(self.onOffBox.checked == YES)
    {
        if (self.serverSelector.stringValue ) {
            if ([self.serverSelector.stringValue isEqualToString:@""]) {
                NSAlert *alert = [NSAlert alertWithMessageText:@"NO OSC Server"
                                                 defaultButton:@"Ok"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@"Maybe the user running osc server quit, please select another one!"];
                [alert runModal];
                return;
            }
        }
        
        NSString *serverAddr;
        if ([self.serverSelector.stringValue isEqualToString:@"Self Define"]) {
            serverAddr = self.selfDefServer.stringValue;
            
        }else if ([self.serverSelector.stringValue isEqualToString:@"Artsmesh.io"]){
            serverAddr = [[NSUserDefaults standardUserDefaults]
                          stringForKey:Preference_Key_General_GlobalServerAddr];
            
        }else{
            for (AMLiveUser *user in _usersRunOscSrv) {
                if ([user.nickName isEqualToString:self.serverSelector.stringValue]) {
                    
                    AMLiveGroup *myCluster = [[AMCoreData shareInstance] myLocalLiveGroup];
                    BOOL bFind = NO;
                    for (AMLiveUser *localUser in myCluster.users) {
                        if ([localUser.nickName isEqualToString:user.nickName]) {
                            bFind = true;
                        }
                    }
                    
                    if (bFind) {
                        serverAddr = user.privateIp;
                    }else{
                        serverAddr = user.publicIp;
                    }
                }
            }
        }
        
        [[AMOSCGroups sharedInstance] startOSCGroupClient:serverAddr];
        [self.serverSelector setEnabled:NO];
        [self.selfDefServer setEnabled:NO];
        
        self.onOffBox.title = @"Off";
    }else{
        
        [[AMOSCGroups sharedInstance] stopOSCGroupClient];
        self.onOffBox.title = @"On";
        
        [self.serverSelector setEnabled:YES];
        [self.selfDefServer setEnabled:YES];
        
        [self.oscMessageLogs removeAllObjects];
        [self.oscMessageSearchResults removeAllObjects];
        [self.oscMsgTable reloadData];
    }
}


-(void)updateOSCServer
{
    [self.serverSelector removeAllItems];
    NSString *selectedServer = self.serverSelector.stringValue;
    
    _usersRunOscSrv = [[NSMutableArray alloc] init];
    BOOL online = [AMCoreData shareInstance].mySelf.isOnline;
    if (online) {
        AMLiveGroup *myLiveGroup = [[AMCoreData shareInstance] mergedGroup];
        NSArray *allUsers = [myLiveGroup usersIncludeSubGroup];
        
        for (AMLiveUser *user in allUsers) {
            if (user.oscServer) {
                [_usersRunOscSrv addObject:user];
            }
        }
    }else{
        AMLiveGroup *myLocalGroup = [[AMCoreData shareInstance] myLocalLiveGroup];
        
        for (AMLiveUser *user in myLocalGroup.users) {
            if (user.oscServer) {
                [_usersRunOscSrv addObject:user];
            }
        }
    }
    
    self.serverSelector.textColor = [NSColor grayColor];
    [self.serverSelector addItemWithTitle:@"Artsmesh.io"];
    [self.serverSelector addItemWithTitle:@"Self Define"];
    for (AMLiveUser *user in _usersRunOscSrv) {
        [self.serverSelector addItemWithTitle:user.nickName];
    }
    
    if (![selectedServer isEqualToString:@""]) {
        [self.serverSelector selectItemWithTitle:selectedServer];
    }else{
        [self.serverSelector selectItemAtIndex:0];
    }
    
    self.serverSelector.delegate = self;
}


-(void)itemSelected:(AMPopUpView *)sender
{
    if ([self.serverSelector.stringValue isEqualToString:@"Self Define"]) {
        [self.selfDefServer setHidden:NO];
    }else{
        [self.selfDefServer setHidden:YES];
    }
}


-(void)controlTextDidChange:(NSNotification *)obj
{
    [self.searchField resignFirstResponder];
    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:self.searchField.stringValue];
    [self.oscMsgTable reloadData];
}

-(void)cancelOperation:(id)sender
{
    self.searchField.stringValue = @"";
    [self.searchField resignFirstResponder];
    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:@""];
    [self.oscMsgTable reloadData];
}

- (IBAction)clearAll:(id)sender
{
    [self.oscMessageLogs removeAllObjects];
    [self.oscMessageSearchResults removeAllObjects];
    [self.oscMsgTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.oscMessageSearchResults count];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 30.0f;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"osc_light_col"]) {
        static NSString *cellIdentifier = @"OSCMsgLightCell";
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
        
        if (cellView == nil)
        {
            NSRect cellFrame = NSMakeRect(0, 0, 30, 30);
            cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
            [cellView setIdentifier:cellIdentifier];
        }
        
        OSCMessagePack* pack = [self.oscMessageSearchResults objectAtIndex:row];
        [cellView addSubview:pack.lightView];
        
        return cellView;
        
    }else if([tableColumn.identifier isEqualToString:@"osc_msg_col"]){
        
        OSCMessagePack* pack = [self.oscMessageSearchResults objectAtIndex:row];
        
        static NSString *cellIdentifier = @"OSCMsgPathCell";
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
        
        if (cellView == nil)
        {
            NSRect cellFrame = NSMakeRect(0, 0, 100, 30);
            cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
            [cellView setIdentifier:cellIdentifier];
        }
        
        for (NSView *view in [cellView subviews]) {
            if(view.tag == 1002){
                [view removeFromSuperview];
            }
        }
        
        
        
        NSRect textFrame = cellView.bounds;
        textFrame.size.height -= 10;
    
        NSTextField *textField = pack.msgFields;
        textField.frame = textFrame;
        
        textField.font = [NSFont fontWithName:@"FoundryMonoline-Bold"
                                         size:12.0f];
        textField.tag = 1002;
        textField.bordered = NO;
        textField.editable = NO;
        textField.backgroundColor = [NSColor clearColor];
        [textField setFocusRingType:NSFocusRingTypeNone];
        [textField setTextColor:[NSColor grayColor]];
        [cellView addSubview:textField];

        return cellView;
        
    }else if([tableColumn.identifier isEqualToString:@"osc_param_col"]){
        OSCMessagePack* pack = [self.oscMessageSearchResults objectAtIndex:row];
        
        static NSString *cellIdentifier = @"OSCMsgParamCell";
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
        
        if (cellView == nil)
        {
            NSRect cellFrame = NSMakeRect(0, 0, self.view.bounds.size.width, 30);
            cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
            [cellView setIdentifier:cellIdentifier];
        }
        
        for (NSView *view in [cellView subviews]) {
            if(view.tag == 1002){
                [view removeFromSuperview];
            }
        }
        
        NSRect textFrame = cellView.bounds;
        textFrame.size.height -= 10;
        NSTextField *textField = pack.paramsFields;
        textField.frame = textFrame;
        
        textField.font = [NSFont fontWithName:@"FoundryMonoline-Bold"
                                         size:12.0f];
        textField.tag = 1002;
        textField.bordered = NO;
        textField.editable = NO;
        textField.backgroundColor = [NSColor clearColor];
        [textField setFocusRingType:NSFocusRingTypeNone];
        [textField setTextColor:[NSColor grayColor]];
        [cellView addSubview:textField];
        
        return cellView;
    }
    
    return nil;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row NS_AVAILABLE_MAC(10_7)
{
    AMOscMsgTableRow* tableRow = [[AMOscMsgTableRow alloc] init];
    return tableRow;
}

-(void)oscMsgComming:(NSString *)msg parameters:(NSArray *)params
{
    NSMutableString *paramDetail = [[NSMutableString alloc] init];
    
    for (NSDictionary *dict in params) {
        //only one key-value pair in dict
        NSString *type = [[dict allKeys] firstObject];
        id value = [dict objectForKey:type];
        
        if([type isEqualToString:@"BOOL"]){
            [paramDetail appendFormat:@"%@(%@), ", value, type];
            
        }else if([type isEqualToString:@"INT"]){
            [paramDetail appendFormat:@"%@(%@), ", value, type];

        }else if([type isEqualToString:@"LONG"]){
            [paramDetail appendFormat:@"%@(%@), ", value, type];
            
        }else if([type isEqualToString:@"FLOAT"]){
            [paramDetail appendFormat:@"%@(%@), ", value, type];
            
        }else if([type isEqualToString:@"STRING"]){
            NSString *text = (NSString *)value;
            if ([text length] > 12){
                text = [text substringToIndex:12];
                text = [NSString stringWithFormat:@"%@...", text];
            }
            [paramDetail appendFormat:@"%@(%@), ", text, type];
            
        }else if([type isEqualToString:@"BLOB"]){
            [paramDetail appendFormat:@"...(%@), ", type];
        
        }
    }
    
    NSLog(@"params = %@", paramDetail);
    
    for (OSCMessagePack *pack in self.oscMessageLogs) {
        if ([pack.msgFields.stringValue isEqualToString:msg]) {
            pack.paramsFields.stringValue = paramDetail;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setOscMessageSearchFilterString:self.searchString];
                [pack startBlinking];
            });
            return;
        }
    }
    
    OSCMessagePack *oscPack = [[OSCMessagePack alloc] init];
    oscPack.msgFields.stringValue = msg;
    oscPack.paramsFields.stringValue = paramDetail;
    [self.oscMessageLogs addObject:oscPack];
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [self setOscMessageSearchFilterString:self.searchString];
         [self.oscMsgTable reloadData];
         [oscPack startBlinking];
    });
}

-(void)setOscMessageSearchFilterString:(NSString *)filterStr
{
    self.searchString = filterStr;
    
    if (filterStr == nil || [filterStr isEqualTo:@""]) {
        self.oscMessageSearchResults = [NSMutableArray arrayWithArray:self.oscMessageLogs];
        return;
    }

    self.oscMessageSearchResults = [[NSMutableArray alloc] init];
    for (OSCMessagePack *pack in self.oscMessageLogs) {
        
        NSString* strLowerMsg = [pack.msgFields.stringValue lowercaseString];
        NSString* strLowerFilter = [filterStr lowercaseString];
        if ([strLowerMsg rangeOfString:strLowerFilter].location == NSNotFound) {
            continue;
        }else{
            [self.oscMessageSearchResults addObject:pack];
        }
    }
}


@end

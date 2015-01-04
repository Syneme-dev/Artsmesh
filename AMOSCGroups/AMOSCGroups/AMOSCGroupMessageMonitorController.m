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
#import "UIFramework/AMPopupView.h"
#import "AMOSCGroups.h"
#import "AMCoreData/AMCoreData.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMOSCForwarder.h"
#import "AMCommonTools/AMCommonTools.h"

@implementation OSCMessagePack
{
    NSTimer *_timer;
    BOOL _highlight;
}

-(instancetype)init
{
    if (self = [super init]) {
        NSRect commonRect = NSMakeRect(0, 0, 30, 30);
        
        self.lightView = [[NSImageView alloc] initWithFrame:commonRect];
        self.lightView.image = [NSImage imageNamed:@"osc_msg_highlight"];
        self.msgFields = [[NSTextField alloc] initWithFrame:commonRect];
      //  self.msgFields.usesSingleLineMode = YES;
        self.paramsFields = [[NSTextField alloc] initWithFrame:commonRect];
     //   self.paramsFields.usesSingleLineMode = YES;
        self.onTopBox = [[AMCheckBoxView alloc] initWithFrame:commonRect];
        self.thruBox = [[AMCheckBoxView alloc] initWithFrame:commonRect];
        
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
@property (weak) IBOutlet AMFoundryFontView *forwardDevPort;

@end

@implementation AMOSCGroupMessageMonitorController
{
    NSMutableArray *_usersRunOscSrv;
    NSMutableSet *_thruMsgSet;
    AMOSCForwarder *_oscForwarder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.oscMessageLogs = [[NSMutableArray alloc] init];
    self.oscMessageSearchResults = [[NSMutableArray alloc] init];
    
    //table
    self.oscMsgTable.dataSource = self;
    self.oscMsgTable.delegate = self;
    self.oscMsgTable.backgroundColor  = [NSColor colorWithCalibratedHue:0.15 saturation:0.15 brightness:0.15 alpha:0.0];
    [self.oscMsgTable setColumnAutoresizingStyle:NSTableViewNoColumnAutoresizing];

    
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


-(void)onOffChecked
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
        
        if([self.sendToDev.stringValue isNotEqualTo:@""] || [self.forwardDevPort.stringValue isNotEqualTo:@""]){
            
            NSString *forwardIp = self.sendToDev.stringValue;
            if(![AMCommonTools isValidIpv4:forwardIp]){
                NSAlert *alert = [NSAlert alertWithMessageText:@"forward address is invalid!"
                                                 defaultButton:@"Ok"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@""];
                [alert runModal];
                return;
            }
            
            int forwardPort = [self.forwardDevPort.stringValue intValue];
            if(forwardPort < 1024 || forwardPort > 65535){
                NSAlert *alert = [NSAlert alertWithMessageText:@"forward port is invalid!"
                                                 defaultButton:@"Ok"
                                               alternateButton:nil
                                                   otherButton:nil
                                     informativeTextWithFormat:@""];
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
        [self.sendToDev setEnabled:NO];
        [self.forwardDevPort setEnabled:NO];
        
        self.onOffBox.title = @"Off";
    }else{
        
        [[AMOSCGroups sharedInstance] stopOSCGroupClient];
        self.onOffBox.title = @"On";
        
        [self.serverSelector setEnabled:YES];
        [self.selfDefServer setEnabled:YES];
        [self.sendToDev setEnabled:YES];
        [self.forwardDevPort setEnabled:YES];
        
        [self.oscMessageLogs removeAllObjects];
        [self.oscMessageSearchResults removeAllObjects];
        [self.oscMsgTable reloadData];
    }
}


-(void)onTopChecked:(NSString *)msg checked:(BOOL)checked
{
    [self sortByOnTop];
    [self.oscMsgTable reloadData];
}

-(void)thruChecked:(NSString *)msg  checked:(BOOL)checked
{
    NSLog(@"thru checked");
    
    if (_thruMsgSet == nil) {
        _thruMsgSet = [[NSMutableSet alloc] init];
    }
    
    if(checked){
        [_thruMsgSet addObject:msg];
    }else{
        [_thruMsgSet removeObject:msg];
    }
}


-(void)onChecked:(AMCheckBoxView *)sender
{
    if([sender.identifier isEqualToString:@"oscMonitorOnOff"]){
        [self onOffChecked];
    }else if([sender.title isEqualToString:@"OnTop"]){
        
        NSString *msg = sender.identifier;
        BOOL checked = sender.checked;
        
        [self onTopChecked:msg checked:checked];
        
    }else if([sender.title isEqualToString:@"Thru"]){
        NSString *msg = sender.identifier;
        BOOL checked = sender.checked;
        
        [self thruChecked:msg checked:checked];
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
    [_thruMsgSet removeAllObjects];
    [self.oscMsgTable reloadData];
}


-(CGFloat)heightOfTextFieldWithString:(NSString *)string width:(CGFloat)width font:(NSFont *)font
{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, width, 1000)];
    textField.font = font;
    textField.stringValue = string;
    NSSize size = [textField.cell cellSizeForBounds:textField.frame];
    return size.height;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.oscMessageSearchResults count];
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
            if(view.tag == 1001){
                [view removeFromSuperview];
            }
        }
        
        NSTextField *textField = pack.msgFields;
        textField.tag = 1001;
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
        
        NSTextField *textField = pack.paramsFields;
        textField.tag = 1002;
        [cellView addSubview:textField];
        
        return cellView;
        
    }else if([tableColumn.identifier isEqualToString:@"osc_check_col"]){
        OSCMessagePack* pack = [self.oscMessageSearchResults objectAtIndex:row];
        
        static NSString *cellIdentifier = @"OSCMsgCheckCell";
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
        
        if (cellView == nil)
        {
            NSRect cellFrame = NSMakeRect(0, 0, self.view.bounds.size.width, 30);
            cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
            [cellView setIdentifier:cellIdentifier];
        }
        
        for (NSView *view in [cellView subviews]) {
            if(view.tag == 1003 || view.tag == 1004){
                [view removeFromSuperview];
            }
        }
        
        AMCheckBoxView* onTopBox = pack.onTopBox;
        AMCheckBoxView* thruBox = pack.thruBox;
        
        NSRect frameRect = NSMakeRect(10, 0, 70, 30);
        onTopBox.frame = frameRect;
        
        frameRect = NSMakeRect(85, 0, 70, 30);
        thruBox.frame = frameRect;
        
        [cellView addSubview:onTopBox];
        [cellView addSubview:thruBox];
        
        return cellView;
    
    }
    
    return nil;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    OSCMessagePack* pack = [self.oscMessageSearchResults objectAtIndex:row];
    CGFloat maxHeight = pack.msgFields.frame.size.height;
    
    if (pack.paramsFields.frame.size.height> maxHeight) {
        maxHeight = pack.paramsFields.frame.size.height;
    }
    
    if (pack.onTopBox.frame.size.height> maxHeight) {
        maxHeight = pack.onTopBox.frame.size.height;
    }
    
    if(pack.thruBox.frame.size.height> maxHeight){
        maxHeight = pack.thruBox.frame.size.height;
    }
    
    if(maxHeight < 30.0){
        maxHeight = 30.0;
    }
    
    return maxHeight;
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
    
   // NSLog(@"params = %@", paramDetail);
    
    
    for (NSString *thruMsg in _thruMsgSet) {
        if ([thruMsg isEqualTo:msg]) {
            NSString* addr = self.sendToDev.stringValue;
            NSString* port = self.forwardDevPort.stringValue;
            [AMOSCForwarder forwardMsg:msg params:params toAddr:addr port:port];
        }
    }
    
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
    oscPack.onTopBox.title = @"OnTop";
    oscPack.thruBox.title = @"Thru";
    oscPack.onTopBox.delegate = self;
    oscPack.thruBox.delegate = self;
    oscPack.onTopBox.identifier = msg;
    oscPack.thruBox.identifier = msg;
    
    NSFont *font = [NSFont fontWithName:@"FoundryMonoline-Bold"
                                   size:12.0f];
    NSUInteger colIndex = [self.oscMsgTable columnWithIdentifier:@"osc_param_col"];
    CGFloat width = [[[self.oscMsgTable tableColumns] objectAtIndex:colIndex] width];
    CGFloat height = [self heightOfTextFieldWithString:oscPack.paramsFields.stringValue
                                width:width font:font];
    
    oscPack.paramsFields.frame = NSMakeRect(0, 0, width, height);
    oscPack.paramsFields.font = font;
    oscPack.paramsFields.bordered = NO;
    oscPack.paramsFields.editable = NO;
    oscPack.paramsFields.backgroundColor = [NSColor clearColor];
    [oscPack.paramsFields setFocusRingType:NSFocusRingTypeNone];
    [oscPack.paramsFields setTextColor:[NSColor grayColor]];
    
    colIndex = [self.oscMsgTable columnWithIdentifier:@"osc_msg_col"];
    width = [[[self.oscMsgTable tableColumns] objectAtIndex:colIndex] width];
    height = [self heightOfTextFieldWithString:oscPack.msgFields.stringValue
                                         width:width font:font];
    oscPack.msgFields.frame = NSMakeRect(0, 0, width, height);
    oscPack.msgFields.font = font;
    oscPack.msgFields.bordered = NO;
    oscPack.msgFields.editable = NO;
    oscPack.msgFields.backgroundColor = [NSColor clearColor];
    [oscPack.msgFields setFocusRingType:NSFocusRingTypeNone];
    [oscPack.msgFields setTextColor:[NSColor grayColor]];
    
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
    }else{
        
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
    
    [self sortByOnTop];
}


-(void)sortByOnTop
{
    NSMutableArray *sortedMsgs = [[NSMutableArray alloc] init];
    
    for (OSCMessagePack *pack in self.oscMessageSearchResults) {
        if(pack.onTopBox.checked == YES){
            [sortedMsgs addObject:pack];
        }
    }
    
    for (OSCMessagePack *pack in self.oscMessageSearchResults) {
        if (pack.onTopBox.checked == NO) {
            [sortedMsgs addObject:pack];
        }
    }
    
    self.oscMessageSearchResults = sortedMsgs;
}


@end

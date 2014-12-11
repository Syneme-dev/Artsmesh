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

@interface AMOSCGroupMessageMonitorController ()<NSTableViewDataSource, NSTableViewDelegate, AMOSCClientDelegate>
@property (weak) IBOutlet NSTableView *oscMsgTable;
@property NSMutableArray* oscMessageLogs;
@property NSMutableDictionary* timerDict;

@end

@implementation AMOSCGroupMessageMonitorController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.oscMessageLogs = [[NSMutableArray alloc] init];
    self.oscMsgTable.dataSource = self;
    self.oscMsgTable.delegate = self;
    self.oscMsgTable.backgroundColor  = [NSColor colorWithCalibratedHue:0.15 saturation:0.15 brightness:0.15 alpha:0.0];
    [self.oscMsgTable setColumnAutoresizingStyle:NSTableViewLastColumnOnlyAutoresizingStyle];
    
    self.timerDict =  [[NSMutableDictionary alloc] init];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.oscMessageLogs count];
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
        
        OSCMessagePack* pack = [self.oscMessageLogs objectAtIndex:row];
        [cellView addSubview:pack.lightView];
        
        return cellView;
        
    }else if([tableColumn.identifier isEqualToString:@"osc_msg_col"]){
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
        NSTextField *textField = [[NSTextField alloc] initWithFrame:textFrame];
        textField.font = [NSFont fontWithName:@"FoundryMonoline-Bold"
                                         size:12.0f];
        textField.tag = 1002;
        textField.bordered = NO;
        textField.editable = NO;
        textField.backgroundColor = [NSColor clearColor];
        [textField setFocusRingType:NSFocusRingTypeNone];
        [textField setTextColor:[NSColor grayColor]];
        [cellView addSubview:textField];

        OSCMessagePack* pack = [self.oscMessageLogs objectAtIndex:row];
        textField.stringValue = pack.msg;
        
        return cellView;
        
    }else if([tableColumn.identifier isEqualToString:@"osc_param_col"]){
        
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
        NSTextField *textField = [[NSTextField alloc] initWithFrame:textFrame];
        textField.font = [NSFont fontWithName:@"FoundryMonoline-Bold"
                                         size:12.0f];
        textField.tag = 1002;
        textField.bordered = NO;
        textField.editable = NO;
        textField.backgroundColor = [NSColor clearColor];
        [textField setFocusRingType:NSFocusRingTypeNone];
        [textField setTextColor:[NSColor grayColor]];
        [cellView addSubview:textField];
        
        OSCMessagePack* pack = [self.oscMessageLogs objectAtIndex:row];
        textField.stringValue = pack.params;
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
        if ([pack.msg isEqualToString:msg]) {
            pack.params = paramDetail;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.oscMsgTable reloadData];
                [pack startBlinking];
            });
            return;
        }
    }
    
    OSCMessagePack *oscPack = [[OSCMessagePack alloc] init];
    oscPack.msg = msg;
    oscPack.params = paramDetail;
    [self.oscMessageLogs addObject:oscPack];
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [self.oscMsgTable reloadData];
         [oscPack startBlinking];
    });
}


@end

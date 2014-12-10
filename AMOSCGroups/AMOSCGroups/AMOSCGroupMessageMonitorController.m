//
//  AMOSCGroupMessageMonitorController.m
//  AMOSCGroups
//
//  Created by 王为 on 19/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroupMessageMonitorController.h"
#import "AMOSCClient.h"


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
    
    self.timerDict =  [[NSMutableDictionary alloc] init];
    
}

-(void)addOscMessageLog:(NSString*)msg
{
    NSUInteger index = [self.oscMessageLogs indexOfObject:msg];
    if (index == NSNotFound) {
        [self.oscMessageLogs addObject:msg];
        [self.oscMsgTable reloadData];
    }else{
        [self blinkTableRow:index];
    }
}


-(void)blinkTableRow:(NSUInteger)row
{
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(onBlinkingTimer:)
                                                    userInfo:[NSNumber numberWithUnsignedLong:row]
                                                     repeats:NO];
    
    [self.timerDict setObject:timer forKey:[NSNumber numberWithUnsignedLong:row]];
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:row];
    [self.oscMsgTable selectRowIndexes:indexSet byExtendingSelection:NO];
    [self.oscMsgTable setNeedsDisplay];
}

-(void)onBlinkingTimer:(NSTimer*)timer
{
    NSNumber* row = timer.userInfo;
    [self.oscMsgTable deselectRow:[row integerValue]];
    [self.oscMsgTable setNeedsDisplay];
    
    NSTimer* t = (NSTimer*)[self.timerDict objectForKey:row];
    [t invalidate];
    t = nil;
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [self.oscMessageLogs count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    static NSString *cellIdentifier = @"OSCMessageCellView";
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier owner:self];
    
    if (cellView == nil)
    {
        NSRect cellFrame = self.oscMsgTable.bounds;
        cellFrame.size.height = 30;
        
        cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
        [cellView setIdentifier:cellIdentifier];
    }
    
    cellView.textField.stringValue = [self.oscMessageLogs objectAtIndex:row];
    return cellView;
}


//-(void)printOSCPacket:(OSCPacket*) packet received:(BOOL)isRecv
//{
//    if(![packet isBundle]){
//        OSCMutableMessage* messages = (OSCMutableMessage*)packet;
//        
//        if (isRecv) {
//            NSMutableString* oscmsg = [[NSMutableString alloc] initWithFormat:@"Received: %@", messages.address ];
//            [self addOscMessageLog:oscmsg];
//        }else{
//            NSMutableString* oscmsg = [[NSMutableString alloc] initWithFormat:@"Sent: %@", messages.address ];
//            [self addOscMessageLog:oscmsg];
//        }
//        
//        return;
//    }else{
//        for (OSCPacket* pk in [packet childPackets]) {
//            [self printOSCPacket:pk received:isRecv];
//        }
//    }
//}


-(void)oscMessageRecieved:(id)oscPacket{
    //[self printOSCPacket:oscPacket received:YES];

}


-(void)oscMessageSent:(id)oscPacket
{
    //[self printOSCPacket:oscPacket received:NO];
}

@end

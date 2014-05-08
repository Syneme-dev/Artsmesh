//
//  AMChatTableCellView.m
//  DemoUI
//
//  Created by Wei Wang on 5/8/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChatTableCellView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMStatusNetModule/AMStatusNetModule.h"

@implementation AMChatTableCellView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)viewDidMoveToSuperview
{
    for (NSView* view in self.subviews)
    {
        if ([view isKindOfClass:[NSButton class]])
        {
            NSButton* btn = view;
            if([btn.identifier isEqualTo:@"post"])
            {
                [btn setTarget:self];
                [btn setAction:@selector(postChat:)];
            }
        }
    }
}

- (IBAction)postChat:(id)sender
{
    if ([sender isKindOfClass:[NSButton class]])
    {
        NSButton* clickBtn = sender;
        if ([clickBtn.superview isKindOfClass:[NSTableCellView class]])
        {
            NSString* senderName;
            NSString* sendTime;
            NSString* message;
            
            AMChatTableCellView* tableCellView = (AMChatTableCellView*)clickBtn.superview;
            for (NSView* view in tableCellView.subviews)
            {
                if ([view.identifier isEqualTo:@"sender"])
                {
                    NSTextField* tf = (NSTextField*)view;
                    senderName = tf.stringValue;
                }
                else if ([view.identifier isEqualTo:@"message"])
                {
                    NSTextField* tf = (NSTextField*)view;
                    message = tf.stringValue;
                }
                else if([view.identifier isEqualTo:@"sendTime"])
                {
                    NSTextField* tf = (NSTextField*)view;
                    sendTime = tf.stringValue;
                }
            }
            NSString* status = [NSString stringWithFormat:@"%@ said: %@ at %@ in group", senderName, message, sendTime];
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* statusNetURL = [defaults stringForKey:Preference_Key_StatusNet_URL];
            NSString* username = [defaults stringForKey:Preference_Key_StatusNet_UserName];
            NSString* password = [defaults stringForKey:Preference_Key_StatusNet_Password];
            
            AMStatusNetModule* statusNetMod = [[AMStatusNetModule alloc] init];
            BOOL res = [statusNetMod postMessageToStatusNet:status
                                                 urlAddress:statusNetURL
                                               withUserName:username
                                               withPassword:password];
            if (res)
            {
                [clickBtn setEnabled:NO];;
            }
        }
    }

}

@end

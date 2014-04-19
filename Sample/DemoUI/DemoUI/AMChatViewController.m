//
//  AMChatViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMChatViewController.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMUser.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMChatViewController ()

@end

@implementation AMChatViewController
{
    GCDAsyncUdpSocket *_socket;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

            _socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                    delegateQueue:dispatch_get_main_queue()];
            int port = 43251;
            
            NSError *error = nil;
            
            if (![_socket bindToPort:port error:&error]) {
                NSLog(@"Error binding: %@", error);
                return nil;
            }
            
            if (![_socket beginReceiving:&error]) {
                NSLog(@"Error receiving: %@", error);
                return nil;
            }
    }
    return self;
}


-(void) appendOutputTextLine:(NSString*)textLine
{
	[self appendOutputText:[NSString stringWithFormat:@"%@\r",textLine]];
}

-(void) appendOutputText:(NSString*)text
{
	printf("%s",[text UTF8String]);
	[self performSelectorOnMainThread:@selector(appendOutputTextOnMainThread:) withObject:text waitUntilDone:NO];
}

-(void) appendOutputTextOnMainThread:(id)data
{
    NSString *text=data;
	//[[[self.msgHistory  textStorage] mutableString] appendString:text];
    
    [self.msgHistory insertText:text];
    
    NSRange range;
    range = NSMakeRange ([[self.msgHistory  string] length], 0);
	
    [self.msgHistory  scrollRangeToVisible: range];
    
    //NSColor * color = [NSColor colorWithDeviceRed:0.65 green:0.82 blue:0.86 alpha: 1.0];
    NSColor * color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha: 1.0];
    [self.msgHistory  setTextColor:color];
    
    NSFont*  oldFont = self.msgHistory.font;
    
    NSFont* font = [NSFont fontWithName:oldFont.fontName size: 20];
    [self.msgHistory  setFont:font];
    
	   
}

//#pragma mark -
//#pragma mark NSTextViewDelegate
//
//- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
//{
//    if((aSelector == @selector(noop:)) && [self isCommandEnterEvent:[NSApp currentEvent]])
//    {
//        [self handleChatHistoryCommandEnter: aTextView];
//        return YES;
//    }
//    
//    return NO;
//}




- (IBAction)sendMsg:(id)sender
{
    NSString* msg = [self.chatMsgField stringValue];
    if(msg == nil || [msg isEqualToString:@""])
    {
        return;
    }
    
    NSMutableArray* userips = [[NSMutableArray alloc] init];
    
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* nickName =[defaults stringForKey:Preference_Key_User_NickName];
    
    NSData* msgData = [[NSString stringWithFormat:@"%@:%@", nickName, msg] dataUsingEncoding:NSUTF8StringEncoding];
    
    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSArray* users = mesher.myGroupUsers;
    if(users != nil)
    {
        for (AMUser* user in users)
        {
            NSString* ip = user.communicationIp;
            //int port = [user.communicationPort intValue];
            
            [_socket sendData:msgData toHost:ip port:43251 withTimeout:-1 tag:0];
        }
    }
    
    self.chatMsgField.stringValue = @"";
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (!msg)
        msg = @"Unknown message";
    
    NSString *host = nil;
    uint16_t port = 0;
    [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
 
    [self appendOutputTextLine: msg];
    
	NSLog(@"%@:%hu said: %@", host, port, msg);
}
@end

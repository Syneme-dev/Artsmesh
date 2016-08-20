//
//  AMP2PViewController.m
//  Artsmesh
//
//  Created by Whisky Zed on 163/24/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import "AMP2PViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AMVideoDeviceManager.h"
#import "AMSyphonView.h"
#import <VideoToolbox/VideoToolbox.h>
#import "AMNetworkUtils/JSONKit.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"


#include "AMLogger/AMLogger.h"
#include <stdio.h>      /* standard C i/o facilities */
#include <stdlib.h>     /* needed for atoi() */
#include <unistd.h>     /* defines STDIN_FILENO, system calls,etc */
#include <sys/types.h>  /* system data type definitions */
#include <sys/socket.h> /* socket specific definitions */
#include <netinet/in.h> /* INET constants and stuff */
#include <arpa/inet.h>  /* IP address conversion stuff */
#include <netdb.h>      /* gethostbyname */
#include "AMP2PVideoView.h"
#include "AMP2PVideoCommon.h"
#include "AMP2PVideoReceiver.h"


#define MAXBUF 1024*1024

NSString *const AMP2PVideoReceiverChanged;

@interface AMP2PViewController ()
@property (weak) IBOutlet AMP2PVideoView *videoView;
@property (weak) IBOutlet NSPopUpButtonCell *serverTitlePopUpButton;
@end

@implementation AMP2PViewController
{
    NSString*                       _port;
    AMP2PVideoReceiver*             _receiver;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_receiver unregisterP2PVideoLayer:self.videoView.videoLayer withPort:_port];
}



- (IBAction)serverSelected:(NSPopUpButton*)sender {
    NSError *error = nil;
    NSInteger port = 0;
    NSString* url = sender.selectedItem.title;
    NSUInteger commaPosition =[url rangeOfString:@":"
                                         options:NSBackwardsSearch].location;
    if(commaPosition != NSNotFound){
        _port = [url substringFromIndex:commaPosition+1];
        AMLog(kAMInfoLog, @"Video Mixer", @"port=[%@]", _port);
        port =[_port integerValue];
    }
    if(port <= 0){
        AMLog(kAMErrorLog, @"Video Mixer", @"Parse port error");
        return;
    }
    
    
    _receiver = [[AMP2PVideoReceiver alloc] init];
    [_receiver registerP2PVideoLayer:self.videoView.videoLayer withPort:port];
    

    return;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self updateServerTitle];
    NSNotificationCenter* defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self
                  selector:@selector(updateServerTitle)
                      name:AMP2PVideoReceiverChanged
                    object:nil];
    
    [defaultNC addObserver:self
                  selector:@selector(stopP2PVideo)
                      name:AMP2PVideoStopNotification
                    object:nil];
 //   _lastNALUData = [[NSMutableData alloc] init];
}


-(NSInteger) stopP2PVideo
{
 //   [_udpSocket close];
    [_receiver unregisterP2PVideoLayer:self.videoView.videoLayer withPort:_port];
    return [_port integerValue];
}

-(Boolean) resumeP2PVideo
{
    int port =[_port integerValue];
    if(port <= 0){
        AMLog(kAMErrorLog, @"Video Mixer", @"resumeP2PVideo port error");
        return NO;
    }
    _receiver = [[AMP2PVideoReceiver alloc] init];
    [_receiver registerP2PVideoLayer:self.videoView.videoLayer withPort:port];
    
    return YES;
}


-(void) updateServerTitle
{
    [_serverTitlePopUpButton removeAllItems];
    
    NSArray* serverTitles = [self getP2PServerNames];
    [_serverTitlePopUpButton addItemsWithTitles:serverTitles];
}

-(NSArray*)getP2PServerNames
{
    NSMutableArray*         serverNames   = [[NSMutableArray alloc] init];
    AMVideoDeviceManager*   deviceManager = [AMVideoDeviceManager sharedInstance];

    for (AMVideoDevice* device in [deviceManager allServerDevices]) {
        NSString* serverTitle = device.deviceID;
        [serverNames addObject:serverTitle];
    }
        
    return serverNames;
}

@end

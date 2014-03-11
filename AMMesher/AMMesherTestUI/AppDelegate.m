//
//  AppDelegate.m
//  AMMesherTestUI
//
//  Created by Wei Wang on 3/11/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AppDelegate.h"
#import "AMETCDApi/AMETCD.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.mesher = [[AMMesher alloc] init];
    [self.mesher start];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.mesher stop];
}

- (IBAction)getValue:(id)sender {

    AMETCD* etcd = [self.mesher getETCDRef];
    AMETCDResult* res = [etcd getKey:self.key.stringValue];
    if (res.errCode == 0)
    {
        self.key_value.stringValue = res.node.value;
    }
}

- (IBAction)setValue:(id)sender {
    AMETCD* etcd = [self.mesher getETCDRef];
    AMETCDResult* res = [etcd setKey:self.key.stringValue withValue:self.key_value.stringValue];
    if (res.errCode != 0) {
        self.errorMsg.stringValue = @"set error";
    }
}

- (IBAction)getETCDLeader:(id)sender {
    AMETCD* etcd = [self.mesher getETCDRef];
    if(etcd != nil)
    {
        self.etcdLeader.stringValue = [etcd getLeader];
    }
}
@end

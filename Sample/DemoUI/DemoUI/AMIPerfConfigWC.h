//
//  AMIPerfConfig.h
//  Artsmesh
//
//  Created by whiskyzed on 7/3/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const AMIPerfServerStartNotification;


@interface AMIPerfConfig : NSObject
@property (nonatomic)  BOOL         serverRole;
@property (nonatomic)  BOOL         useUDP;
@property (nonatomic)  NSInteger    port;
@property (nonatomic)  NSInteger    bandwith;
@property (nonatomic)  BOOL         tradeoff;
@property (nonatomic)  BOOL         dualtest;
@property (nonatomic)  BOOL         useIPV6;
@property (nonatomic)  NSInteger    len;            //length for buffer.
@end


@interface AMIPerfConfigWC : NSWindowController
@property AMIPerfConfig* iperfConfig;
@end

//
//  AMOSCForwarder.h
//  AMOSCGroups
//
//  Created by wangwei on 29/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMOSCForwarder : NSObject

@property NSString *forwardAddr;
@property NSString *forwardPort;

-(void)forwardMessage:(NSData *)oscPack;
-(void)forwardMessage:(NSData *)oscPack toAddr:(NSString *)addr port:(NSString *)port;

@end

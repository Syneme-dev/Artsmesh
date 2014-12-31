//
//  AMOSCForwarder.h
//  AMOSCGroups
//
//  Created by wangwei on 29/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMOSCForwarder : NSObject

-(BOOL)openSocketWithAddr:(NSString *)remoteAddr port:(NSString*)remotePort;
-(void)forwardMsg:(NSString *)msg
           params:(NSArray *)params;
-(void)closeSocket;


+(void)forwardMsg:(NSString *)msg
           params:(NSArray *)params
           toAddr:(NSString *)addr
             port:(NSString *)port;
@end

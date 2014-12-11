//
//  AMOSCMonitor.h
//  AMOSCGroups
//
//  Created by wangwei on 10/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMOSCMonitorDelegate;
@interface AMOSCMonitor : NSObject

@property (weak) id<AMOSCMonitorDelegate>delegate;

+(id)monitorWithPort:(int)port;
+(AMOSCMonitor *)shareMonitor;

-(BOOL)startListening;
-(void)stopListening;

@end

@protocol AMOSCMonitorDelegate<NSObject>
@optional

-(void)receivedOscMsg:(NSData*)data;
-(void)parsedOscMsg:(NSString *)msg withParameters:(NSArray *)params;

@end

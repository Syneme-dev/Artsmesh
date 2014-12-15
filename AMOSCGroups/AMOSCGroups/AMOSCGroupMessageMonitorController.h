//
//  AMOSCGroupMessageMonitorController.h
//  AMOSCGroups
//
//  Created by 王为 on 19/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OSCMessagePack : NSObject

@property NSString *msg;
@property NSString *params;
@property NSImageView *lightView;

-(void)startBlinking;

@end

@interface AMOSCGroupMessageMonitorController : NSViewController

-(void)setOscMessageSearchFilterString:(NSString *)filterStr;

@end

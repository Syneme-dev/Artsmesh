//
//  AMOSCGroupMessageMonitorController.h
//  AMOSCGroups
//
//  Created by 王为 on 19/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMCheckBoxView.h"

@interface OSCMessagePack : NSObject

@property NSTextField *msgFields;
@property NSTextField *paramsFields;
@property NSImageView *lightView;
@property AMCheckBoxView *onTopBox;
@property AMCheckBoxView *thruBox;

-(void)startBlinking;

@end


@interface AMOSCGroupMessageMonitorController : NSViewController

-(void)setOscMessageSearchFilterString:(NSString *)filterStr;

@end

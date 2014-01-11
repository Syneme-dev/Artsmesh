//
//  AMNotificationMessage.h
//  AMNotificationManager
//
//  Created by Sky JIA on 1/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMNotificationMessage : NSObject
#pragma mark Header
-(NSInteger) countIndex;
-(NSDictionary*) header;

#pragma mark Body
-(id) body;
@end

//
//  AMJackHelper.h
//  JackClient
//
//  Created by wangwei on 9/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <jack/jack.h>

@interface AMJackHelper : NSObject

+(NSString*)jackStatusToString:(jack_status_t)status;
+(float) value_to_db:(float)value;
+(float) db_to_value:(float) db;


@end

//
//  AMETCDUserTTLOperation.h
//  AMMesher
//
//  Created by 王 为 on 4/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDUserTTLOperation : AMETCDOperation

@property NSString* fullUserName;
@property int ttl;


-(id)initWithParameter:(NSString*)ip
            port:(NSString*)port
              fullUserName:(NSString*)fullUserName
                   ttl:(int)ttl;

@end

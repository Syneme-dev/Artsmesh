//
//  AMETCDInitOperation.h
//  AMMesher
//
//  Created by 王 为 on 4/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDInitOperation : AMETCDOperation

-(id)initWithEtcdServer:(NSString*)ip
                   port:(NSString*)port;
@end

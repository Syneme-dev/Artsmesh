//
//  AMETCDDeleteUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDDeleteUserOperation : AMETCDOperation

@property NSString* fullUserName;

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName;

@end

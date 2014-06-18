//
//  AMGroup.m
//
//  Created by lattesir on 5/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroup.h"

@implementation AMGroup

+ (NSString*) createGroupId
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    
    return uuidStr;
}

@end

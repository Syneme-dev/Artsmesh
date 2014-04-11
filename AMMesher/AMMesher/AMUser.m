//
//  AMUser.m
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUser.h"

@implementation AMUser

-(id)init
{
    if(self = [super init])
    {
        self.isLeaf = YES;
        self.children = nil;
        self.domain = @"default";
        self.location = @"default";
    }
    
    return self;
}

-(NSString*)nodeName
{
    if (self.uniqueName == nil)
    {
        return @"default";
    }
    
    NSArray* nameParts = [AMUser parseFullUserName:self.uniqueName];
    if (nameParts != nil && [nameParts count] >= 1)
    {
        return [nameParts objectAtIndex:0];
    }
    
    return @"default";
}


+(NSArray*)parseFullUserName:(NSString*)fullName
{
    NSMutableArray* parts = [[NSMutableArray alloc] init];
    NSArray* nameAndDomain = [fullName componentsSeparatedByString:@"@"];
    [parts addObject:[nameAndDomain objectAtIndex:0]];
    
    if ([nameAndDomain count] > 1)
    {
        NSArray* domainAndLocation = [[nameAndDomain objectAtIndex:1] componentsSeparatedByString:@"."];
        [parts addObject:[domainAndLocation objectAtIndex:0]];
        
        if ([domainAndLocation count] > 1)
        {
            [parts addObject:[domainAndLocation objectAtIndex:1]];
        }
    }
    
    return parts;
}

@end

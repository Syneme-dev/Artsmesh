//
//  AMGroup.m
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMGroup.h"
#import "AMETCDApi/AMETCD.h"
#import "AMUser.h"

@implementation AMGroup

-(id)init
{
    if (self = [super init])
    {
        self.isLeaf = NO;
        self.children = [[NSMutableArray alloc] init];
        self.parent = nil;
    }
    
    return self;
}

-(NSString*)nodeName
{
    if (self.uniqueName == nil)
    {
        return @"default";
    }
    
//    NSArray* nameParts = [AMGroup parseFullGroupName:self.uniqueName];
//    if (nameParts != nil && [nameParts count] >= 1)
//    {
//        return [nameParts objectAtIndex:0];
//    }
//    
//    return @"default";
    
    return self.uniqueName;
}

+(NSArray*)parseFullGroupName:(NSString*)fullName
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

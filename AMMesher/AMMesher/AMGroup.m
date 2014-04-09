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

-(id)initWithName:(NSString*)name domain:(NSString*)domain  location:(NSString*)location;
{
    if (self = [super init])
    {
        self.isLeaf = NO;
        self.children = [[NSMutableArray alloc] init];
        self.parent = nil;
        self.nodeName = name;
        
        self.fullname = [NSString stringWithFormat:@"%@@%@.%@", name, domain, location];
    }
    
    return self;
}

-(void)updateGroup:(AMGroup*)group
{
    if(![group.fullname isEqualToString:self.fullname])
    {
        return;
    }
    
    self.description = group.description;
    self.ip = group.ip;
    self.port = group.port;
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

//
//  AMUser.m
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUser.h"

@implementation AMUser

-(id)initWithName:(NSString*)name
{
    if (self = [super initWithName:name isGroup:NO])
    {
        
    }
    
    return self;
}

-(BOOL)isEqualToUser:(AMUser*)group differentFields:(NSMutableArray*)fields
{
    [AMUser compareField:self withGroup:group withFiledName:@"name" differentFields:fields];
    [AMUser compareField:self withGroup:group withFiledName:@"groupName" differentFields:fields];
    [AMUser compareField:self withGroup:group withFiledName:@"domain" differentFields:fields];
    [AMUser compareField:self withGroup:group withFiledName:@"description" differentFields:fields];
    [AMUser compareField:self withGroup:group withFiledName:@"status" differentFields:fields];
    [AMUser compareField:self withGroup:group withFiledName:@"foafUrl" differentFields:fields];
    [AMUser compareField:self withGroup:group withFiledName:@"foafUrl" differentFields:fields];

    
    return [fields count] == 0;
}


@end

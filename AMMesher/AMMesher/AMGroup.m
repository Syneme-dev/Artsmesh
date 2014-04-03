//
//  AMGroup.m
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMGroup.h"

@implementation AMGroup

-(id)initWithName:(NSString*)name
{
    if (self = [super initWithName:name isGroup:YES])
    {
        
    }
    
    return self;
}




-(BOOL)isEqualToGroup:(AMGroup*)group differentFields:(NSMutableArray*)fields
{
    [AMGroup compareField:self withGroup:group withFiledName:@"name" differentFields:fields];
    [AMGroup compareField:self withGroup:group withFiledName:@"domain" differentFields:fields];
    [AMGroup compareField:self withGroup:group withFiledName:@"description" differentFields:fields];
    [AMGroup compareField:self withGroup:group withFiledName:@"m2mIp" differentFields:fields];
    [AMGroup compareField:self withGroup:group withFiledName:@"m2mPort" differentFields:fields];
    [AMGroup compareField:self withGroup:group withFiledName:@"foafUrl" differentFields:fields];
    
    return [fields count] == 0;
}

@end

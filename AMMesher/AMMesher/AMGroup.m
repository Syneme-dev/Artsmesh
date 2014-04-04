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


-(AMGroup*)copyWithoutUsers
{
    AMGroup* newGroup = [[AMGroup alloc] init];
    newGroup.name = [self.name copy];
    newGroup.domain = [self.domain copy];
    newGroup.description = [self.description copy];
    newGroup.m2mIp = [self.m2mIp copy];
    newGroup.m2mPort = [self.m2mPort copy];
    newGroup.foafUrl = [self.foafUrl copy];
    
    return newGroup;
}


-(BOOL)isEqualToGroup:(AMGroup*)group differentFields:(NSMutableDictionary*)fieldsWithNewVal
{
    [AMGroup compareField:self withGroup:group withFiledName:@"name" differentFields:fieldsWithNewVal];
    [AMGroup compareField:self withGroup:group withFiledName:@"domain" differentFields:fieldsWithNewVal];
    [AMGroup compareField:self withGroup:group withFiledName:@"description" differentFields:fieldsWithNewVal];
    [AMGroup compareField:self withGroup:group withFiledName:@"m2mIp" differentFields:fieldsWithNewVal];
    [AMGroup compareField:self withGroup:group withFiledName:@"m2mPort" differentFields:fieldsWithNewVal];
    [AMGroup compareField:self withGroup:group withFiledName:@"foafUrl" differentFields:fieldsWithNewVal];
    
    return [fieldsWithNewVal count] == 0;
}

-(NSDictionary*)fieldsAndValue
{
    NSMutableDictionary* fieldsAndValueDic = [[NSMutableDictionary alloc]init];
    
    NSString* val = [self valueForKey:@"name"];
    if (val != nil)
    {
        [fieldsAndValueDic setObject:val forKey:@"name"];
    }

    val = [self valueForKey:@"domain"];
    if (val != nil)
    {
        [fieldsAndValueDic setObject:val forKey:@"domain"];
    }
    
    val = [self valueForKey:@"description"];
    if (val != nil)
    {
        [fieldsAndValueDic setObject:val forKey:@"description"];
    }
    
    val = [self valueForKey:@"m2mIp"];
    if (val != nil)
    {
        [fieldsAndValueDic setObject:val forKey:@"m2mIp"];
    }
    
    val = [self valueForKey:@"m2mPort"];
    if (val != nil)
    {
        [fieldsAndValueDic setObject:val forKey:@"m2mPort"];
    }
    
    val = [self valueForKey:@"foafUrl"];
    if (val != nil)
    {
        [fieldsAndValueDic setObject:val forKey:@"foafUrl"];
    }
    
    return fieldsAndValueDic;
}


@end

//
//  AMUser.m
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUser.h"

@implementation AMUser

-(id)initWithName:(NSString*)name domain:(NSString *)domain
{
    if (self = [super initWithName:name isGroup:NO])
    {
        self.fullname = [NSString stringWithFormat:@"%@@%@", name, domain];
        self.domain = domain;
    }
    
    return self;
}

-(id)initWithFullName:(NSString*)fullname
{
    NSArray* nameAndDomain = [fullname componentsSeparatedByString:@"@"];
    if ([nameAndDomain count] < 1)
    {
        return nil;
    }
    
    NSString* name = [nameAndDomain objectAtIndex:0];
    NSString* domain = nil;
    if ([nameAndDomain count] == 2)
    {
        domain = [nameAndDomain objectAtIndex:1];
    }
    
    if (self = [super initWithName:name isGroup:NO])
    {
        self.domain = domain;
        self.fullname = fullname;
    }
    
    return self;
}

//-(BOOL)isEqualToUser:(AMUser*)group differentFields:(NSMutableDictionary*)fieldsWithNewVal;
//{
//    [AMUser compareField:self withGroup:group withFiledName:@"name" differentFields:fieldsWithNewVal];
//    [AMUser compareField:self withGroup:group withFiledName:@"groupName" differentFields:fieldsWithNewVal];
//    [AMUser compareField:self withGroup:group withFiledName:@"domain" differentFields:fieldsWithNewVal];
//    [AMUser compareField:self withGroup:group withFiledName:@"description" differentFields:fieldsWithNewVal];
//    [AMUser compareField:self withGroup:group withFiledName:@"status" differentFields:fieldsWithNewVal];
//    [AMUser compareField:self withGroup:group withFiledName:@"ip" differentFields:fieldsWithNewVal];
//    [AMUser compareField:self withGroup:group withFiledName:@"foafUrl" differentFields:fieldsWithNewVal];
//
//    
//    return [fieldsWithNewVal count] == 0;
//}
//
//-(NSDictionary*)fieldsAndValue
//{
//    NSMutableDictionary* fieldsAndValueDic = [[NSMutableDictionary alloc]init];
//    
//    NSString* val = [self valueForKey:@"name"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"name"];
//    }
//    
//    val = [self valueForKey:@"groupName"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"groupName"];
//    }
//    
//    val = [self valueForKey:@"domain"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"domain"];
//    }
//    
//    val = [self valueForKey:@"description"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"description"];
//    }
//    
//    val = [self valueForKey:@"status"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"status"];
//    }
//    
//    val = [self valueForKey:@"foafUrl"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"foafUrl"];
//    }
//    
//    val = [self valueForKey:@"ip"];
//    if (val != nil)
//    {
//        [fieldsAndValueDic setObject:val forKey:@"ip"];
//    }
//    
//    return fieldsAndValueDic;
//}
//
//-(AMUser*)copyUser
//{
//    AMUser* newUser = [[AMUser alloc] initWithName:self.name];
//    newUser.groupName = self.groupName;
//    newUser.domain = self.domain;
//    newUser.description = self.description;
//    newUser.status = self.status;
//    newUser.foafUrl = self.foafUrl;
//    newUser.ip  = self.ip;
//    
//    return newUser;
//}


@end

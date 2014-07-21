//
//  AMStatusNet.m
//  AMStatusNet
//
//  Created by Wei Wang on 7/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStatusNet.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMStatusNet()

@property NSString* userName;
@property NSString* password;

@end

@implementation AMStatusNet

+(AMStatusNet*)shareInstance
{
    static AMStatusNet* sharedStatusNet = nil;
    @synchronized(self){
        if (sharedStatusNet == nil){
            sharedStatusNet = [[self alloc] privateInit];
        }
    }
    return sharedStatusNet;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

-(AMStatusNet*)privateInit
{
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    self.homePage = [defaults stringForKey:Preference_Key_StatusNet_URL];
    self.userName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    self.password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    
    return nil;
}

-(void)loadGroups
{
    //synchronize get all static user and groups
    //then post a notification;
    if (self.homePage == nil || [self.homePage isEqualToString:@""])
    {
        return;
    }
    
    if (self.userName == nil || [self.userName isEqualToString:@""])
    {
        return;
    }
    
    if (self.password == nil || [self.password isEqualToString:@""])
    {
        return;
    }
    
    return;
    
}


-(BOOL)quickRegisterAccount:(NSString*)account password:(NSString*)password
{
    return YES;
}

-(BOOL)registerAccount:(AMStaticUser*)user password:(NSString*)password
{
    return YES;
}

-(BOOL)loginAccount:(NSString*)account password:(NSString*)password
{
    return YES;
}

-(BOOL)followGroup:(NSString*)groupName
{
    return YES;
}

-(BOOL)createGroup:(NSString*)groupName
{
    return YES;
}

-(BOOL)postMessageToStatusNet:(NSString*)status
{
    return YES;
}


@end

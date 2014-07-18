//
//  AMCoreData.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMCoreData.h"

@implementation AMCoreData

+(AMCoreData*)shareInstance
{
    static AMCoreData* sharedCoreData = nil;
    @synchronized(self){
        if (sharedCoreData == nil){
            sharedCoreData = [[self alloc] privateInit];
        }
    }
    return sharedCoreData;
}

- (instancetype)privateInit
{
    return [super init];
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}


-(void)broadcastChanges:(NSString*)notificationName
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotification* notification = [NSNotification notificationWithName:notificationName object:self userInfo:nil];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    });
}

@end

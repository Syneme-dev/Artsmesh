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
    //TODO:Test code
//    NSMutableArray* sgArray = [[NSMutableArray alloc] init];
//    
//    AMStaticGroup* sg1 = [[AMStaticGroup alloc] init];
//    sg1.g_id = @"test_group1";
//    sg1.nickname = @"test_group1";
//    
//    NSMutableArray* suArray1 = [[NSMutableArray alloc] init];
//    
//    AMStaticUser* su1 = [[AMStaticUser alloc] init];
//    su1.u_id = @"test_user1";
//    su1.name = @"test_user1";
//    [suArray1 addObject:su1];
//    
//    AMStaticUser* su2 = [[AMStaticUser alloc] init];
//    su2.u_id = @"test_user2";
//    su2.name = @"test_user2";
//    [suArray1 addObject:su2];
//    
//    sg1.users = suArray1;
//    [sgArray addObject:sg1];
//    
//    
//    AMStaticGroup* sg2 = [[AMStaticGroup alloc] init];
//    sg2.g_id = @"test_group2";
//    sg2.nickname = @"test_group2";
//    
//    NSMutableArray* suArray2 = [[NSMutableArray alloc] init];
//    
//    AMStaticUser* su3 = [[AMStaticUser alloc] init];
//    su3.u_id = @"test_user3";
//    su3.name = @"test_user3";
//    [suArray2 addObject:su3];
//    
//    AMStaticUser* su4 = [[AMStaticUser alloc] init];
//    su4.u_id = @"test_user4";
//    su4.name = @"test_user4";
//    [suArray2 addObject:su4];
//    
//    sg2.users = suArray2;
//    [sgArray addObject:sg2];
//    
//    self.staticGroups = sgArray;
//
//    //Test Code finished
    
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

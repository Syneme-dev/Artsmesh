//
//  AMRestHelper.m
//  DemoUI
//
//  Created by xujian on 7/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMRestHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import <AMNotificationManager/AMNotificationManager.h>
#import "AMPreferenceManager/AMPreferenceManager.h"
@implementation AMRestHelper

//-(NSDictionary*)getUserInfo:(NSString*)nickname{
//    __block NSDictionary *userInfo=[[NSDictionary alloc]init];
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    [manager GET:@"http://artsmesh.io/api/users/show/xujian.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
//        userInfo=responseObject;
////        userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
////                   @"wangwei", @"UserName", nil];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//    return userInfo;
//}

//Note:
//Sample as this:http://artsmesh.io/api/users/show/xujian.json
+(NSString*)getMyAccountInfoUrl{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *statusNetURL= [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSString * myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    NSString *url=[NSString stringWithFormat:@"%@/api/users/show/%@.json",statusNetURL,myUserName];
    return url;
}

@end

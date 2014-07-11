//
//  AMStatusNetModule.h
//  AMStatusNetModule
//
//  Created by Wei Wang on 5/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMStatusNetModule : NSObject

-(BOOL)postMessageToStatusNet:(NSString*)status
                   urlAddress:(NSString*)url
                 withUserName:(NSString*)username
                 withPassword:(NSString*)password;

-(void)getGroupsOnStatusNet:(NSString*)url
            completionBlock:(void(^)(NSData*, NSError*))completionBlock;


@end

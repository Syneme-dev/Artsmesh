//
//  AMUserGroupCtrlSrvDelegate.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupCtrlSrvDelegate.h"
#import "AMUserGroupServer.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

@implementation AMUserGroupCtrlSrvDelegate
{
    AMUserGroupServer* server;
}

-(id)initWithDataSource:(AMUserGroupServer*)s
{
    if(self = [super init])
    {
        server = s;
    }
    
    return self;
}

// /Ctrl/Register?username=kkk&dataport=12345&ctrlport=54321
// /Ctrl/Unregister?username=uuu

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlStr);
	
	NSURL* url = [NSURL URLWithString:urlStr];
    if(url == nil)
    {
        return;
    }
    
    NSString* requestPath = url.path;
    NSString* query = url.query;

    NSArray* pathArray = [requestPath componentsSeparatedByString:@"/"];
    NSArray* keyvalues = [query componentsSeparatedByString:@"&"];
    
    if([pathArray count] < 2)
    {
        return;
    }
    
    if(![pathArray[0] isEqualToString:@"Ctrl"])
    {
        return;
    }
    
    if([pathArray[1] isEqualToString:@"Register"])
    {
        if([self registerUser:keyvalues])
        {
            [server sendCtrlData:[@"ok" dataUsingEncoding:NSUTF8StringEncoding] toAddress:address];
        }
        else
        {
            [server sendCtrlData:[@"failed" dataUsingEncoding:NSUTF8StringEncoding] toAddress:address];
        }
        
        return;
    }
    
    if([pathArray[1] isEqualToString:@"Unregister"])
    {
        [self unregisterUser:keyvalues];
    }
    
    if([pathArray[1] isEqualToString:@"GetGroupList"])
    {
        NSData* data = [self getGroups];
        [server sendCtrlData: data toAddress:address];
    }
        
}

-(NSData*)getGroups
{
    NSMutableString* response = [[NSMutableString alloc] init];
    
    int index = 0;
    for(NSString* key in server.groups)
    {
        if (index > 0)
        {
             [response appendString:@","];
        }
        
        NSString* gname = [NSString stringWithFormat:@"groupname=%@", key ];
        NSDictionary* group = [server.groups objectForKey:key];
        NSString* gDesc = [group objectForKey:@"description"];
        NSString* gDescStr = [NSString stringWithFormat:@"description=%@", gDesc];
        
        [response appendString:gname];
        [response appendString:@"&"];
        [response appendString:gDescStr];
    }
    
    return [response dataUsingEncoding:NSUTF8StringEncoding];

}

-(void)unregisterUser:(NSArray*)keyVals
{
    NSMutableDictionary* userMeta = [[NSMutableDictionary alloc] init];
    
    for(NSString* kv in keyVals)
    {
        NSArray *pairComponents = [kv componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [userMeta setObject:value forKey:key];
    }
    
    NSString* userName = [userMeta objectForKey:@"username"];
    if (userName == nil)
    {
        return;
    }

    [server.users removeObjectForKey:userName];
    
    return;
}


-(BOOL)registerUser:(NSArray*)keyVals
{
    NSMutableDictionary* userMeta = [[NSMutableDictionary alloc] init];
    
    for(NSString* kv in keyVals)
    {
        NSArray *pairComponents = [kv componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [userMeta setObject:value forKey:key];
    }
    
    NSString* userName = [userMeta objectForKey:@"username"];
    if (userName == nil)
    {
        return NO;
    }
    
    NSMutableDictionary* exitUser = [server.users objectForKey:userName];
    if(exitUser != nil)
    {
        return NO;
    }
    
    [userMeta setObject:[NSData data] forKey:@"lastActiveTime"];
    
    [server.users setObject:userMeta forKey:userName];
    return YES;
}

@end

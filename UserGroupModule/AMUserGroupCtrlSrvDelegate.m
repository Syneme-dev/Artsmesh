//
//  AMUserGroupCtrlSrvDelegate.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupCtrlSrvDelegate.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMNetworkUtils/JSONKit.h"

@implementation AMUserGroupCtrlSrvDelegate

-(id)initWithDataModel:(AMUserGroupModel*) m
            withServer:(AMUserGroupServer*) s
{
    if(self = [super init])
    {
        self.model = m;
        self.server = s;
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
    
    if([pathArray count] < 3)
    {
        return;
    }
    
    if(![pathArray[1] isEqualToString:@"Ctrl"])
    {
        return;
    }
    
    if([pathArray[2] isEqualToString:@"Register"])
    {
        if([self registerUser:keyvalues])
        {
            [self.server sendCtrlData:[@"/Register?return=ok" dataUsingEncoding:NSUTF8StringEncoding] toAddress:address];
        }
        else
        {
            [self.server sendCtrlData:[@"/Register?return=failed" dataUsingEncoding:NSUTF8StringEncoding] toAddress:address];
        }
        
        return;
    }
    
    if([pathArray[2] isEqualToString:@"Unregister"])
    {
        [self unregisterUser:keyvalues];
        return;
    }
    
    if([pathArray[2] isEqualToString:@"GetGroups"])
    {
        NSData* data = [self getGroups];
        [self.server sendCtrlData: data toAddress:address];
        
        return;
    }
        
}

-(NSData*)getGroups
{
    NSMutableString* response = [[NSMutableString alloc] init];
    
    [response appendString:@"/Ctrl/GetGroups?value="];
    
    int index = 0;
    for(NSString* key in self.model.groups)
    {
        if (index > 0)
        {
             [response appendString:@","];
        }
        
        NSString* gname = [NSString stringWithFormat:@"groupname=%@", key ];
        NSDictionary* group = [self.model.groups objectForKey:key];
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

    [self.model.users removeObjectForKey:userName];
    
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
    
    NSMutableDictionary* exitUser = [self.model.users objectForKey:userName];
    if(exitUser != nil)
    {
        return NO;
    }
    
    [userMeta setObject:[NSData data] forKey:@"lastActiveTime"];
    
    [self.model.users setObject:userMeta forKey:userName];
    return YES;
}

@end

//
//  MainViewController.m
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "MainViewController.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMNetworkUtils/JSONKit.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMOutlineUserNode.h"

#import "AMUserGroupServer.h"
#import "AMUserGroupClient.h"
#import "AMUserGroupModel.h"
#include <sys/socket.h>
#include <netinet/in.h>


#define ROOT_KEY @"/Groups"
#define DEFAULT_GROUP @"Artsmesh"

@implementation MainViewController
{
    AMUserGroupModel* _model;
    AMUserGroupServer* _server;
    AMUserGroupClient* _client;
    
    //dispatch_queue_t _mySerialModeOpQueue;
    
    NSString* _myName;
    NSString* _myGroup;
    int _myPort;
    
    NSTimer *_heartbeatTimer;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _model = [[AMUserGroupModel alloc]init];
        _server = [[AMUserGroupServer alloc] init];
        _client = [[AMUserGroupClient alloc] init];
        
        //_mySerialModeOpQueue = dispatch_queue_create("artsmesh.usergroup.model.queue", NULL);
        
        _client.delegate = self;
        _server.delegate = self;
        
        [_model.myself setObject:@(4001) forKey:@"port"];
        [_model.myself setObject:@"Artsmesh" forKey:@"groupname"];
        
        [_server startServer];
        
        if(![self findMesherService])
        {
            NSMutableDictionary* group1 = [[NSMutableDictionary alloc]init];
            [group1 setObject:@"Artsmesh" forKey:@"groupname"];
            [group1 setObject:@"This is default group" forKey:@"description"];
            
            NSMutableDictionary* group2 = [[NSMutableDictionary alloc]init];
            [group2 setObject:@"Performance" forKey:@"groupname"];
            [group2 setObject:@"This is a created group" forKey:@"description"];
            
            [_model.groups setObject:group1 forKey:@"Artsmesh"];
            [_model.groups setObject:group2 forKey:@"Performance"];
        }
        
        [_client getGroups:_model.serverAddr];
        [_client getUsers: _model.serverAddr];
        
        self.outlineUserNodes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(BOOL)findMesherService
{
    //get the server's ip and port and set it to model
    _model.serverAddr = [AMNetworkUtils addressFromIpAndPort:@"127.0.0.1" port:7001];
    
    return NO;
}



-(void)StopEverything
{
}

- (IBAction)setUserName:(id)sender
{
    if(_myName == nil)
    {
        [_model.myself setObject:@"test" forKey:@"username"];
        [_client RegsterUser:_model.serverAddr name:@"test" withPort:4001];
    }
    else
    {
        
    }
}

- (IBAction)joinGroup:(id)sender
{
    
}


-(void)unregisterUser
{
    [_heartbeatTimer invalidate];
    [_client UnregisterUser:_model.serverAddr name: [_model.myself objectForKey:@"username"]];
}


-(void)sendEveryOneMyself
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        for(NSString* key in _model.users)
        {
            NSDictionary* user = [_model.users objectForKey:key];
            
            NSString* ip = [user objectForKey:@"ip"];
            int port = [[user objectForKey:@"port"] intValue];
            
            if(ip != nil && port >=0)
            {
                NSData* address = [AMNetworkUtils addressFromIpAndPort:ip port:port];
                NSString* userInfo = [_model.myself JSONString];
                
                [_client sendUserInfo:address userInfo:userInfo];
            }
        }
    });
}



- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[NSDictionary class]]) {
        return YES;
    }else {
        return NO;
    }
}


#pragma mark -
#pragma mark AMUserGroupServerDelegate


-(void)GetGroupsHandler:(GCDAsyncUdpSocket*)sock
            fromAddress:(NSData *)address
            withRequest:(NSString*)request
{
    NSString* resKey = [NSString stringWithFormat:@"%@/Results",request];
    NSMutableDictionary* retDic = [[NSMutableDictionary alloc] init];
    [retDic setObject:_model.groups forKey:resKey];
    
    NSString* retString = [retDic JSONString];
    NSLog(@"group list json is:%@", retString);
    
    [sock sendData:  [retString dataUsingEncoding:NSUTF8StringEncoding]
         toAddress:address withTimeout:-1 tag:0];
}


-(void)GetUsersHandler:(GCDAsyncUdpSocket*)sock
           fromAddress:(NSData *)address
           withRequest:(NSString*)request
{
    NSString* resKey = [NSString stringWithFormat:@"%@/Results",request];
    NSMutableDictionary* retDic = [[NSMutableDictionary alloc] init];
    [retDic setObject:_model.users forKey:resKey];
    
    NSString* retString = [retDic JSONString];
    NSLog(@"user list json is:%@", retString);
    
    [sock sendData:  [retString dataUsingEncoding:NSUTF8StringEncoding]
         toAddress:address withTimeout:-1 tag:0];

}


-(void)RegisterUserHandler:(GCDAsyncUdpSocket*)sock
               fromAddress:(NSData *)address
               withRequest:(NSString*)request
                  username:(NSString*)name
                   usePort:(int)port
{
    NSString* resKey = [NSString stringWithFormat:@"%@/Results",request];
    NSMutableDictionary* retDic = [[NSMutableDictionary alloc] init];
    
    id exist = [_model.users objectForKey:name];
    if(exist != nil)
    {
        [retDic setObject:@"already used" forKey:resKey];
    }
    else
    {
        NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
        [user setObject:@"username" forKey:name];
        [user setObject:@"port" forKey:@(port)];
        [user setObject:[GCDAsyncUdpSocket hostFromAddress:address] forKey:@"ip"];
        
        [_model.users setObject:user forKey:name];
        
        [retDic setObject:@"ok" forKey:resKey];
    }
    
    NSString* retString = [retDic JSONString];
    NSLog(@"user list json is:%@", retString);
    
    [sock sendData:  [retString dataUsingEncoding:NSUTF8StringEncoding]
         toAddress:address withTimeout:-1 tag:0];
}


-(void)UnregisterUserHandler:(GCDAsyncUdpSocket*)sock
                 fromAddress:(NSData *)address
                 withRequest:(NSString*)request
                    username:(NSString*)name
{
    id exist = [_model.users objectForKey:name];
    if(exist == nil)
    {
        NSLog(@"no user to remove");
    }
    else
    {
        [_model.users removeObjectForKey:name];
        NSLog(@"remove user : %@\n", name);
    }
}


#pragma mark -
#pragma mark AMUserGroupClientDelegate
-(void)didGetGroups:(id)groupsObject
{
    if(![groupsObject isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSDictionary* groups = groupsObject;
    
    for(NSString* key in groups)
    {
        NSString* groupname = key;
        NSDictionary* groupObj = [groups objectForKey:key];
        
        [_model.groups setObject:groupObj forKey:groupname];
    }
}

-(void)didGetUsers:(id)userObject
{
    if(![userObject isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSDictionary* users = userObject;
    
    for(NSString* key in users)
    {
        NSString* groupname = key;
        NSDictionary* groupObj = [users objectForKey:key];
        
        [_model.users setObject:groupObj forKey:groupname];
    }

}

-(void)didRegsterUser:(id)res
{
    if ([res isEqualToString:@"ok"])
    {
        NSLog(@"Register ok");
        
        [self sendEveryOneMyself];
        _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0
                                                          target:self
                                                        selector:@selector(sendEveryOneMyself)
                                                        userInfo:nil
                                                         repeats:YES];
        
    }
}



@end

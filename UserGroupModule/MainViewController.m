//
//  MainViewController.m
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "MainViewController.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMUser.h"

#import "AMUserGroupServer.h"
#import "AMUserGroupClient.h"
#import "AMUserGroupModel.h"
#import "AMUserGroupDataDeletage.h"
#import "AMUserGroupCtrlSrvDelegate.h"


#define ROOT_KEY @"/Groups"
#define DEFAULT_GROUP @"Artsmesh"

@implementation MainViewController
{
    AMUserGroupModel* _model;
    AMUserGroupServer* _server;
    AMUserGroupClient* _client;
    AMUserGroupCtrlSrvDelegate* _ctrlRequestDelegate;
    AMUserGroupDataDeletage* _dataComingDelegate;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _model = [[AMUserGroupModel alloc]init];
        _server = [[AMUserGroupServer alloc] init];
        _client = [[AMUserGroupClient alloc] init];
        
        _ctrlRequestDelegate = [[AMUserGroupCtrlSrvDelegate alloc]
                                initWithDataModel:_model withServer:_server];
        _dataComingDelegate = [[AMUserGroupDataDeletage alloc]
                               initWithDataModel:_model withServer:_server];
        
        [_server createSocket:_ctrlRequestDelegate
             withDataDeletage:_dataComingDelegate];
        
        _client.delegate = self;
    }
    
    if([self findMesherService])
    {
        [_client getGroups:_model.serverAddr];
        [_client getUsers: _model.serverAddr];
    }
    
    return self;
}

-(BOOL)findMesherService
{
    //get the server's ip and port and set it to model
    return YES;
}

-(void)StopEverything
{
}

- (IBAction)setUserName:(id)sender
{
    
}

- (IBAction)joinGroup:(id)sender
{
    
}









@end

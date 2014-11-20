//
//  AMSyphonManager.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import "AMSyphonManager.h"


@implementation AMSyphonManager
- (id) initWithClientCount : (int) cnt
{
    if(self = [super init]){
        amSyphonClients = [[NSMutableArray alloc] initWithCapacity:cnt];
        for(int i = 0; i < cnt; i++){
            
             NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.videoFramework"];
            AMSyphonViewController* amSyphonCtrl =  [[AMSyphonViewController alloc]
                                                     initWithNibName:@"AMSyphonViewController" bundle:myBundle];
            [amSyphonClients addObject:amSyphonCtrl];
        }
    }
    
    amSyphonRouter = [[AMSyphonViewRouterController alloc] initWithNibName:@"AMSyphonViewRouterController" bundle:nil];

    
    return self;
}

- (AMSyphonView*) getRouterView
{
    return amSyphonRouter.view;
}

- (AMSyphonView*) getViewByIndex : (int) index
{
    if(index >= [amSyphonClients count]){
        return nil;
    }
    AMSyphonViewController* amSyphonCtrl = [amSyphonClients objectAtIndex:index];
    return amSyphonCtrl.view;
}

- (BOOL) startRouter:(NSString *)err
{
    [amSyphonRouter startRouter:err];
    return YES;
}

- (BOOL) stopRouter:(NSString *)err
{
    [amSyphonRouter stopRouter:err];
    
    return YES;
}

@end

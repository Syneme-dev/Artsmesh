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
            AMSyphonViewController* amSyphonCtrl =  [[AMSyphonViewController alloc]
                                                     initWithNibName:@"AMSyphonViewController" bundle:nil];
            [amSyphonClients addObject:amSyphonCtrl];
        }
    }
    
    return self;
}

- (AMSyphonView*) getViewByIndex : (int) index
{
    if(index >= [amSyphonClients count]){
        return nil;
    }
    AMSyphonViewController* amSyphonCtrl = [amSyphonClients objectAtIndex:index];
    return amSyphonCtrl.view;
}

@end

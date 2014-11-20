//
//  AMSyphonManager.h
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMSyphonViewRouterController.h"
#import "AMSyphonViewController.h"
#import "AMSyphonView.h"

@interface AMSyphonManager : NSObject
{
    int                             amClientCnt;
    NSMutableArray*                 amSyphonClients;
    AMSyphonViewRouterController*   amSyphonRouter;
}
- (id) initWithClientCount : (int) cnt;
- (AMSyphonView*)   getViewByIndex : (int) index;
- (AMSyphonView*)   getRouterView;
- (BOOL)            selectClientToRouter: (int)  index;
- (BOOL)            startRouter:(NSString*) err;
- (BOOL)            stopRouter:(NSString*) err;
@end

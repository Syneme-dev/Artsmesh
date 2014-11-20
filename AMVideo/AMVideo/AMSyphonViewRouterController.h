//
//  AMSyphonViewRouterController.h
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Syphon/Syphon.h>

@interface AMSyphonViewRouterController : NSViewController
{
    NSArray*        servers;
    SyphonClient*   syClient;
    SyphonServer*   syServer;

    NSTimeInterval fpsStart;
    NSUInteger fpsCount;
    NSUInteger FPS;
    NSUInteger frameWidth;
    NSUInteger frameHeight;
    
}


@end

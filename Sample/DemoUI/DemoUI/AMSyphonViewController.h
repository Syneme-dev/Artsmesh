//
//  AMSyphonViewController.h
//  SyphonDemo
//
//  Created by WhiskyZed on 11/16/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Syphon/Syphon.h>

@interface AMSyphonViewController : NSViewController

@property NSString* currentServerName;
-(void) unselected;
-(void) selectNewSyphonServer:(NSString*) serverName;
-(NSString*) selectedSyphonServerName;
-(void)updateServerList;
-(void)stop;

@end

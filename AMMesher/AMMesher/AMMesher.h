//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MesherBrowserDelegate
- (void)updateServerList;
@end

@class ServerBrowserDelegate;
@interface AMMesher : NSObject<NSNetServiceBrowserDelegate>

@property NSMutableArray* meshers;
@property id<MesherBrowserDelegate>  delegate;

//LAN
-(BOOL)browseLocalMesher;
-(void)stopBrowser;
-(void)joinLocalMesher:(NSString*) mesherName;

-(void)createMesher;
-(void)publishLocalMesher;

//TODO
//communicate with WLAN mesher

@end

//
//  AMWorldMap.h
//  DemoUI
//
//  Created by Brad Phillips on 9/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMWorldMap : NSObject

@property (nonatomic) NSInteger current_resolution;

@property (nonatomic) NSMutableArray *allMapPixels;
@property (nonatomic) NSMutableArray *markedPixels;
@property (nonatomic) NSInteger numMapTiles;

@property (nonatomic, assign) NSInteger mapHeight;
@property (nonatomic, assign) NSInteger mapWidth;

@property (nonatomic, assign) NSInteger tileWidth;
@property (nonatomic, assign) NSInteger tileHeight;

@property (nonatomic, assign) NSInteger numGroups;

- (id)init;

@end

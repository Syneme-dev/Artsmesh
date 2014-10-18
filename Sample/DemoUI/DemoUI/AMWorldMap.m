//
//  AMWorldMap.m
//  DemoUI
//
//  Created by Brad Phillips on 9/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMWorldMap.h"

@implementation AMWorldMap

@synthesize current_resolution = _current_resolution;
@synthesize allMapPixels = _allMapPixels;
@synthesize markedPixels = _markedPixels;
@synthesize tileWidth = _tileWidth;
@synthesize tileHeight = _tileHeight;
@synthesize numGroups = _numGroups;

NSString *mapLine1 =  @"..........................................................................";
NSString *mapLine2 =  @"..................XXX....XXXX....................X.....XX..................";
NSString *mapLine3 =  @"...............XXXXXXXXXXXXXXXX...............XXX...XXXXXX.................";
NSString *mapLine4 =  @"................XXXXXXXXXXXXXX................XXXXXXXXXXXXXXX..XX..........";
NSString *mapLine5 =  @"................XXX.XXXXXXXXX..........XXX....XXXXXXXXXXXXXXXXXXXXXXXXX....";
NSString *mapLine6 =  @"......................XXXXXXX.........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.";
NSString *mapLine7 =  @"...........XX...XXXX...XXXXXX........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..";
NSString *mapLine8 =  @"..XXX......XXXXX.XXXX..XXXXXX.....XX.XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX....";
NSString *mapLine9 =  @".XXXXXXXXXXXXXXXXX.XXX.XXXX.XX...XX..XXXXXXXXXXXXXXXXXXXXXXXXXX....XX......";
NSString *mapLine10 = @"XXXXXXXXXXXXXXXXX..XXX..XX...XX...XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..XX.......";
NSString *mapLine11 = @".XXXXXXXXXXXXXXX..XXXX...X........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...........";
NSString *mapLine12 = @"XXXXXXXXXXXXXXXX..XXXX..........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX..X.........";
NSString *mapLine13 = @".XX....XXXXXXXXXXXXXXXX........XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX...X.........";
NSString *mapLine14 = @"........XXXXXXXXXXXXXXXX........XX...XXXXXXXXXXXXXXXXXXXXXXXX...XX.........";
NSString *mapLine15 = @".........XXXXXXXXXXXX..............XX....XXXXXXXXXXXXXXXXXX.X..XX..........";
NSString *mapLine16 = @".........XXXXXXXXXXXX...........XXXXXX.X.XXXXXXXXXXXXXXXXXXX...............";
NSString *mapLine17 = @".........XXXXXXXXXXX............XXXXXXXXXXXXXXXXXXXXXXXXXXXX...............";
NSString *mapLine18 = @".........XXXXXXXXXX............XXXXXXXXXX.XXXX..XXXXXXXXXXX................";
NSString *mapLine19 = @"..........XXXXXXXXX...........XXXXXXXXXXXX.XXX...XXX.XXXX...X..............";
NSString *mapLine20 = @"..........XXXXXX.XX............XXXXXXXXXXXX......XX...XXX...X..............";
NSString *mapLine21 = @"...........XXXX...X............XXXXXXXXXXXXXXX........X....................";
NSString *mapLine22 = @".............XXX..X.............XXXXXXXXXXXXX.........XX...X...............";
NSString *mapLine23 = @"..............XXX..X.................XXXXXXX...........X..XX.X.............";
NSString *mapLine24 = @"................XXXXXX...............XXXXXX............XX.X...XX...........";
NSString *mapLine25 = @"..................XXXXXX.............XXXXXXX.X..........X......XX..........";
NSString *mapLine26 = @"..................XXXXXXX............XXXXXXXX...............XXXX...........";
NSString *mapLine27 = @"..................XXXXXXXXX...........XXXXX.XX............XXXXXXX..........";
NSString *mapLine28 = @"..................XXXXXXXXX...........XXXX..X............XXXXXXXXX.........";
NSString *mapLine29 = @"..................XXXXXXXXX...........XXXX................XXXXXXXX.........";
NSString *mapLine30 = @"....................XXXXXX.............XX.................XXXXXXXX.........";
NSString *mapLine31 = @"....................XXXXX......................................XX.....X....";
NSString *mapLine32 = @"....................XXXX.............................................XX....";
NSString *mapLine33 = @"...................XXXXX............................................XX.....";
NSString *mapLine34 = @"...................XXXX....................................................";
NSString *mapLine35 = @"...................XXX.....................................................";
NSString *mapLine36 = @"...................XX......................................................";
NSString *mapLine37 = @"...................XX......................................................";
NSString *mapLine38 = @"...................XX......................................................";
NSString *mapLine39 = @"....................XX.....................................................";
NSString *mapLine40 = @"...........................................................................";


- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
    
}

- (void)setup {
    _current_resolution = 0;
    
    //NSLog(@"AMLiveMap setup running and current resolution = %li", (long)_current_resolution);
    
    
    if (_current_resolution <= 0) {
        
        self.mapWidth = 75;
        self.mapHeight = 40;
        
        
        self.allMapPixels = [NSMutableArray arrayWithCapacity:(self.mapWidth * self.mapHeight)];
        self.markedPixels = [NSMutableArray array];
        
        [self.allMapPixels addObject:mapLine1];
        [self.allMapPixels addObject:mapLine2];
        [self.allMapPixels addObject:mapLine3];
        [self.allMapPixels addObject:mapLine4];
        [self.allMapPixels addObject:mapLine5];
        [self.allMapPixels addObject:mapLine6];
        [self.allMapPixels addObject:mapLine7];
        [self.allMapPixels addObject:mapLine8];
        [self.allMapPixels addObject:mapLine9];
        [self.allMapPixels addObject:mapLine10];
        [self.allMapPixels addObject:mapLine11];
        [self.allMapPixels addObject:mapLine12];
        [self.allMapPixels addObject:mapLine13];
        [self.allMapPixels addObject:mapLine14];
        [self.allMapPixels addObject:mapLine15];
        [self.allMapPixels addObject:mapLine16];
        [self.allMapPixels addObject:mapLine17];
        [self.allMapPixels addObject:mapLine18];
        [self.allMapPixels addObject:mapLine19];
        [self.allMapPixels addObject:mapLine20];
        [self.allMapPixels addObject:mapLine21];
        [self.allMapPixels addObject:mapLine22];
        [self.allMapPixels addObject:mapLine23];
        [self.allMapPixels addObject:mapLine24];
        [self.allMapPixels addObject:mapLine25];
        [self.allMapPixels addObject:mapLine26];
        [self.allMapPixels addObject:mapLine27];
        [self.allMapPixels addObject:mapLine28];
        [self.allMapPixels addObject:mapLine29];
        [self.allMapPixels addObject:mapLine30];
        [self.allMapPixels addObject:mapLine31];
        [self.allMapPixels addObject:mapLine32];
        [self.allMapPixels addObject:mapLine33];
        [self.allMapPixels addObject:mapLine34];
        [self.allMapPixels addObject:mapLine35];
        [self.allMapPixels addObject:mapLine36];
        [self.allMapPixels addObject:mapLine37];
        [self.allMapPixels addObject:mapLine38];
        [self.allMapPixels addObject:mapLine39];
        [self.allMapPixels addObject:mapLine40];
        
        
        // Set number of map tiles to place
        int numTiles = 0;
        int curTile = 1;
        for (int i = 0; i < self.allMapPixels.count; i++) {
            
            NSString *curString = [self.allMapPixels objectAtIndex:i];
            for (int c = 0; c < curString.length; c++) {
                curTile++;
                
                NSString *curChar = [curString substringWithRange:NSMakeRange(c, 1)];
                if ( [curChar  isEqual: @"X"] ) {
                    numTiles++;
                    [self.markedPixels addObject:[NSNumber numberWithInteger:curTile]];
                }
            }
        }
        self.numMapTiles = numTiles;
    }
    
    _state = overView;
}


@end

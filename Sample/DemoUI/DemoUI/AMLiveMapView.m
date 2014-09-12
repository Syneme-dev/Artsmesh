//
//  AMLiveMapView.m
//  DemoUI
//
//  Created by Brad Phillips on 9/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveMapView.h"
#import "AMWorldMap.h"
#import "AMPixel.h"

@interface AMLiveMapView ()
{
    NSPoint _center;
    CGFloat _radius;
    NSInteger _portIndex;
}

@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) NSArray *ports;

@end


@implementation AMLiveMapView

AMWorldMap *worldMap;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    
    //Construct WorldMap and pixel arrays for assigning buttons to view
    worldMap = [[AMWorldMap alloc] init];
    
    _backgroundColor = [NSColor colorWithCalibratedRed:0.15
                                                 green:0.15
                                                  blue:0.15
                                                 alpha:1.0];
    int numberOfPorts = (int)worldMap.numMapTiles;
    NSMutableArray *allPorts = [NSMutableArray arrayWithCapacity:numberOfPorts];
    
    for (int i = 0; i < numberOfPorts; i++) {
        [allPorts addObject:[[AMPixel alloc] initWithIndex:i]];
    }
    _ports = [allPorts copy];
    _portIndex = -1;
        
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor set];
    NSRectFill(self.bounds);
    
    NSRect rect = NSInsetRect(self.bounds, NSWidth(self.bounds) / 16.0,
                              NSHeight(self.bounds) / 16.0);
    _radius = MIN(NSWidth(rect) / 2.0, NSHeight(rect) / 2.0);
    _center = NSMakePoint(NSMidX(rect), NSMidY(rect));
    
    
    //Draw each port onto the canvas
    
    NSPoint portCenter;
    int portX = 0;
    int portY = 0;
    float portRow = 0;
    int portCol = 0;
    float portW = self.bounds.size.width / (long)worldMap.mapWidth;
    float portH = self.bounds.size.height / (long)worldMap.mapHeight;
    
    portW = self.bounds.size.width / (long)worldMap.mapWidth;
    portH = (((long)worldMap.mapHeight * portW )/(long)worldMap.mapWidth) *1.75;
    
    float xPush = (self.bounds.size.width - (portW * worldMap.mapWidth))/2;
    //float xPush = 0.0;
    
    for (int i = 0; i < self.ports.count; i++) {
        AMPixel *port = self.ports[i];
        int portPixelPos = [[worldMap.markedPixels objectAtIndex:i] integerValue];
        
        if (port.state == AMPixelStateConnected && port.index < port.peerIndex) {
            NSBezierPath *bezierPath = [NSBezierPath bezierPath];
            [bezierPath moveToPoint:[self centerOfPort:port.index]];
            [bezierPath curveToPoint:[self centerOfPort:port.peerIndex]
                       controlPoint1:_center
                       controlPoint2:_center];
            if (port.index == _portIndex) {
                bezierPath.lineWidth = 12.0;
                [[NSColor colorWithRed:0.6 green:1.0 blue:1.0 alpha:0.2] setStroke];
                [bezierPath stroke];
                bezierPath.lineWidth = 2.0;
                [[NSColor lightGrayColor] setStroke];
                [bezierPath stroke];
            } else {
                bezierPath.lineWidth = 2.0;
                [[NSColor grayColor] setStroke];
                [bezierPath stroke];
            }
        }
        
        // Find position of current Tile on the LiveMapView
        
        portRow = (portPixelPos / (float)worldMap.mapWidth);
        if (portRow != (int)portRow) {
            portRow = (int)portRow + 1;
        }
        portCol = portPixelPos % worldMap.mapWidth;
        if (portCol == 0) { portCol = (int)worldMap.mapWidth; }
        portX = ((portW * portCol) - (portW/2)) + xPush;
        portY = (portH * portRow) - (portH/2);
        portCenter = NSMakePoint(portX, portY);
        
        //[port drawWithCenterAt:[self centerOfPort:i]];
        [port drawWithCenterAt:portCenter];
        
    }
    
}

- (NSPoint)centerOfPort:(NSInteger)portIndex
{
    NSAssert(portIndex >= 0 && portIndex < self.ports.count, @"invalid argument");
    
    
    CGFloat radian = portIndex * 2 * M_PI / self.ports.count;
    return NSMakePoint(_radius * cos(radian) + _center.x,
                       _radius * sin(radian) + _center.y);
    
}


- (BOOL)isFlipped{
    return YES;
}


@end

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
#import "AMCoreData/AMCoreData.h"
#import "CoreLocation/CoreLocation.h"

@interface AMLiveMapView ()
{
    NSPoint _center;
    CGFloat _radius;
    NSInteger _portIndex;
}

@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) NSArray *ports;
@property (nonatomic) NSMutableDictionary * localGroupLoc;

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
    _localGroupLoc = [[NSMutableDictionary alloc] initWithCapacity:2];
    
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
    
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;

    // Get/Set location data
    
    NSString *location = @"beijing";
    if (myGroup.location) {
        location = myGroup.location;
    }
    [self getCoordinates:location];
    
    [self markLiveGroupLocation];

}

- (void)drawRect:(NSRect)dirtyRect
{
    NSLog(@"draw rect called..");
    
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
        int portPixelPos = (int)[[worldMap.markedPixels objectAtIndex:i] integerValue];
        
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

- (void)markLiveGroupLocation {

    if ( [_localGroupLoc count] > 0 ) {
    //This variable is fake data, replace when actual lat/lon fields availbale in AMCoreData LiveGroup section
    float lat;
    float lon;
    // Use this when data available in AMCoreData if ( myGroup.latitude && myGroup.longitude ) {
    
        //lat = [myGroup.latitude floatValue];lon = [myGroup.longitude floatValue];
        NSLog(@"found latitude was %f", [[_localGroupLoc objectForKey:@"latitude"] floatValue]);
        lat = [[_localGroupLoc objectForKey:@"latitude"] floatValue];
        lon = [[_localGroupLoc objectForKey:@"longitude"] floatValue];
        //NSLog(@"lat/lon = %f/%f", lat, lon);

    double mapLat0 = worldMap.mapHeight/2;
    double mapLon0 = worldMap.mapWidth/2;
    
    //If lat & lon exist, find their equivelent on current live map
    //need an if statement here checking for amlivegroup data, when it's ready
    double liveGroupLat = (lat * mapLat0)/90;
    double liveGroupLon = (lon * mapLon0)/180;
    double liveGroupPosY = liveGroupLat;
    double liveGroupPosX = liveGroupLon;
    
    if (liveGroupPosY > 0 ) {
        liveGroupPosY = mapLat0 - fabs(liveGroupPosY);
    } else {
        liveGroupPosY += mapLat0;
    }
    if ( liveGroupPosX < 0 ) {
        liveGroupPosX = mapLon0 - fabs(liveGroupPosX);
    } else {
        liveGroupPosX += mapLon0;
    }
    
    //Find closest pixel to current live group location
    
    AMPixel *liveGroupPixel;
    double closestDistToLiveGroup = -1;
    float portX = 0;
    float portY = 0;
    float portRow = 0;
    int portCol = 0;
    //double portW = self.bounds.size.width / (long)worldMap.mapWidth;
    //double portH = self.bounds.size.height / (long)worldMap.mapHeight;
    double portW = 1;
    double portH = worldMap.mapHeight / worldMap.mapWidth;
    
    portH = (((long)worldMap.mapHeight * portW )/(long)worldMap.mapWidth) *1.75;
    
    for (int i = 0; i < self.ports.count; i++) {
        AMPixel *port = self.ports[i];
        port.state = AMPixelStateNormal;
        
        int portPixelPos = (int)[[worldMap.markedPixels objectAtIndex:i] integerValue];
        
        portRow = portPixelPos/worldMap.mapWidth;
        if ( portRow != (int)portRow ) {
            portRow += (int)portRow + 1;
        }
        portCol = portPixelPos % worldMap.mapWidth;
        if (portCol == 0) { portCol = (int)worldMap.mapWidth; }
        
        portX = (portCol * portW) - (portW/2);
        portY = (portRow * portH) - (portH/2);
        
        //Calculate distance between portCenter and liveGroup lat/lon
        double distToLiveGroup = fabs(sqrt(pow((portX - liveGroupPosX),2) - (pow((portY - liveGroupPosY),2))));
        
        if (!isnan(distToLiveGroup) && (closestDistToLiveGroup == -1 || closestDistToLiveGroup > distToLiveGroup)) {
            //NSLog(@"Pixel %i with x/y: (%d, %d) compared to livegroup x/y of: (%f,%f)", i, portX, portY, liveGroupPosX, liveGroupPosY);
            //NSLog(@"new closest Port has distance from livegroup of %f",distToLiveGroup);
            closestDistToLiveGroup = distToLiveGroup;
            liveGroupPixel = port;
        }
        
        
    }
    liveGroupPixel.state = AMPixelStateConnected;
    }
}

- (void)getCoordinates:(NSString *)searchTerm{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:searchTerm
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (error) {
                         NSLog(@"%@", error);
                         
                     } else if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         
                         NSLog(@"top search result is %f, %f",topResult.location.coordinate.latitude, topResult.location.coordinate.longitude);
                         
                         [_localGroupLoc setObject:[NSNumber numberWithFloat:topResult.location.coordinate.latitude] forKey:@"latitude"];
                         [_localGroupLoc setObject:[NSNumber numberWithFloat:topResult.location.coordinate.longitude] forKey:@"longitude"];
                         
                         [self markLiveGroupLocation];
                         
                         [self setNeedsDisplay:YES];
                     }
                 }
     ];

}

@end

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

#import "AMLiveGroupDataSource.h"
#import "AMStaticGroupDataSource.h"
#import "AMStatusNet/AMStatusNet.h"

@interface AMLiveMapView ()
{
    NSPoint _center;
    CGFloat _radius;
    NSInteger _portIndex;
}

@property (nonatomic) NSColor *backgroundColor;
@property (nonatomic) NSArray *ports;
@property (nonatomic) NSMutableDictionary * localGroupLoc;
@property (nonatomic) NSMutableDictionary * allLiveGroupPixels;
@property (nonatomic) NSMutableArray * mergedLocations;
@property (nonatomic) NSCache * allGroupsLoc;
@property (nonatomic) double mapXPush;
@property (nonatomic) double portW;
@property (nonatomic) double portH;
@property (nonatomic) BOOL isCheckingLocation;
@property (nonatomic) BOOL refreshNeeded;
@property (strong)AMLiveGroupDataSource* liveGroupDataSource;

@end


@implementation AMLiveMapView

AMWorldMap *worldMap;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initVars];
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    //[self initVars];
    [self setup];
}

- (void)setup
{
    
    //Construct WorldMap and pixel arrays for assigning buttons to view
    
    
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    NSString *storedMyGroupLoc = [_allGroupsLoc objectForKey:myGroup.groupId];
    
    NSMutableDictionary *connectedGroups = [[NSMutableDictionary alloc] init];

     
    // Get/Set location data
    
    if ( [myGroup isMeshed] ) {
        for (AMLiveGroup *remoteGroup in [AMCoreData shareInstance].remoteLiveGroups) {

            
            NSString * storedGroupLoc = [_allGroupsLoc objectForKey:remoteGroup.groupId];

            if ( storedGroupLoc != remoteGroup.location ) {
                // Current group has either just been created or has had a location change
                
                if ( storedGroupLoc != nil ) { [self checkPixel:remoteGroup]; };
                
                [_allGroupsLoc removeObjectForKey:remoteGroup.groupId];
                
                [self findLiveGroupLocation:remoteGroup];
                
            }
            
            for (AMLiveGroup *remoteSubGroup in remoteGroup.subGroups) {
                NSString * storedSubGroupLoc = [_allGroupsLoc objectForKey:remoteSubGroup.groupId];
                
                if ( storedSubGroupLoc != remoteSubGroup.location ) {
                    
                    if ( storedSubGroupLoc != nil ) { [self checkPixel:remoteSubGroup]; };
                    
                    [_allGroupsLoc removeObjectForKey:remoteSubGroup.groupId];
                    
                    [self findLiveGroupLocation:remoteSubGroup];
                
                    [connectedGroups removeAllObjects];
                    [connectedGroups setObject:remoteGroup forKey:@"group"];
                    [connectedGroups setObject:remoteSubGroup forKey:@"subGroup"];
                    
                    //TODO: Need to be sure either group isn't stored in the mergedLocations array as
                    //part of an old merged connection
                    
                    for ( NSMutableDictionary *groups in self.mergedLocations) {
                        AMLiveGroup *storedGroup = [groups valueForKey:@"group"];
                        AMLiveGroup *storedSubGroup = [groups valueForKey:@"subGroup"];
                        
                        NSLog(@"merged location contains: %@, %@", storedGroup.groupName, storedSubGroup.groupName);
                        NSLog(@"checking against these groups: %@, %@", remoteGroup.groupName, remoteSubGroup.groupName);
                        
                        if ( [remoteGroup.groupId isEqualToString:storedGroup.groupId] ||
                             [remoteGroup.groupId isEqualToString:storedSubGroup.groupId] ||
                             [remoteSubGroup.groupId isEqualToString:storedGroup.groupId] ||
                             [remoteSubGroup.groupId isEqualToString:storedSubGroup.groupId] ) {
                            NSLog(@"Need to remove old merged location...");
                            
                            [self.mergedLocations removeObject:groups];
                        }
                    }
                    
                    [_mergedLocations addObject:connectedGroups];
                
                }
            }
        }
    } else {
        
        NSLog( @"stored mygroup location: %@, current myGroup location: %@", storedMyGroupLoc, myGroup.location );
        
        if ( storedMyGroupLoc != myGroup.location ) {
            NSLog(@"local location doesn't match stored location.");
            [_allGroupsLoc removeAllObjects];
            [self clearMap];
        
            [self findLiveGroupLocation:myGroup];
        }
    }
    
    if ( _refreshNeeded ) {
        _refreshNeeded = NO;
        [self setNeedsDisplay:YES];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveGroupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSLog(@"draw rect called..");
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    [self.backgroundColor set];
    NSRectFill(self.bounds);
    
    NSRect rect = NSInsetRect(self.bounds, NSWidth(self.bounds) / 16.0,
                              NSHeight(self.bounds) / 16.0);
    _radius = MIN(NSWidth(rect) / 2.0, NSHeight(rect) / 2.0);
    _center = NSMakePoint(NSMidX(rect), NSMidY(rect));
    
    
    //Draw each port onto the canvas
    
    NSPoint portCenter;
    
    //_portW = self.bounds.size.width / (long)worldMap.mapWidth;
    
    for (int i = 0; i < self.ports.count; i++) {
        AMPixel *port = self.ports[i];
        
        // Old code to connect 2 ports with line
        /**
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
        **/
        
        portCenter = [self getPortCenter:port];
        //[port drawWithCenterAt:[self centerOfPort:i]];
        
        [port drawWithCenterAt:portCenter];
        
        
    }
    
    // Draw each line connecting ports
    if ( [myGroup isMeshed] ) {
        for ( NSMutableDictionary *groups in self.mergedLocations) {
            NSLog(@"mergedLocations looks like %@", self.mergedLocations);
        
            NSRect rect = NSInsetRect(self.bounds, NSWidth(self.bounds) / 16.0,
                                  NSHeight(self.bounds) / 16.0);
            NSPoint center = NSMakePoint(NSMidX(rect), NSMidY(rect));
            AMPixel *point1;
            AMPixel *point2;
        
            AMLiveGroup *group = [groups valueForKey:@"group"];
            AMLiveGroup *remoteGroup = [groups valueForKey:@"subGroup"];
        
            NSLog(@"A line needs to be drawn between %@ and %@", group.groupName, remoteGroup.groupName);
        
            // Find port associated with each group
            for (int i = 0; i < self.ports.count; i++) {
                AMPixel *port = self.ports[i];
                if ( port.location != nil ) {
                    // port location = group 1 location, set point1 = to port
                    // else if location = group 2 location, set point 2 = to port
                    if (port.location == group.location) {
                        point1 = port;
                    }
                    else if (port.location == remoteGroup.location) {
                        point2 = port;
                    }
                }
            }
        
            //calculate center point of current port on live map (maybe move this to function)
        
        
            NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    
            [bezierPath moveToPoint:[self getPortCenter:point1]];
            [bezierPath curveToPoint:[self getPortCenter:point2]
                   controlPoint1:center
                   controlPoint2:center];
            bezierPath.lineWidth = 2.0;
            [[NSColor grayColor] setStroke];
            [bezierPath stroke];
        
        }
        
    } else {
        [self.mergedLocations removeAllObjects];
    }
    
}

- (NSPoint)getPortCenter:(AMPixel *)port {
    
    //NSUInteger portPixelPos = [self.ports indexOfObjectIdenticalTo:port];
    NSUInteger portPixelPos = (int)[[worldMap.markedPixels objectAtIndex:port.index] integerValue];
    
    NSPoint portCenter;
    int portX = 0;
    int portY = 0;
    float portRow = 0;
    NSUInteger portCol = 0;
    
    _portW = self.bounds.size.width / (long)worldMap.mapWidth;
    float portH = (((long)worldMap.mapHeight * _portW )/(long)worldMap.mapWidth) *1.75;
    
    // Find position of current Pixel on the LiveMapView
    
    portRow = (portPixelPos / (float)worldMap.mapWidth);
    if (portRow != (int)portRow) {
        portRow = (int)portRow + 1;
    }
    portCol = portPixelPos % worldMap.mapWidth;
    if (portCol == 0) { portCol = (int)worldMap.mapWidth; }
    portX = ((_portW * portCol) - (_portW/2)) + _mapXPush;
    portY = (portH * portRow) - (portH/2);
    portCenter = NSMakePoint(portX, portY);
    
    return portCenter;
}

/**
- (NSPoint)centerOfPort:(NSInteger)portIndex
{
    NSAssert(portIndex >= 0 && portIndex < self.ports.count, @"invalid argument");
    
    
    CGFloat radian = portIndex * 2 * M_PI / self.ports.count;
    return NSMakePoint(_radius * cos(radian) + _center.x,
                       _radius * sin(radian) + _center.y);
    
}
**/


- (BOOL)isFlipped{
    return YES;
}

- (void)findLiveGroupLocation:(AMLiveGroup *)theGroup {
    AMLiveGroup *myGroup = theGroup;
    NSString *groupID = myGroup.groupId;
    NSString *location = @"beijing";
    if (myGroup.location) {
        location = myGroup.location;
    }
    
    NSLog(@"finding live group location..");
    //NSLog(@"current group is %@ with latitude and longitude: %@, %@", theGroup.groupName, theGroup.latitude, theGroup.longitude);
    
    [self markLiveGroupLocation:theGroup];
    
    [_allGroupsLoc setObject:myGroup.location forKey:groupID];
    
    _refreshNeeded = YES;
    
    //[self getCoordinates:myGroup];

}

- (void)markLiveGroupLocation:(AMLiveGroup *)theGroup {
    
    float curLat = [theGroup.latitude floatValue];
    float curLon = [theGroup.longitude floatValue];
    
    [_localGroupLoc setObject:[NSNumber numberWithFloat: curLat] forKey:@"latitude"];
    [_localGroupLoc setObject:[NSNumber numberWithFloat: curLon] forKey:@"longitude"];

    if ( [_localGroupLoc count] > 0 ) {
    //This variable is fake data, replace when actual lat/lon fields availbale in AMCoreData LiveGroup section
    float lat;
    float lon;
    // Use this when data available in AMCoreData if ( myGroup.latitude && myGroup.longitude ) {
    
        //lat = [myGroup.latitude floatValue];lon = [myGroup.longitude floatValue];
        //NSLog(@"found latitude was %f", [[_localGroupLoc objectForKey:@"latitude"] floatValue]);
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
        liveGroupPosY = fabs(liveGroupPosY);
        liveGroupPosY += mapLat0;
    }
    if ( liveGroupPosX < 0 ) {
        liveGroupPosX = mapLon0 - fabs(liveGroupPosX);
    } else {
        liveGroupPosX += mapLon0;
    }
    //NSLog(@"Relative position of liveGroup on 75/40 map is: %f, %f", liveGroupPosX, liveGroupPosY);
    
    //Find closest pixel to current live group location
    
    AMPixel *liveGroupPixel;
    double closestDistToLiveGroup = -1;
    float portX = 0;
    float portY = 0;
    float portRow = 0;
    int portCol = 0;
    double portW = 1;
    double portH = worldMap.mapHeight / worldMap.mapWidth;
    
    portH = (((long)worldMap.mapHeight * portW )/(long)worldMap.mapWidth) *1.75;
    
    for (int i = 0; i < self.ports.count; i++) {
        AMPixel *port = self.ports[i];
        //if (self.isCheckingLocation) { port.state = AMPixelStateNormal; }
        
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
            //NSLog(@"Pixel %i with x/y: (%f, %f) compared to livegroup x/y of: (%f,%f) now has shortest distance of %f", i, portX, portY, liveGroupPosX, liveGroupPosY, distToLiveGroup);
            //NSLog(@"new closest Port has distance from livegroup of %f",distToLiveGroup);
            closestDistToLiveGroup = distToLiveGroup;
            liveGroupPixel = port;
        }
        
        
    }
    
    liveGroupPixel.location = theGroup.location;
    liveGroupPixel.state = AMPixelStateConnected;
        
    [_allLiveGroupPixels setObject:liveGroupPixel forKey:theGroup.groupId];
    
    }
}

- (void)getCoordinates:(AMLiveGroup *)currentGroup{
    NSString *searchTerm = currentGroup.location;
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder geocodeAddressString:searchTerm
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (error) {
                         NSLog(@"error--%@",[error localizedDescription]);
                         
                     } else if (placemarks && placemarks.count > 0) {
                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         
                         NSLog(@"top search result is %f, %f",topResult.location.coordinate.latitude, topResult.location.coordinate.longitude);
                         
                         [_localGroupLoc setObject:[NSNumber numberWithFloat:topResult.location.coordinate.latitude] forKey:@"latitude"];
                         [_localGroupLoc setObject:[NSNumber numberWithFloat:topResult.location.coordinate.longitude] forKey:@"longitude"];
                         
                         [self markLiveGroupLocation:currentGroup];
                         
                         [self setNeedsDisplay:YES];
                     }
                 }
     ];
    

}

- (void)checkPixel:(AMLiveGroup *)theGroup {
    // This function checks a given group's previous location (following a change)
    // against all currently active locations on the map
    // If no other group is currently occupying that portion, turn the pixel from active to normal/off
    
    AMPixel *pixelToCheck = [_allLiveGroupPixels objectForKey:theGroup.groupId];
    
    [_allLiveGroupPixels removeObjectForKey:theGroup.groupId];
    
    BOOL normalize = YES;
    
    
    for (NSString *pixelID in _allLiveGroupPixels) {
        AMPixel *liveGroupPixel = [_allLiveGroupPixels objectForKey:pixelID];
        if ( liveGroupPixel.location == pixelToCheck.location ) {
            normalize = NO;
            break;
        }
    }
    
    if (normalize) {
        NSLog(@"Normalizing a pixel..");
        pixelToCheck.state = AMPixelStateNormal;
    }
    
    
}

- (void)clearMap {
    for (int i = 0; i < self.ports.count; i++) {
        AMPixel *port = self.ports[i];
        port.state = AMPixelStateNormal;
    }
}

- (void)liveGroupChanged:(NSNotification *)note {
    [self setup];
}

- (void)initVars {
    worldMap = [[AMWorldMap alloc] init];
    _allGroupsLoc = [[NSCache alloc] init];
    _localGroupLoc = [[NSMutableDictionary alloc] initWithCapacity:2];
    _mergedLocations = [[NSMutableArray alloc] init];
    _allLiveGroupPixels = [[NSMutableDictionary alloc] init];
    
    _backgroundColor = [NSColor colorWithCalibratedRed:0.15
                                                 green:0.15
                                                  blue:0.15
                                                 alpha:1.0];
    
    _portW = self.bounds.size.width / (long)worldMap.mapWidth;
    _portH = self.bounds.size.height / (long)worldMap.mapHeight;
    _mapXPush = (self.bounds.size.width - (_portW * worldMap.mapWidth))/2;
    
    int numberOfPorts = (int)worldMap.numMapTiles;
    NSMutableArray *allPorts = [NSMutableArray arrayWithCapacity:numberOfPorts];
    
    for (int i = 0; i < numberOfPorts; i++) {
        [allPorts addObject:[[AMPixel alloc] initWithIndex:i]];
    }
    
    _ports = [allPorts copy];
    _portIndex = -1;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

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
@property (nonatomic) NSMutableDictionary *allGroups;
@property (nonatomic) NSMutableDictionary * allGroupsLoc;
@property (nonatomic) NSTextView *infoPanel;
@property (nonatomic) NSMutableDictionary *infoPanels;
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
                    
                    //Make sure either group isn't stored in the mergedLocations array as part of an old merged connection
                    
                    /** this has been moved to a function, 
                        make sure still works when meshed then delete this
                    for ( NSMutableDictionary *groups in self.mergedLocations) {
                        AMLiveGroup *storedGroup = [groups valueForKey:@"group"];
                        AMLiveGroup *storedSubGroup = [groups valueForKey:@"subGroup"];
                        
                        if ( [remoteGroup.groupId isEqualToString:storedGroup.groupId] ||
                             [remoteGroup.groupId isEqualToString:storedSubGroup.groupId] ||
                             [remoteSubGroup.groupId isEqualToString:storedGroup.groupId] ||
                             [remoteSubGroup.groupId isEqualToString:storedSubGroup.groupId] ) {
                            
                            [self.mergedLocations removeObject:groups];
                        }
                    }
                    **/
                    
                    
                    [self.mergedLocations removeObject:[self checkGroupIsMerged:remoteGroup]];
                    [self.mergedLocations removeObject:[self checkGroupIsMerged:remoteSubGroup]];
                    
                    
                    [_mergedLocations addObject:connectedGroups];
                
                }
            }
        }
    } else {
        
        if ( storedMyGroupLoc != myGroup.location ) {
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
        
            NSRect rect = NSInsetRect(self.bounds, NSWidth(self.bounds) / 16.0,
                                  NSHeight(self.bounds) / 16.0);
            NSPoint center = NSMakePoint(NSMidX(rect), NSMidY(rect));
            AMPixel *point1;
            AMPixel *point2;
        
            AMLiveGroup *group = [groups valueForKey:@"group"];
            AMLiveGroup *remoteGroup = [groups valueForKey:@"subGroup"];
            
            // TODO: this can probably be more efficient
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
    
    
    [self markLiveGroupLocation:theGroup];
    
    [_allGroups removeObjectForKey:groupID];
    [_allGroups setObject:myGroup forKey:groupID];
    [_allGroupsLoc setObject:myGroup.location forKey:groupID];
    
    _refreshNeeded = YES;
    
}

- (void)markLiveGroupLocation:(AMLiveGroup *)theGroup {
    
    float curLat = [theGroup.latitude floatValue];
    float curLon = [theGroup.longitude floatValue];
    
    [_localGroupLoc setObject:[NSNumber numberWithFloat: curLat] forKey:@"latitude"];
    [_localGroupLoc setObject:[NSNumber numberWithFloat: curLon] forKey:@"longitude"];

    if ( [_localGroupLoc count] > 0 ) {
    
    float lat = [[_localGroupLoc objectForKey:@"latitude"] floatValue];
    float lon = [[_localGroupLoc objectForKey:@"longitude"] floatValue];
        

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
            // New shortest distance found, note it
            closestDistToLiveGroup = distToLiveGroup;
            liveGroupPixel = port;
        }
        
        
    }
    
    liveGroupPixel.location = theGroup.location;
    liveGroupPixel.state = AMPixelStateConnected;
        
    [_allLiveGroupPixels setObject:liveGroupPixel forKey:theGroup.groupId];
    
    }
}

- (id) checkGroupIsMerged:(AMLiveGroup *)theGroup {
    id mergedId = nil;
    
    for ( NSMutableDictionary *groups in self.mergedLocations) {
        AMLiveGroup *storedGroup = [groups valueForKey:@"group"];
        AMLiveGroup *storedSubGroup = [groups valueForKey:@"subGroup"];
        
        if ( [theGroup.groupId isEqualToString:storedGroup.groupId] ||
            [theGroup.groupId isEqualToString:storedSubGroup.groupId] ||
            [theGroup.groupId isEqualToString:storedGroup.groupId] ||
            [theGroup.groupId isEqualToString:storedSubGroup.groupId] ) {
            
            mergedId = groups;
        } else {
            mergedId = nil;
        }
    }
    
    return mergedId;
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
    _allGroups = [[NSMutableDictionary alloc] init];
    _allGroupsLoc = [[NSMutableDictionary alloc] init];
    _infoPanels = [[NSMutableDictionary alloc] init];
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
    
    NSTrackingArea* trackingArea = [ [ NSTrackingArea alloc] initWithRect:[self bounds]       options:(NSTrackingMouseMoved | NSTrackingActiveAlways ) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];

    //Apply the information overlay to the map
    //[self addOverlay:self];
}

-(void) mouseMoved: (NSEvent *) thisEvent
{

    // This event fires when you're in the live map view and the mouse is moving
    NSPoint cursorPoint = [self convertPoint: [thisEvent locationInWindow] fromView: nil];
    BOOL isHovering = NO;
    // Group found, do something with it's information
    AMLiveGroup *hovGroup;
    
    for ( AMPixel *pixel in _allLiveGroupPixels ) {
        
        // Look through every pixel that is set to connected/active state
        
        AMPixel *curPort = [_allLiveGroupPixels objectForKey:pixel];
        NSPoint pixelCenter = [self getPortCenter:curPort];
        
        // Make an imaginary rectangle around each active pixel
        NSRect pixelBounds = NSMakeRect((pixelCenter.x - (_portW/2)), (pixelCenter.y - (_portW/2)), _portW, _portH);
        
        if ( NSPointInRect(cursorPoint, pixelBounds) ) {
            NSString *portLoc = curPort.location;
            
            for ( NSDictionary *group in _allGroupsLoc ) {
                
                // Look through all groups and compare locations to current port
                NSString *groupLoc = [_allGroupsLoc objectForKey:group];
                if (groupLoc == portLoc) {
                    
                    hovGroup = [_allGroups objectForKey:group];
                    //NSLog(@"group is being hovered on! %@", hovGroup.groupName);
                    
                    switch (isHovering) {
                        case NO:
                            if ( ![_infoPanels objectForKey:pixel] ) {
                                NSLog(@"Add overlay for %@", hovGroup.groupName);
                                [self addOverlay:pixel];
                            }
                    
                            NSTextView *thePanel = [_infoPanels objectForKey:pixel];
                            [thePanel setString:hovGroup.groupName];
                            if ( thePanel.isHidden ) {
                                
                                AMPixel *curPixel = [_allLiveGroupPixels objectForKey:pixel];
                                NSPoint hovPoint = [self getPortCenter:curPixel];
                                
                                
                                if ( hovPoint.x > self.frame.size.width/2 ) {
                                    
                                    [thePanel setFrameOrigin:NSMakePoint(hovPoint.x - (thePanel.frame.size.width + 20), hovPoint.y + 20)];
                                } else {
                                    [thePanel setFrameOrigin: NSMakePoint(hovPoint.x + 20,hovPoint.y + 20)];
                                }
                                [self showView:thePanel];
                            }
                    }
                    
                    isHovering = YES;
                    
                }
            }
        }
        
    }
    switch (isHovering) {
        case NO:
            for ( id thePanel in _infoPanels ) {
                NSTextView *curPanel = [_infoPanels objectForKey:thePanel];
                if (!curPanel.isHidden) {
                    [self hideView:curPanel];
                }
            }
            break;
    }
}

- (void)addOverlay:(AMPixel *) thePixel {
    // Add the info panel to the map (used for displaying text on map)
    id pixelId = thePixel;
    NSTextView *newPanel;
    
    NSRect textFrame = [self bounds];
    NSLog(@"text frame width is %f", textFrame.size.width);
    NSLog(@"text frame height is %f", textFrame.size.height);
    textFrame.size.width = 200; //textFrame.size.width/2;
    textFrame.size.height = 35; //textFrame.size.height/5;
    NSFont *font = [NSFont userFontOfSize:16.0];
    
    // Set TextView Properties
    newPanel = [[NSTextView alloc] initWithFrame:textFrame];
    [newPanel setTextColor:[NSColor whiteColor]];
    [newPanel setFont:font];
    [newPanel setAlignment: NSCenterTextAlignment];
    
    newPanel.backgroundColor = _backgroundColor;
    
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:[NSColor colorWithCalibratedRed:0.0
                                                         green:0.0
                                                          blue:0.0
                                                         alpha:0.8]];
    [dropShadow setShadowOffset:NSMakeSize(0, 4.0)];
    [dropShadow setShadowBlurRadius:4.0];
    
    [self setWantsLayer: YES];
    [newPanel setShadow: dropShadow];
    
    
    // Add TextView to Live Map, as a subview overlay
    [self addSubview:newPanel positioned:NSWindowAbove relativeTo:nil];
    
    [newPanel setFrameOrigin:NSMakePoint( (self.frame.size.width/2), self.frame.size.height - (newPanel.frame.size.height) )];
    
    [newPanel setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin]; //NSViewWidthSizable
    
    [self hideView:newPanel];
    
    NSLog(@"New view created and added, with visibility of %hhd", newPanel.isHidden);
    
    [_infoPanels setObject:newPanel forKey:pixelId];
}

- (void)hideView:(NSView *)theView {
    [theView setHidden:TRUE];
}
- (void)showView:(NSView *)theView {
    [theView setHidden:FALSE];
    [theView setNeedsDisplay:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

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
@property (nonatomic) NSMutableDictionary *localGroupLoc;
@property (nonatomic) NSMutableDictionary *allLiveGroupPixels;
@property (nonatomic) NSMutableDictionary *mergedLocations;
@property (nonatomic) NSMutableDictionary *allGroups;
@property (nonatomic) NSMutableDictionary *allGroupsLoc;
@property (nonatomic) NSTextView *infoPanel;
@property (nonatomic) NSMutableDictionary *infoPanels;
@property (nonatomic) double mapXPush;
@property (nonatomic) double portW;
@property (nonatomic) double portH;
@property (nonatomic) BOOL isCheckingLocation;
@property (nonatomic) BOOL isHovering;
@property (nonatomic) AMLiveGroup *hovGroup;
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

     
    // Get/Set location data
    
    if ( [myGroup isMeshed] ) {
        //AMCoreData *remoteGroups = [AMCoreData shareInstance].remoteLiveGroups;
        
        [self clearGroup:myGroup.groupId];
        
        for (AMLiveGroup *remoteGroup in [AMCoreData shareInstance].remoteLiveGroups) {

        //for (AMLiveGroup *remoteGroup in [self getFakeData]) {
            
            NSString * storedGroupLoc = [_allGroupsLoc objectForKey:remoteGroup.groupId];

            if ( storedGroupLoc != remoteGroup.location ) {
                // Current group has either just been created or has had a location change
                
                [_allGroupsLoc removeObjectForKey:remoteGroup.groupId];
                
                [self findLiveGroupLocation:remoteGroup];
                
            }
            
            for (AMLiveGroup *remoteSubGroup in remoteGroup.subGroups) {
                NSString * storedSubGroupLoc = [_allGroupsLoc objectForKey:remoteSubGroup.groupId];
                
                if ( storedSubGroupLoc != remoteSubGroup.location ) {
                    //subgroup either just created or location changed
                    
                    if ( storedSubGroupLoc != nil ) {
                        //[self checkPixel:remoteSubGroup];
                        [self clearPixel:remoteSubGroup.groupId];
                    };
                    
                    [_allGroupsLoc removeObjectForKey:remoteSubGroup.groupId];
                    
                    [self findLiveGroupLocation:remoteSubGroup];
                    
                    NSString *mergeId = [NSString stringWithFormat:@"%@%@", remoteGroup.groupId, remoteSubGroup.groupId];
                    
                    if ( ![_mergedLocations objectForKey:mergeId] ) {
                        // Connection doesn't exist yet
                        
                        NSMutableDictionary *connectedGroups = [[NSMutableDictionary alloc] initWithObjectsAndKeys:remoteGroup, @"group", remoteSubGroup, @"subGroup", nil];
                        
                        [_mergedLocations setObject:connectedGroups forKey:mergeId];
                    }
                        
                }
            }
            
            //Make sure group isn't stored in the mergedLocations array as part of an old merged connection
            [self removeOldMerges:remoteGroup];
            
        }
        
        // Check for de-meshed users
        for (AMPixel *curPixel in _allLiveGroupPixels) {
            if ( ![_allGroups objectForKey:curPixel] ) {
                // This group no longer exists (de-meshed)
                _refreshNeeded = YES;
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
    
    for (int i = 0; i < self.ports.count; i++) {
        AMPixel *port = self.ports[i];
        
        portCenter = [self getPortCenter:port];
        //[port drawWithCenterAt:[self centerOfPort:i]];
        
        [port drawWithCenterAt:portCenter];
        
        
    }
    
    // Draw each line connecting ports
    if ( [myGroup isMeshed] ) {
        for ( NSMutableDictionary *groups in _mergedLocations ) {
            
            NSMutableDictionary *theGroups = [_mergedLocations objectForKey:groups];
            
            AMPixel *point1;
            AMPixel *point2;
        
            AMLiveGroup *group = [theGroups valueForKey:@"group"];
            AMLiveGroup *subGroup = [theGroups valueForKey:@"subGroup"];
            
        
            point1 = [_allLiveGroupPixels objectForKey:group.groupId];
            point2 = [_allLiveGroupPixels objectForKey:subGroup.groupId];
            
            if ( point1 && point2 ) {
                
                NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    
                [bezierPath moveToPoint:[self getPortCenter:point1]];
                [bezierPath lineToPoint:[self getPortCenter:point2]];
                //[bezierPath curveToPoint:[self getPortCenter:point2]
                   //controlPoint1:center
                   //controlPoint2:center];
                bezierPath.lineWidth = 2.0;
                [[NSColor grayColor] setStroke];
                [bezierPath stroke];
            }
        }
        
    } else {
        [_mergedLocations removeAllObjects];
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
    
    // Clear any old pixel associated with this group
    [self clearPixel:theGroup.groupId];
        
    // Find closest open pixel to current live group location
        
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
        
        if ( port.state == AMPixelStateNormal ) {
            
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
        
        
    }
    
    if ( liveGroupPixel.state == AMPixelStateNormal ) {
        liveGroupPixel.location = theGroup.location;
        liveGroupPixel.liveGroupId = theGroup.groupId;
        liveGroupPixel.state = AMPixelStateConnected;
        
        [_allLiveGroupPixels setObject:liveGroupPixel forKey:theGroup.groupId];
    
        }
    }
}

- (NSMutableDictionary *) checkGroupIsMerged:(AMLiveGroup *)theGroup {
    NSMutableDictionary *mergedIds = [[NSMutableDictionary alloc] init];
    
    for ( NSDictionary *groups in _mergedLocations) {
        NSDictionary *theGroups = [_mergedLocations objectForKey:groups];
        
        AMLiveGroup *storedGroup = [theGroups valueForKey:@"group"];
        AMLiveGroup *storedSubGroup = [theGroups valueForKey:@"subGroup"];
        
        if ( [theGroup.groupId isEqualToString:storedGroup.groupId] ) {
            // merge found
            [mergedIds setObject:storedSubGroup forKey:storedSubGroup.groupId];
        } else if ( [theGroup.groupId isEqualToString:storedSubGroup.groupId] ) {
            // merge found
            [mergedIds setObject:storedGroup forKey:storedGroup.groupId];
        }
    }
    return mergedIds;
}

- (void)removeOldMerges:(AMLiveGroup *)theGroup {
    id mergedGroups = [self checkGroupIsMerged:theGroup ];
    if ( [mergedGroups count] > 0 ) {
        // This group has some merged connections
        
        for ( id mergedGroup in mergedGroups) {
            // Here is a connection, make sure the subGroup is still a subgroup and hasn't de-merged
            AMLiveGroup *theMergedGroup = [_allGroups objectForKey:mergedGroup];
            BOOL groupExists = NO;
            for (AMLiveGroup *remoteSubGroup in theGroup.subGroups) {
                if ( theMergedGroup.groupId == remoteSubGroup.groupId ) {
                    groupExists = YES;
                }
            }
            switch (groupExists) {
                case NO:
                {
                    // Subgroup no longer exists. Remove this stored connection
                    NSString *mergeId = [NSString stringWithFormat:@"%@%@", theGroup.groupId, theMergedGroup.groupId];
                    NSString *mergeSubId = [NSString stringWithFormat:@"%@%@", theMergedGroup.groupId, theGroup.groupId];
                    [_mergedLocations removeObjectForKey:mergeId];
                    [_mergedLocations removeObjectForKey:mergeSubId];
                    break;
                }
                    
                default:
                    break;
            }
        }
    }
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

- (void)clearGroup:(id)theGroup {
    [self clearPixel:theGroup];
    [_allGroups removeObjectForKey:theGroup];
    [_allGroupsLoc removeObjectForKey:theGroup];
}

- (void)clearPixel:(id)theGroup {
    AMPixel *pixelToClear = [_allLiveGroupPixels objectForKey:theGroup];
    
    pixelToClear.state = AMPixelStateNormal;
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
    _mergedLocations = [[NSMutableDictionary alloc] init];
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

}

-(void) mouseMoved: (NSEvent *) thisEvent
{
    // This event fires when you're in the live map view and the mouse is moving
    NSPoint cursorPoint = [self convertPoint: [thisEvent locationInWindow] fromView: nil];
    
    if (!_hovGroup) {
        // Hasn't been hoving over group, check to make sure still not hovering
        
        BOOL groupFound = NO;
        for ( AMPixel *pixel in _allLiveGroupPixels ) {
            
            // Look through every pixel that is set to connected/active state
            
            AMPixel *curPort = [_allLiveGroupPixels objectForKey:pixel];
            NSPoint pixelCenter = [self getPortCenter:curPort];
            
            // Make an imaginary rectangle around this active pixel
            NSRect pixelBounds = NSMakeRect((pixelCenter.x - (_portW/2)), (pixelCenter.y - (_portW/2)), _portW, _portH);
            
            if ( NSPointInRect(cursorPoint, pixelBounds) ) {

                AMLiveGroup *group = [_allGroups objectForKey:pixel];
                if ( group ) {
                    // Group is being hovered on
                    
                    _hovGroup = group;
                    groupFound = YES;
                        
                    switch (_isHovering) {
                        case NO:
                            // Display info panel
                            if ( ![_infoPanels objectForKey:_hovGroup.groupId] ) {
                                [self addOverlay:_hovGroup];
                            }
                        
                            NSTextView *thePanel = [_infoPanels objectForKey:_hovGroup.groupId];
                            [thePanel setString:_hovGroup.groupName];
                            if ( thePanel.isHidden ) {
                                    
                                // Display the main group panel
                                [self displayInfoPanel:thePanel forGroup:_hovGroup onPixel:pixel];
                                    
                                // If the current group is a part of a merged group, show a panel for the other group also
                                    
                                id mergedGroups = [self checkGroupIsMerged:_hovGroup ];
                                if ( [mergedGroups count] > 0 ) {
                                    // This group is merged
                                    for ( id mergedGroup in mergedGroups) {
                                    
                                        AMLiveGroup *theMergedGroup = [_allGroups objectForKey:mergedGroup];
                                            
                                        // find pixel for mergedGroup
                                        id mergedPixel = theMergedGroup.groupId;
                                            
                                        // if pixel doesn't have a panel, add one
                                        if ( ![_infoPanels objectForKey:theMergedGroup.groupId] ) {
                                            [self addOverlay:theMergedGroup];
                                        }
                                            
                                        // grab the newly created info panel and manipulate it, if not done already
                                        thePanel = [_infoPanels objectForKey:theMergedGroup.groupId];
                                        [thePanel setString:theMergedGroup.groupName];
                                        if ( thePanel.isHidden ) {
                                            [self displayInfoPanel:thePanel forGroup:mergedGroup onPixel:mergedPixel];
                                        }
                                }
                                        
                                } else {
                                        //This group isn't merged..
                                }
                                    
                                    
                            }
                            [[NSCursor pointingHandCursor] set];
                            _isHovering = YES;
                            break;
                        
                    } // close switch case
                }
            }
        
            if (groupFound) { break;}
            
        } //close live pixel for loop
    } else {
        [[NSCursor pointingHandCursor] set];
        // Group currently hovered on, make sure still hovering on
        id hovGroupId = _hovGroup.groupId;
        AMPixel *curPort = [_allLiveGroupPixels objectForKey:hovGroupId];
        NSPoint pixelCenter = [self getPortCenter:curPort];
        
        // Make an imaginary rectangle around this active pixel
        NSRect pixelBounds = NSMakeRect((pixelCenter.x - (_portW/2)), (pixelCenter.y - (_portW/2)), _portW, _portH);
        
        if ( !NSPointInRect(cursorPoint, pixelBounds) ) {
            //Cursor no longer hovering over a group
            _isHovering = NO;
        }
    }// close if _hovGroup
    
    switch (_isHovering) {
        case NO:
            [[NSCursor arrowCursor] set];
            _hovGroup = nil;
            for ( id thePanel in _infoPanels ) {
                NSTextView *curPanel = [_infoPanels objectForKey:thePanel];
                if (!curPanel.isHidden) {
                    [self hideView:curPanel];
                }
            }
            break;
    }
}

- (void)displayInfoPanel:(NSTextView *) thePanel forGroup:(AMLiveGroup *) theGroup onPixel:(AMPixel *) thePixel {
    NSSize panelPadding = { 10, 5 };
    
    
    NSLayoutManager *panelLayout = thePanel.layoutManager;
    NSTextContainer *panelText = thePanel.textContainer;
    
    [panelLayout glyphRangeForTextContainer:panelText] ;
    NSSize panelSize = [panelLayout usedRectForTextContainer:panelText].size;
    
    
    NSRect newPanelSize = NSMakeRect(0, 0, panelSize.width + (panelPadding.width *2), panelSize.height+panelPadding.height + (panelPadding.height * 2));
    [thePanel setTextContainerInset:panelPadding];
    [thePanel setFrame:newPanelSize];

    //id pixelId = (id)thePixel;
    AMPixel *curPixel = [_allLiveGroupPixels objectForKey:thePixel];
    NSPoint hovPoint = [self getPortCenter:curPixel];

        
    if ( hovPoint.x > self.frame.size.width/2 ) {
            
        [thePanel setFrameOrigin:NSMakePoint(hovPoint.x - (thePanel.frame.size.width + 20), hovPoint.y + 20)];
    } else {
        [thePanel setFrameOrigin: NSMakePoint(hovPoint.x + 20,hovPoint.y + 20)];
    }
    
    [self showView:thePanel];
}

- (void)addOverlay:(AMLiveGroup *) theGroup {
    // Add the info panel to the map (used for displaying text on map)
    //id pixelId = thePixel;
    NSString *groupId = theGroup.groupId;
    
    NSTextView *newPanel;
    
    NSRect textFrame = [self bounds];
    textFrame.size.width = 200; //textFrame.size.width/2;
    textFrame.size.height = 35; //textFrame.size.height/5;
    NSFont *font = [NSFont userFontOfSize:16.0];
    
    // Set TextView Properties
    newPanel = [[NSTextView alloc] initWithFrame:textFrame];
    [newPanel setTextColor:[NSColor whiteColor]];
    [newPanel setEditable:NO];
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
    
    [_infoPanels setObject:newPanel forKey:groupId];
}

- (void)hideView:(NSView *)theView {
    [theView setHidden:TRUE];
}
- (void)showView:(NSView *)theView {
    [theView setHidden:FALSE];
    [theView setNeedsDisplay:YES];
}

- (BOOL)isFlipped{
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (NSMutableArray *)getFakeData {

    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://localhost:8080/artsmesh-test-data.json"]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request
returningResponse:nil error:nil];
    NSError *jsonParsingError = nil;
    NSArray *fakeLiveData = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    
    if(jsonParsingError != nil){
        NSLog(@"fake data parse Json error:%@", jsonParsingError.description);
    }
    
    NSDictionary* results = (NSDictionary*)fakeLiveData;
    NSDictionary* rootGroup = [results valueForKey:@"Data"];
    
    NSArray* groups = [rootGroup valueForKey:@"SubGroups"];
    
    
    NSMutableArray *formattedResults = [[NSMutableArray alloc] init];
    for (NSDictionary *remoteGroup in groups) {
        //Create group and any subgroups from data
        //AMLiveGroup *theGroup = [self createFakeGroup:[remoteGroup valueForKey:@"GroupData"]];
        AMLiveGroup *theGroup = [self createFakeGroup:remoteGroup];
        
        //NSLog(@"here is a group %@", theGroup.groupName);
        [formattedResults addObject:theGroup];
    }
    
    //NSLog(@"formatted groups are : %@", formattedResults);
    
    return formattedResults;
}

- (AMLiveGroup *)createFakeGroup:(NSDictionary *)remoteGroup {
    NSDictionary *rawGroupData = [remoteGroup objectForKey:@"GroupData"];
    NSArray *rawSubGroupData = [remoteGroup valueForKey:@"SubGroups"];
    
    AMLiveGroup *theGroup = [[AMLiveGroup alloc] init];
    theGroup.groupId = [rawGroupData valueForKey:@"GroupId"];
    theGroup.groupName = [rawGroupData valueForKey:@"GroupName"];
    theGroup.description = [rawGroupData valueForKey:@"Description"];
    theGroup.leaderId = [rawGroupData valueForKey:@"LeaderId"];
    theGroup.fullName = [rawGroupData valueForKey:@"FullName"];
    theGroup.project = [rawGroupData valueForKey:@"Project"];
    theGroup.location = [rawGroupData valueForKey:@"Location"];
    theGroup.longitude = [rawGroupData valueForKey:@"Longitude"];
    theGroup.latitude = [rawGroupData valueForKey:@"Latitude"];
    theGroup.busy = (BOOL)[rawGroupData valueForKey:@"Busy"];
    
    if ( ![rawSubGroupData isEqual:[NSNull null]] ) {NSLog(@"no subgroups");
        theGroup.subGroups = [self findFakeSubGroups:rawSubGroupData];
    }
    
    return theGroup;
}

- (NSMutableArray *)findFakeSubGroups:(NSArray *)rawSubGroupData {
    
    NSMutableArray *subGroups = [[NSMutableArray alloc] init];
    
    
    
    //NSLog(@"subgroup data looks like %@", rawSubGroupData);
    
    for (NSDictionary *remoteSubGroup in rawSubGroupData) {
        AMLiveGroup *theGroup = [self createFakeGroup:remoteSubGroup];
        [subGroups addObject:theGroup];
    }
    
    //NSLog(@"subgroups look like %@", subGroups);
    
    
    return subGroups;
    
}

@end
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
#import "AMLiveMapProgramView.h"
#import "AMLiveMapProgramViewController.h"
#import "AMLiveMapProgramContentView.h"
#import "AMLiveMapProgramPanelTextView.h"
#import "AMFloatPanelViewController.h"
#import "AMFloatPanelView.h"
#import "AMPanelViewController.h"
#import "AMGroupPreviewPanelController.h"
#import "AMGroupPreviewPanelView.h"
#import "UIFramework/AMBorderView.h"


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
@property (nonatomic) NSMutableDictionary *infoPanels;
@property (nonatomic) NSMutableDictionary *fonts;
@property (nonatomic) NSView *programView;
@property (nonatomic) NSTrackingArea *mapTrackingArea;
@property (nonatomic) AMFloatPanelViewController *floatPanelViewController;
@property (nonatomic) AMLiveMapProgramViewController *programViewController;
@property (nonatomic) NSWindow *programWindow;
@property (nonatomic) NSTextView *infoPanel;
@property (nonatomic) double mapXPush;
@property (nonatomic) double portW;
@property (nonatomic) double portH;
@property (nonatomic) BOOL isCheckingLocation;
@property (nonatomic) BOOL isHovering;
@property (nonatomic) BOOL refreshNeeded;
@property (nonatomic) BOOL isMeshed;
@property (nonatomic) AMLiveGroup *myGroup;
@property (nonatomic) AMLiveGroup *hovGroup;
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
    
    //AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    NSString *storedMyGroupLoc = [_allGroupsLoc objectForKey:_myGroup.groupId];
    
    // Get/Set location data
    
    if ( [_myGroup isMeshed] ) {
        NSLog(@"iterate through groups in setup again.");
        
        NSMutableDictionary *curGroups = [[NSMutableDictionary alloc] init];
        
        //for (AMLiveGroup *remoteGroup in [AMCoreData shareInstance].remoteLiveGroups) {
        
        for (AMLiveGroup *remoteGroup in [self getFakeData]) {
            
            [curGroups setObject:remoteGroup.groupName forKey:remoteGroup.groupId];
            
            NSString * storedGroupLoc = [_allGroupsLoc objectForKey:remoteGroup.groupId];
            
            if ( storedGroupLoc != remoteGroup.location ) {
                // Current group has either just been created or has had a location change
                
                [_allGroupsLoc removeObjectForKey:remoteGroup.groupId];
                
                [self findLiveGroupLocation:remoteGroup];
                
            }
            
            for (AMLiveGroup *remoteSubGroup in remoteGroup.subGroups) {
        
                AMLiveGroup *storedRemoteGroup = [_allGroups objectForKey:remoteGroup];
                
                [curGroups setObject:remoteSubGroup.groupName forKey:remoteSubGroup.groupId];
                
                NSString * storedSubGroupLoc = [_allGroupsLoc objectForKey:remoteSubGroup.groupId];
                
                //if ( storedSubGroupLoc != remoteSubGroup.location ) {
                if ( ![storedRemoteGroup.subGroups isEqualToArray:remoteGroup.subGroups] ) {
                    //subgroup either just created or location changed
                    //NSLog(@"subgroup either just created or location changed.. %@", remoteSubGroup.groupName);
                    
                    if ( storedSubGroupLoc != nil ) {
                        [self clearPixel:remoteSubGroup.groupId];
                    };
                    
                    [_allGroupsLoc removeObjectForKey:remoteSubGroup.groupId];
                    
                    [self findLiveGroupLocation:remoteSubGroup];
                    
                    NSString *mergeId = [NSString stringWithFormat:@"%@%@", remoteGroup.groupId, remoteSubGroup.groupId];
                    
                    if ( ![_mergedLocations objectForKey:mergeId] ) {
                        // Connection doesn't exist yet
                        
                        NSMutableDictionary *connectedGroups = [[NSMutableDictionary alloc] initWithObjectsAndKeys:remoteGroup, @"group", remoteSubGroup, @"subGroup", nil];
                        
                        [_mergedLocations setObject:connectedGroups forKey:mergeId];
                        
                        _refreshNeeded = YES;
                    }
                    
                }
            }
            
            //Make sure group isn't stored in the mergedLocations array as part of an old merged connection
            [self removeOldMerges:remoteGroup];
            
        }
        
        // Check for de-meshed users
        
        NSMutableDictionary *allGroupsCopy = [_allGroups copy];
        for ( AMLiveGroup *group in allGroupsCopy ) {
            if (![curGroups objectForKey:group]) {
                // This group no longer exists (de-meshed)
                [self clearGroup:group];
                _refreshNeeded = YES;
            }
        }
        
    } else {
        
        if ( storedMyGroupLoc != _myGroup.location ) {
            [_allGroupsLoc removeAllObjects];
            [self clearMap];
            
            [self findLiveGroupLocation:_myGroup];
        }
    }

    
    if ( _refreshNeeded ) {
        _refreshNeeded = NO;
        [self setNeedsDisplay:YES];
    }
    
}

- (void)drawRect:(NSRect)dirtyRect
{
    //AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
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
    
    //NSLog(@"all merged connections are %@", _mergedLocations);
    
    // Draw each line connecting ports
    if ( [_myGroup isMeshed] ) {
        
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
    
    if ( !worldMap.state == overView ) {
        [self updateGroupPreviewOverlays];
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
    
    NSMutableDictionary *mergedGroups = [[NSMutableDictionary alloc] init];
    
    mergedGroups = [self checkGroupIsMerged:theGroup];
    
    if ( [mergedGroups count] > 0 ) {
        // This group has some merged connections
        
        for ( id mergedGroup in mergedGroups) {
            // Here is a connection
            //make sure the subGroup is still a subgroup and hasn't de-merged
            AMLiveGroup *theMergedGroup = [_allGroups objectForKey:mergedGroup];
            
            BOOL groupExists = NO;
            for (AMLiveGroup *remoteSubGroup in theGroup.subGroups) {
                if ( [theMergedGroup.groupId isEqualToString:remoteSubGroup.groupId] ) {
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
    _myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
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
    
    _isMeshed = NO;
    _portW = self.bounds.size.width / (long)worldMap.mapWidth;
    _portH = self.bounds.size.height / (long)worldMap.mapHeight;
    _mapXPush = (self.bounds.size.width - (_portW * worldMap.mapWidth))/2;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    _fonts = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
              [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:5 size:16.0], @"header",
              [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:14.0], @"body",
              [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:10 size:13.0], @"13",
              [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:5 size:12.0], @"small",
              [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:5 size:12.0], @"small-italic",
              nil];
    
    _programView = [[AMLiveMapProgramView alloc] init];
    
    [self addSubview:_programView];
    [self hideView:_programView];
    
    int numberOfPorts = (int)worldMap.numMapTiles;
    NSMutableArray *allPorts = [NSMutableArray arrayWithCapacity:numberOfPorts];
    
    for (int i = 0; i < numberOfPorts; i++) {
        [allPorts addObject:[[AMPixel alloc] initWithIndex:i]];
    }
    
    _ports = [allPorts copy];
    _portIndex = -1;
    
    NSTrackingArea* trackingArea = [ [ NSTrackingArea alloc] initWithRect:[self bounds]       options:(NSTrackingMouseMoved | NSTrackingActiveAlways ) owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    _mapTrackingArea = trackingArea;
    
    
    [self createProgram];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(liveGroupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    
    
    // For local testing purposes only
    
    /**
     [NSTimer scheduledTimerWithTimeInterval: 30.0
     target: self
     selector:@selector(onTick:)
     userInfo: nil repeats:YES];
    **/
}

- (void)updateTrackingAreas {
    [super updateTrackingAreas];
    if (_mapTrackingArea) {
        [self removeTrackingArea:_mapTrackingArea];
        NSTrackingArea* trackingArea = [ [ NSTrackingArea alloc] initWithRect:[self bounds]       options:(NSTrackingMouseMoved | NSTrackingActiveAlways ) owner:self userInfo:nil];
        _mapTrackingArea = trackingArea;
        [self addTrackingArea:_mapTrackingArea];
    }
}

-(void) mouseMoved: (NSEvent *) thisEvent
{
    // This event fires when you're in the live map view and the mouse is moving
    if ( worldMap.state == overView ) {
        
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
                                
                                AMGroupPreviewPanelView *theOverlay = [_infoPanels objectForKey:_hovGroup.groupId];
                                
                                if ( [theOverlay isHidden] ) {
                                    
                                    // Display the main group panel
                                    [self displayGroupPreviewOverlay:_hovGroup];
                                    // If the current group is a part of a merged group, show a panel for the other group also
                                    
                                    id mergedGroups = [self checkGroupIsMerged:_hovGroup ];
                                    if ( [mergedGroups count] > 0 ) {
                                        // This group is merged
                                        for ( id mergedGroup in mergedGroups) {
                                            
                                            AMLiveGroup *theMergedGroup = [_allGroups objectForKey:mergedGroup];
                                            
                                            // if pixel doesn't have a panel, add one
                                            if ( ![_infoPanels objectForKey:theMergedGroup.groupId] ) {
                                                [self addOverlay:theMergedGroup];
                                            }
                                            
                                            // grab the newly created info panel and manipulate it, if not done already
                                            theOverlay = [_infoPanels objectForKey:theMergedGroup.groupId];
                                            
                                            if ( [theOverlay isHidden] ) {

                                                [self displayGroupPreviewOverlay:theMergedGroup];
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
                [self hideAllPanels];
                
                if ( worldMap.state == overView && self.wantsLayer == YES) {
                    // Turn this off when not needed to avoid graphic clipping
                    [self setWantsLayer: NO];
                }
                break;
            case YES:
                if ( worldMap.state == overView && self.wantsLayer == NO ) {
                    // Displaying shadows atop live map, so need this property
                    [self setWantsLayer: YES];
                }
                break;
        }
    } else if ( worldMap.state == programView ) {
        [[NSCursor arrowCursor] set];
        _hovGroup = nil;
    }
    
}


-(void) mouseDown: (NSEvent *) thisEvent {
    
    NSCursor *cursor = [NSCursor currentCursor];
    
    if ( [cursor isEqual:[NSCursor pointingHandCursor]] ) {
        // Cursor is hovering over group and has been clicked
        
        if (_hovGroup) {
            worldMap.state = programView;
            
            if ( [_myGroup isMeshed] ) {
                // Check if group is parent or subgroup of a merge
                BOOL isMerged = NO;
                for ( NSMutableDictionary *groups in _mergedLocations ) {
                    
                    NSMutableDictionary *theGroups = [_mergedLocations objectForKey:groups];
                    
                    AMLiveGroup *group = [theGroups valueForKey:@"group"];
                    AMLiveGroup *subGroup = [theGroups valueForKey:@"subGroup"];
                    if ( group == _hovGroup || subGroup == _hovGroup ) {
                        [self displayProgram:group];
                        isMerged = YES;
                        break;
                    }
                }
                if (!isMerged) {
                    [self displayProgram:_hovGroup];
                }
                
            } else {
                // only worry about myGroup
                
                [self displayProgram:_hovGroup];
            }
            
        }
        
        
    } else {
        // General map area has been clicked, reset map state
        _isHovering = NO;
        worldMap.state = overView;
        [self hideView:_programView];
        [self hideAllPanels];
    }
    
}


- (void)createProgram {

    AMLiveMapProgramViewController *pvc = [[AMLiveMapProgramViewController alloc] initWithNibName:@"AMLiveMapProgramViewController" bundle:nil];
    _programViewController = pvc;
    pvc.scrollView.autoresizingMask = NSViewHeightSizable | NSViewWidthSizable;
    
    double programW = pvc.view.frame.size.width;
    double programH = pvc.view.frame.size.height;
    
    AMFloatPanelViewController *fpc = [[AMFloatPanelViewController alloc] initWithNibName:@"AMFloatPanelView" bundle:nil];
    _floatPanelViewController = fpc;
    _floatPanelViewController.panelTitle = @"LIVE";
    [_floatPanelViewController.view setFrameSize:NSMakeSize(programW, programH)];
    AMFloatPanelView *floatPanel = (AMFloatPanelView *) fpc.view;
    floatPanel.floatPanelViewController = fpc;
    //NSRect frame = NSMakeRect(0, 0, fpc.view.frame.size.width-100, fpc.view.frame.size.height);
    NSRect frame = NSMakeRect(0, 0, programW, programH+41);
    
    _programWindow  = [[NSWindow alloc] initWithContentRect:frame
                                                  styleMask:NSBorderlessWindowMask
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];
    fpc.containerWindow = _programWindow;

    [fpc.view addSubview:pvc.view];
    
    
    //[_programWindow setBackgroundColor:[NSColor blueColor]];
    _programWindow.hasShadow = YES;
    
    [_programWindow setFrameOrigin:NSMakePoint((self.frame.size.width/2), self.frame.size.height)];
    
    
    [_programWindow.contentView addSubview:floatPanel];
    
    fpc.view.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:@{@"subView" : fpc.view}];
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : fpc.view}];
    [_programWindow.contentView addConstraints:verticalConstraints];
    [_programWindow.contentView addConstraints:horizontalConstraints];
    
    [_programWindow.contentView setAutoresizesSubviews:YES];
    [fpc.view setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
        
}

- (void)displayProgram:(AMLiveGroup *)theGroup {
    _programViewController.group = theGroup;
    
    // Remove old content from scroll view
    /**
    for(NSView *subview in [_programViewController.scrollView subviews]) {
        if([subview isKindOfClass:[AMLiveMapProgramPanelTextView class]]) {
            [subview removeFromSuperview];
        }
    }
     **/
    
    // Configure & display the group/user fields
    
    AMLiveMapProgramContentView *programContentContainer = [[AMLiveMapProgramContentView alloc] initWithFrame:NSMakeRect(0, 0, _programViewController.scrollView.bounds.size.width, 0)];
    
    _programViewController.scrollView.documentView = programContentContainer;
    
    [programContentContainer fillContent:theGroup inScrollView:_programViewController.scrollView];
    
    
    // Display the program
    _programWindow.level = NSFloatingWindowLevel;
    [_programWindow makeKeyAndOrderFront:self];
}

- (void) displayGroupPreviewOverlay:(AMLiveGroup *)theGroup {
    
    AMPixel *curPixel = [_allLiveGroupPixels objectForKey:theGroup.groupId];
    NSPoint hovPoint = [self getPortCenter:curPixel];
    
    AMGroupPreviewPanelView *previewPanelView = [_infoPanels objectForKey:theGroup.groupId];

    if ( hovPoint.x > self.frame.size.width/2 ) {
        [previewPanelView setFrameOrigin:NSMakePoint((hovPoint.x - previewPanelView.frame.size.width) - 20, hovPoint.y +20)];
    } else {
        [previewPanelView setFrameOrigin:NSMakePoint(hovPoint.x + 20, hovPoint.y +20)];
    }
     
    [previewPanelView setHidden:NO];
    
}

- (void) updateGroupPreviewOverlays {
    for ( id thePanel in _infoPanels ) {
        
        AMGroupPreviewPanelView *curPreviewPanelView = [_infoPanels objectForKey:thePanel];
        
        if (![curPreviewPanelView isHidden]) {
            
            [self displayGroupPreviewOverlay:curPreviewPanelView.group];
            
        }
        
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

- (void)hideAllPanels {
    for ( id thePanel in _infoPanels ) {
        AMGroupPreviewPanelView *curPreviewPanel = [_infoPanels objectForKey:thePanel];
        if ( ![curPreviewPanel isHidden] ) {
            [curPreviewPanel setHidden:YES];
        }

    }
}

- (void)addOverlay:(AMLiveGroup *) theGroup {
    // Add the info panel to the map (used for displaying text on map)
    
    NSString *groupId = theGroup.groupId;
    AMGroupPreviewPanelController *gpc = [[AMGroupPreviewPanelController alloc] initWithNibName:@"AMGroupPreviewPanelController" bundle:nil];
    gpc.group = theGroup;
    
    NSFont* textFieldFont =  [_fonts objectForKey:@"small-italic"];
    NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName:textFieldFont};
    NSMutableAttributedString* groupDesc = [[NSMutableAttributedString alloc] initWithString:theGroup.description attributes:attr];
    gpc.groupDesc = groupDesc;

    
    AMGroupPreviewPanelView *previewPanelView = (AMGroupPreviewPanelView *)gpc.view;
    previewPanelView.groupPreviewPanelController = gpc;
    previewPanelView.group = theGroup;
    
    [previewPanelView setHidden:YES];
    [self addSubview:previewPanelView];
    
    [_infoPanels setObject:previewPanelView forKey:groupId];
    
}

- (void)formatTextView:(NSTextView *) theTextView withFont:(NSFont *)theFont {
    
    [theTextView setTextColor:[NSColor whiteColor]];
    [theTextView setFont:theFont];
    [theTextView setAlignment: NSCenterTextAlignment];
    
    theTextView.backgroundColor = _backgroundColor;
}

- (void)formatTextField:(NSTextField *)theField withFont:(NSFont *)theFont {
    
    [theField setBackgroundColor:_backgroundColor];
    [theField setBordered:NO];
    [theField setStringValue:@"Additional Info"];
    
    //theFont = [[NSFontManager sharedFontManager] convertFont:theFont toHaveTrait:NSFontBoldTrait];
    
    [theField setFont: theFont];
}

- (void)addShadow:(NSView *)theView withOffset:(NSSize)theOffset {
    
    NSShadow *dropShadow = [[NSShadow alloc] init];
    [dropShadow setShadowColor:[NSColor colorWithCalibratedRed:0.0
                                                         green:0.0
                                                          blue:0.0
                                                         alpha:0.8]];
    [dropShadow setShadowOffset:theOffset];
    [dropShadow setShadowBlurRadius:4.0];
    
    [theView setShadow: dropShadow];
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


// Below: Local testing code (not used in production)


-(void)onTick:(NSTimer *)timer {
    //do something
    //NSLog(@"test ping..");
    [self setup];
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
    NSArray *rawUserData = [remoteGroup objectForKey:@"Users"];
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

    if ( ![rawUserData isEqual:[NSNull null]] ) {
        theGroup.users = [self findFakeUsers:rawUserData];
    }
    
    if ( ![rawSubGroupData isEqual:[NSNull null]] ) {
        //NSLog(@"no subgroups");
        theGroup.subGroups = [self findFakeSubGroups:rawSubGroupData];
    }
    
    return theGroup;
}

- (AMLiveUser *)createFakeUser:(NSDictionary *)theUser {
    AMLiveUser *fakeUser = [[AMLiveUser alloc] init];
    
    NSString *fakeFullName = [theUser objectForKey:@"FullName"];
    NSString *fakeNickName = [theUser objectForKey:@"NickName"];
    NSString *fakeDescription = [theUser objectForKey:@"Description"];
    
    if (![fakeFullName isEqualToString:@"FullName"]) {
        fakeUser.fullName = fakeFullName;
    } else { fakeUser.fullName = @""; }
    fakeUser.nickName = fakeNickName;
    fakeUser.description = fakeDescription;
    
    NSLog(@"the created user is %@", fakeUser);

    return fakeUser;
}

- (NSMutableArray *)findFakeUsers:(NSArray *)rawUserData {
    
    NSMutableArray *users = [[NSMutableArray alloc] init];

    for (NSDictionary *user in rawUserData) {
        AMLiveUser *theUser = [self createFakeUser:user];
        [users addObject:theUser];
    }
    
    return users;
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
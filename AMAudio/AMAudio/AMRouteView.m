//
//  AMRouteView.m
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


#import "AMRouteView.h"
#import "AMChannel.h"
#import "AMRouteViewController.h"

static NSUInteger kNumberOfChannels = 54;
static CGFloat kChannelRadius = 10.0;
static CGFloat kPlaceholderChannelRadius = 5.0;

@interface AMDevice : NSObject

@property(nonatomic) NSString *deviceID;
@property(nonatomic) NSString *deviceName;
@property(nonatomic) NSRange channelIndexRange;

@end

@implementation AMDevice

@end


@interface AMRouteView ()
{
    NSColor *_backgroundColor;
    NSColor *_placeholderChannelColor;
    NSColor *_sourceChannelColor;
    NSColor *_destinationChannelColor;
    NSColor *_selectedChannelFillColor;
    NSColor *_connectionColor;
    NSColor *_selectedConnectionColor;
    NSPoint _center;
    CGFloat _radius;
    NSMutableArray *_allChannels;
    AMChannel *_selectedChannel;
    AMChannel *_targetChannel;
    NSInteger _selectedConnection[2];
    NSMenu *_contextMenu;
}

@property(nonatomic) NSMutableDictionary *devices;

@end

@implementation AMRouteView

#pragma mark - Overridden Methods

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [self doInit];
    
//    self.delegate = [[AMRouteViewController alloc] init];
//    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:4];
//    for (int i = 0; i < 4; i++) {
//        AMChannel *channel = [[AMChannel alloc] initWithIndex:i];
//        channel.type = (i < 2) ? AMSourceChannel : AMDestinationChannel;
//        channels[i] = channel;
//    }
//    [self associateChannels:channels
//                 withDevice:@"Device1"
//                       name:@"Device 1"];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [_backgroundColor set];
    NSRectFill(self.bounds);
    
    for (AMChannel *channel in self.allChannels) {
        if (channel.type == AMSourceChannel) {
            [channel.peerIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                AMChannel *peerChannle = [self channelAtIndex:idx];
                NSBezierPath *bezierPath = [NSBezierPath bezierPath];
                [bezierPath moveToPoint:[self centerOfChannel:channel]];
                [bezierPath curveToPoint:[self centerOfChannel:peerChannle]
                           controlPoint1:_center
                           controlPoint2:_center];
                bezierPath.lineWidth = 2.0;
                [_connectionColor setStroke];
                [bezierPath stroke];
                if (channel.index == _selectedConnection[0] &&
                    peerChannle.index == _selectedConnection[1]) {
                    bezierPath.lineWidth = 12.0;
                    [_selectedConnectionColor setStroke];
                    [bezierPath stroke];
                }
            }];
        }
    }
    
    for (AMChannel *channel in self.allChannels)
        [self drawChannel:channel WithCenterAt:[self centerOfChannel:channel]];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if (theEvent.modifierFlags & NSControlKeyMask)
        return [self rightMouseDown:theEvent];
    
    if (_selectedConnection[0] != NSNotFound) {
        _selectedConnection[0] = NSNotFound;
        _selectedConnection[1] = NSNotFound;
        self.needsDisplay = YES;
    }
    
    AMChannel *channel = [self testClickOccuredOnChannel:theEvent];
    if (channel) {
        if (channel.type != AMPlaceholderChannel) {
            _selectedChannel = (_selectedChannel == channel) ? nil : channel;
            self.needsDisplay = YES;
        }
        return;
    }
    
    if ([self testClickOccuredOnConnection:theEvent])
        self.needsDisplay = YES;
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    AMChannel *channel = [self testClickOccuredOnChannel:theEvent];
    if (channel && channel.type != AMPlaceholderChannel) {
        if (_selectedChannel && _selectedChannel.type != channel.type &&
            ![_selectedChannel.peerIndexes containsIndex:channel.index]) {
            _targetChannel = channel;
            NSMenuItem *connectMenuItem = [_contextMenu itemAtIndex:0];
            [connectMenuItem setEnabled:YES];
            NSMenuItem *disconnectMenuItem = [_contextMenu itemAtIndex:1];
            [disconnectMenuItem setEnabled:NO];
            [NSMenu popUpContextMenu:_contextMenu withEvent:theEvent forView:self];
            self.needsDisplay = YES;
        }
        return;
    }
    
    if ([self testClickOccuredOnConnection:theEvent]) {
        NSMenuItem *connectMenuItem = [_contextMenu itemAtIndex:0];
        [connectMenuItem setEnabled:NO];
        NSMenuItem *disconnectMenuItem = [_contextMenu itemAtIndex:1];
        [disconnectMenuItem setEnabled:YES];
        [NSMenu popUpContextMenu:_contextMenu withEvent:theEvent forView:self];
    }
}

#pragma mark - Public Methods

- (void)associateChannels:(NSArray *)channels
               withDevice:(NSString *)deviceID
                     name:(NSString *)deviceName
{
    AMDevice *device = [[AMDevice alloc] init];
    device.deviceID = deviceID;
    device.deviceName = deviceName;
    NSUInteger minIndex = 0;
    for (AMChannel *channel in channels) {
        NSAssert(channel.index < kNumberOfChannels, @"channel index out of bound");
        minIndex = MIN(minIndex, channel.index);
        _allChannels[channel.index] = channel;
    }
    device.channelIndexRange = NSMakeRange(minIndex, channels.count);
    self.devices[deviceID] = device;
}

- (AMChannel *)channelAtIndex:(NSUInteger)index
{
    return self.allChannels[index];
}

- (NSArray *)channelsAssociatedWithDevice:(NSString *)deviceID
{
    NSRange range = [self.devices[deviceID] channelIndexRange];
    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:range.length];
    for (NSUInteger i = range.location; i < range.location + range.length; i++)
        [channels addObject:[self channelAtIndex:i]];
    return channels;
}

#pragma mark - Private Methods

- (void)doInit
{
    _allChannels = [NSMutableArray arrayWithCapacity:kNumberOfChannels];
    for (int i = 0; i < kNumberOfChannels; i++)
        _allChannels[i] = [[AMChannel alloc] initWithIndex:i];
    
    _devices = [NSMutableDictionary dictionary];
    
    _selectedConnection[0] = NSNotFound;
    _selectedConnection[1] = NSNotFound;
    
    _contextMenu = [[NSMenu alloc] initWithTitle:@"Contextual Menu"];
    _contextMenu.autoenablesItems = NO;
    [_contextMenu insertItemWithTitle:@"Connect"
                               action:@selector(tryToConnect:)
                        keyEquivalent:@""
                              atIndex:0];
    [_contextMenu insertItemWithTitle:@"Disconnect"
                               action:@selector(tryToDisconnect:)
                        keyEquivalent:@""
                              atIndex:1];
    
    self.postsFrameChangedNotifications = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(frameChanged)
                                                 name:NSViewFrameDidChangeNotification
                                               object:self];
    
    _backgroundColor = [NSColor colorWithCalibratedRed:0.15
                                                 green:0.15
                                                  blue:0.15
                                                 alpha:1.0];
    _placeholderChannelColor = [NSColor grayColor];
    _sourceChannelColor = [NSColor grayColor];
    _destinationChannelColor = [NSColor colorWithCalibratedRed:0.27
                                                         green:0.3686
                                                          blue:0.494
                                                         alpha:1.0];
    _selectedChannelFillColor = [NSColor lightGrayColor];
    _connectionColor = [NSColor greenColor];
    _selectedConnectionColor = [NSColor colorWithCalibratedRed:1.0
                                                         green:1.0
                                                          blue:1.0
                                                         alpha:0.4];
}

- (void)frameChanged
{
    NSRect rect = NSInsetRect(self.bounds, NSWidth(self.bounds) / 16.0,
                              NSHeight(self.bounds) / 16.0);
    _radius = MIN(NSWidth(rect) / 2.0, NSHeight(rect) / 2.0);
    _center = NSMakePoint(NSMidX(rect), NSMidY(rect));
}

- (void)tryToConnect:(id)sender
{
    if ([self.delegate routeView:self
            shouldConnectChannel:_selectedChannel
                       toChannel:_targetChannel]) {
        if ([self.delegate routeView:self
                      connectChannel:_selectedChannel
                           toChannel:_targetChannel]) {
            [_selectedChannel.peerIndexes addIndex:_targetChannel.index];
            [_targetChannel.peerIndexes addIndex:_selectedChannel.index];
            _targetChannel = nil;
            self.needsDisplay = YES;
        }
    }
}

- (void)tryToDisconnect:(id)sender
{
    AMChannel *channel1 = [self channelAtIndex:_selectedConnection[0]];
    AMChannel *channel2 = [self channelAtIndex:_selectedConnection[1]];
    if ([self.delegate routeView:self
          shouldDisonnectChannel:channel1
                     fromChannel:channel2]) {
        if ([self.delegate routeView:self
                   disconnectChannel:channel1
                         fromChannel:channel2]) {
            [channel1.peerIndexes removeIndex:channel2.index];
            [channel2.peerIndexes removeIndex:channel1.index];
            _selectedConnection[0] = NSNotFound;
            _selectedConnection[1] = NSNotFound;
            self.needsDisplay = YES;
        }
    }
}

- (NSPoint)centerOfChannel:(AMChannel *)channel
{
    CGFloat radian = channel.index * 2.0 * M_PI / kNumberOfChannels;
    return NSMakePoint(_radius * cos(radian) + _center.x,
                       _radius * sin(radian) + _center.y);
}

- (void)drawChannel:(AMChannel *)channel WithCenterAt:(NSPoint)p
{
    if (channel.type == AMPlaceholderChannel) {
        NSBezierPath *dot = [NSBezierPath bezierPath];
        [dot appendBezierPathWithArcWithCenter:p
                                        radius:kPlaceholderChannelRadius
                                    startAngle:0
                                      endAngle:360];
        [_placeholderChannelColor setFill];
        [dot fill];
    } else {
        NSColor *color = nil;
        if (channel.type == AMSourceChannel)
            color = _sourceChannelColor;
        else
            color = _destinationChannelColor;
        
        // draw outer circle
        NSBezierPath *outerCircle = [NSBezierPath bezierPath];
        [outerCircle appendBezierPathWithArcWithCenter:p
                                                radius:kChannelRadius
                                            startAngle:0
                                              endAngle:360];
        [_backgroundColor setFill];
        [outerCircle fill];
        outerCircle.lineWidth = 2.0;
        [color setStroke];
        [outerCircle stroke];
        
        // draw inner circle
        NSBezierPath *innerCircle = [NSBezierPath bezierPath];
        [innerCircle appendBezierPathWithArcWithCenter:p
                                                radius:kChannelRadius - 4.0
                                            startAngle:0
                                              endAngle:360];
        innerCircle.lineWidth = 1.0;
        if (_selectedChannel == channel) {
            [_selectedChannelFillColor setFill];
            [innerCircle fill];
        } else {
            [innerCircle stroke];
        }
    }
}

- (AMChannel *)testClickOccuredOnChannel:(NSEvent *)mouseUpEvent
{
    NSPoint p = [self convertPoint:mouseUpEvent.locationInWindow
                          fromView:nil];
    CGFloat r = hypot(p.x - _center.x, p.y - _center.y);
    if (fabs(r - _radius) >= kChannelRadius)
        return nil;
    CGFloat theta = atan2(p.y - _center.y, p.x - _center.x);
    if (theta < 0)
        theta += 2 * M_PI;
    int channelIndex = (int)(theta * kNumberOfChannels / (2.0 * M_PI) + 0.5) % kNumberOfChannels;
    AMChannel *channel = [self channelAtIndex:channelIndex];
    NSPoint channelCenter = [self centerOfChannel:channel];
    r = hypot(p.x - channelCenter.x, p.y - channelCenter.y);
    return (r >= kChannelRadius) ? nil : channel;
}

- (BOOL)testClickOccuredOnConnection:(NSEvent *)mouseUpEvent
{
    NSPoint p = [self convertPoint:[mouseUpEvent locationInWindow]
                          fromView:nil];
    if (hypot(p.x - _center.x, p.y - _center.y) >= (_radius - kChannelRadius))
        return NO;
    for (AMChannel *channel in self.allChannels) {
        if (channel.type == AMSourceChannel) {
            [channel.peerIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                AMChannel *peerChannle = [self channelAtIndex:idx];
                CGPoint channelCenter = NSPointToCGPoint([self centerOfChannel:channel]);
                CGPoint peerChannleCenter = NSPointToCGPoint([self centerOfChannel:peerChannle]);
                
                CGMutablePathRef bezierPath = CGPathCreateMutable();
                CGPathMoveToPoint(bezierPath, NULL, channelCenter.x, channelCenter.y);
                CGPathAddCurveToPoint(bezierPath, NULL, _center.x, _center.y, _center.x,
                                      _center.y, peerChannleCenter.x, peerChannleCenter.y);
                CGPathRef hitTestArea = CGPathCreateCopyByStrokingPath(bezierPath, NULL,
                                                                       20.0, NSButtLineCapStyle, NSRoundLineJoinStyle, 10.0);
                CGPathRelease(bezierPath);
                if (CGPathContainsPoint(hitTestArea, NULL, p, false)) {
                    _selectedConnection[0] = channel.index;
                    _selectedConnection[1] = peerChannle.index;
                    *stop = YES;
                }
                CGPathRelease(hitTestArea);
            }];
            if (_selectedConnection[0] != NSNotFound)
                return YES;
        }
    }
    
    return NO;
}

+(NSUInteger)maxChannels
{
    return kNumberOfChannels;
}

@end

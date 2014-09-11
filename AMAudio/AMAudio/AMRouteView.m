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
#import "NSBezierPath+QuartzUtilities.h"

typedef struct GlyphArcInfo {
	CGFloat	width;
	CGFloat	angle;	// in radians
} GlyphArcInfo;

static GlyphArcInfo *
CreateGlyphArcInfo(CTLineRef line, CGFloat radius)
{
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    GlyphArcInfo *glyphArcInfo = (GlyphArcInfo *)calloc(glyphCount, sizeof(GlyphArcInfo));
    
	NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);
	CFIndex glyphOffset = 0;
	for (id run in runArray) {
		CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);
        CGGlyph glyphs[runGlyphCount];
        CTRunGetGlyphs((__bridge CTRunRef)run, CFRangeMake(0, 0), glyphs);
		for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            CFIndex index = glyphOffset + runGlyphIndex;
			glyphArcInfo[index].width = CTRunGetTypographicBounds((__bridge CTRunRef)run,
                                            CFRangeMake(runGlyphIndex, 1), NULL, NULL, NULL);
		}
        
		glyphOffset += runGlyphCount;
	}
    
	//double lineLength = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
	CGFloat prevHalfWidth = glyphArcInfo[0].width / 2.0;
	glyphArcInfo[0].angle = prevHalfWidth / radius;
	for (CFIndex lineGlyphIndex = 1; lineGlyphIndex < glyphCount; lineGlyphIndex++) {
		CGFloat halfWidth = glyphArcInfo[lineGlyphIndex].width / 2.0;
		CGFloat prevCenterToCenter = prevHalfWidth + halfWidth;
		glyphArcInfo[lineGlyphIndex].angle = prevCenterToCenter / radius;
		prevHalfWidth = halfWidth;
	}
    
    return glyphArcInfo;
}


#define todegree(radius)  ((radius) * 360.0 / (2.0 * M_PI))

static NSUInteger kNumberOfChannels = 72;
static CGFloat kChannelRadius = 10.0;
static CGFloat kPlaceholderChannelRadius = 5.0;
static CGFloat kCloseButtonRadius = 0.0;

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
    NSColor *_deviceLableColor;
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
    
    //self.delegate = [[AMRouteViewController alloc] init];
    NSMutableArray *channels = [NSMutableArray arrayWithCapacity:4];
    NSMutableArray* channels2 = [NSMutableArray arrayWithCapacity:4];
    for (int i = 0; i < 4; i++) {
        AMChannel *channel = [[AMChannel alloc] initWithIndex:i];
        channel.type = (i < 2) ? AMSourceChannel : AMDestinationChannel;
        channels[i] = channel;
    }
    
//    for (int i = 8; i < 12; i++) {
//        AMChannel *channel = [[AMChannel alloc] initWithIndex:i];
//        channel.type = (i < 10) ? AMSourceChannel : AMDestinationChannel;
//        channels2[i-8] = channel;
//    }
    [self associateChannels:channels
                 withDevice:@"Device1"
                       name:@"GarageBand"];
//    [self associateChannels:channels2
//                 withDevice:@"Device2"
//                       name:@"Device2"];

}

- (void)drawRect:(NSRect)dirtyRect
{
    [_backgroundColor set];
    NSRectFill(self.bounds);
    
    [self drawDeviceLabel];
    
    for (AMChannel *channel in self.allChannels) {
        if (channel.type == AMSourceChannel) {
            [channel.peerIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                AMChannel *peerChannle = [self channelAtIndex:idx];
                NSBezierPath *bezierPath = [self bezierPathFromChannel:channel
                                                             toChannel:peerChannle];
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
    _deviceLableColor = [NSColor colorWithCalibratedRed:0.27
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

- (NSBezierPath *)bezierPathFromChannel:(AMChannel *)channel1
                              toChannel:(AMChannel *)channel2
{
    NSBezierPath *bezierPath = [NSBezierPath bezierPath];
    [bezierPath moveToPoint:[self centerOfChannel:channel1]];
    [bezierPath curveToPoint:[self centerOfChannel:channel2]
               controlPoint1:_center
               controlPoint2:_center];
    return bezierPath;
}

- (void)drawDeviceLabel
{
    // draw device circle
    CGFloat radius = _radius + 25.0;
    NSBezierPath *circle = [NSBezierPath bezierPath];
    [circle appendBezierPathWithArcWithCenter:_center
                                       radius:radius
                                   startAngle:3.75
                                     endAngle:363.75];
    CGFloat lineDash[2];
    lineDash[0] = 0.8 * kChannelRadius;
    lineDash[1] = radius * 2.0 * M_PI / kNumberOfChannels - lineDash[0];
    [circle setLineDash:lineDash
                  count:sizeof(lineDash) / sizeof(lineDash[0])
                  phase:0.0];
    circle.lineWidth = 2.0;
    [_deviceLableColor set];
    [circle stroke];
    
    // draw device lables
    for (NSString *deviceID in self.devices) {
        AMDevice *device = self.devices[deviceID];
        NSRange indexRange = device.channelIndexRange;
        NSInteger startIndex = indexRange.location;
        NSInteger endIndex = startIndex + indexRange.length;
        CGFloat startAngle = (startIndex - 0.5) * 2.0 * M_PI / kNumberOfChannels;
        CGFloat endAngle = (endIndex - 0.5) * 2.0 * M_PI / kNumberOfChannels;
        
        // draw cd line
        NSBezierPath *cdLine = [NSBezierPath bezierPath];
        [cdLine moveToPoint:NSMakePoint((radius - 8.0) * cos(startAngle) + _center.x,
                                        (radius - 8.0) * sin(startAngle) + _center.y)];
        [cdLine lineToPoint:NSMakePoint((radius + 8.0) * cos(startAngle) + _center.x,
                                        (radius + 8.0) * sin(startAngle) + _center.y)];
        [cdLine moveToPoint:NSMakePoint((radius - 8.0) * cos(endAngle) + _center.x,
                                        (radius - 8.0) * sin(endAngle) + _center.y)];
        [cdLine lineToPoint:NSMakePoint((radius + 8.0) * cos(endAngle) + _center.x,
                                        (radius + 8.0) * sin(endAngle) + _center.y)];
        cdLine.lineWidth = 1.0;
        [cdLine stroke];
        
        // draw lable
        CGFloat arcLength = radius * (endAngle - startAngle);
        CGFloat maxTextWidth = arcLength - 30.0 - kCloseButtonRadius;
        if (maxTextWidth <= 20)
            continue;
        
        NSDictionary *attributes = @{
            NSForegroundColorAttributeName : _deviceLableColor,
            NSFontAttributeName : [NSFont fontWithName:@"HelveticaNeue" size:11.0]
        };
        NSAttributedString *label =
            [[NSAttributedString alloc] initWithString:device.deviceName
                                            attributes:attributes];
        CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)label);
        CGFloat textWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
        if (textWidth > maxTextWidth) {
            NSAttributedString *truncationTokenString =
                [[NSAttributedString alloc] initWithString:@"…"
                                            attributes:attributes];
            CTLineRef truncationToken = CTLineCreateWithAttributedString(
                            (__bridge CFAttributedStringRef)truncationTokenString);
            CTLineRef truncatedLine = CTLineCreateTruncatedLine(line, maxTextWidth,
                                            kCTLineTruncationEnd, truncationToken);
            CFRelease(line);
            line = truncatedLine;
            CFRelease(truncationToken);
            textWidth = CTLineGetTypographicBounds(line, NULL, NULL, NULL);
        }
        
        // align text to arc center
        CGFloat angleAdjust = ((arcLength - kCloseButtonRadius - textWidth) / 2.0) / radius;
        endAngle -= angleAdjust;
        startAngle += angleAdjust + kCloseButtonRadius / radius;
        
        NSBezierPath *textPath = [NSBezierPath bezierPath];
        [textPath appendBezierPathWithArcWithCenter:_center
                                             radius:radius
                                         startAngle:todegree(startAngle) - 1.0
                                           endAngle:todegree(endAngle) + 1.0];
        textPath.lineWidth = 20.0;
        [_backgroundColor set];
        [textPath stroke];

        CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, _center.x, _center.y);
        CGContextRotateCTM(context, endAngle - M_PI_2);
        
        CGPoint textPosition = CGPointMake(0.0, radius);
        CGContextSetTextPosition(context, textPosition.x, textPosition.y);
        
        GlyphArcInfo *glyphArcInfo = CreateGlyphArcInfo(line, radius);
        NSArray *runArray = (__bridge NSArray *)CTLineGetGlyphRuns(line);
        CFIndex glyphOffset = 0;
        for (id run in runArray) {
            CFIndex runGlyphCount = CTRunGetGlyphCount((__bridge CTRunRef)run);
            for (CFIndex runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
                CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
                CFIndex index = runGlyphIndex + glyphOffset;
                CGContextRotateCTM(context, -(glyphArcInfo[index].angle));
                CGFloat glyphWidth = glyphArcInfo[index].width;
                CGFloat halfGlyphWidth = glyphWidth / 2.0;
                CGPoint positionForThisGlyph = CGPointMake(textPosition.x - halfGlyphWidth,
                                                           textPosition.y);
                textPosition.x -= glyphWidth;
                CGAffineTransform textMatrix = CTRunGetTextMatrix((__bridge CTRunRef)run);
                textMatrix.tx = positionForThisGlyph.x;
                textMatrix.ty = positionForThisGlyph.y;
                CGContextSetTextMatrix(context, textMatrix);
                CTRunDraw((__bridge CTRunRef)run, context, glyphRange);
            }
        }
 
        CFRelease(line);
        free(glyphArcInfo);
        CGContextRestoreGState(context);
    }
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
                NSBezierPath *bezierPath = [self bezierPathFromChannel:channel
                                                             toChannel:peerChannle];
                CGPathRef quartzBezierPath = [bezierPath quartzPath:NO];
                CGPathRef hitTestArea = CGPathCreateCopyByStrokingPath(quartzBezierPath,
                                NULL, 20.0, NSButtLineCapStyle, NSRoundLineJoinStyle, 10.0);
                CGPathRelease(quartzBezierPath);
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

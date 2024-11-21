#import "AMP2PVideoView.h"

@implementation AMP2PVideoView

- (void)setupVideoLayer {
    self.videoLayer = [AVSampleBufferDisplayLayer new];
    self.videoLayer.bounds = self.bounds;
    self.videoLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.videoLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    CMTimebaseRef controlTimebase;
    CMTimebaseCreateWithMasterClock( CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase);

    self.videoLayer.controlTimebase = controlTimebase;
    CMTimebaseSetTime(self.videoLayer.controlTimebase, kCMTimeZero);
    CMTimebaseSetRate(self.videoLayer.controlTimebase, 1.0);

    self.videoLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;

    [self setWantsLayer:YES];
    [self.layer addSublayer:self.videoLayer];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        [self setupVideoLayer];
    }

    return self;
}

- (instancetype)init{
    self = [super init];
    
    if (self) {
        [self setupVideoLayer];
    }
    
    return self;
}


@end

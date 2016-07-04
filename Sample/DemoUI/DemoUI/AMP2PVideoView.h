#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface AMP2PVideoView : NSView

@property (nonatomic, strong) AVSampleBufferDisplayLayer * videoLayer;

@end

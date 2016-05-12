#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoView : NSView

@property (nonatomic, strong) AVSampleBufferDisplayLayer * videoLayer;

@end

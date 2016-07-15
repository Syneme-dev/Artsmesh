//
//  AMP2PVideoReceiver.h
//  Artsmesh
//
//  Created by Whisky Zed on 167/15/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AMP2PVideoReceiver : NSObject

-(BOOL) registerP2PVideoLayer:(AVSampleBufferDisplayLayer*) layer
                     withPort:(NSString*) port;



@end

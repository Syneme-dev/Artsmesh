//
//  AMP2PVideoCommon.h
//  Artsmesh
//
//  Created by Whisky Zed on 167/4/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#ifndef AMP2PVideoCommon_h
#define AMP2PVideoCommon_h

NSString *const naluTypesStrings[];

typedef NS_ENUM(NSUInteger, AMP2PVideoState){
    AMP2PVideoStart,
    AMP2PVideoStop,
};

extern NSString* const AMP2PVideoStartNotification;
extern NSString* const AMP2PVideoStopNotification;
extern NSString* const AMP2PVideoInfoNotification;
#endif /* AMP2PVideoCommon_h */

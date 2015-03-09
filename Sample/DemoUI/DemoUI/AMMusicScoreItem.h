//
//  AMMusicScoreItem.h
//  DemoUI
//
//  Created by whiskyzed on 1/20/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMMusicScoreItem : NSObject

@property (nonatomic, assign)   BOOL        selected;
@property (nonatomic, retain)   NSImage*    image;
@property (nonatomic, copy)     NSString*   name;
@property (nonatomic)           NSSize      size;
@end

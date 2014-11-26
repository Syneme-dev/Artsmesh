//
//  AMAudioSlider.h
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AMAudioSlider;

@protocol AMAudioSliderDelegate <NSObject>

-(void)slider:(AMAudioSlider *)slider ValueChanged:(float)value;

@end

@interface AMAudioSlider : NSView

@property NSRange valueRange;
@property float value;
@property (weak) id<AMAudioSliderDelegate> delegate;

@end

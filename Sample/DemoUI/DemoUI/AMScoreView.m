//
//  AMScoreView.m
//  Artsmesh
//
//  Created by whiskyzed on 3/23/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMScoreView.h"
#import "UIFramework/AMCollectionView.h"
#import "UIFramework/AMCollectionViewCell.h"

#import "AMNowBarView.h"

@interface AMScoreView()
{
    AMCollectionView*   _collectionView;
    AMNowBarView*       _nowBarView;
}
@end

@implementation AMScoreView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) addMusicScore : (NSImage*) image
{
    AMCollectionViewCell *imageCell = [[AMCollectionViewCell alloc]
                                       initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
        imageCell.image = image;
        imageCell.imageScaling = NSImageScaleNone;
        [_collectionView addViewItem:imageCell];
}

- (void) removeMusicScore
{
    [_collectionView removeSelectedItem];
}

//static void AMScoreViewCommonInit(AMScoreView* scoreView)

-(id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self == nil) {
        return nil;
    }
    //init nowBar View
    NSRect bounds = [self bounds];
    
    NSRect nowBarRect = NSMakeRect(bounds.size.width/3, 0, 3, bounds.size.height);
    _nowBarView = [[AMNowBarView alloc] initWithFrame:nowBarRect];
    
    _collectionView = [[AMCollectionView alloc] initWithFrame:bounds];
    _collectionView.itemGap = 10;
    _collectionView.selectable = YES;
    
    [self addSubview:_collectionView];

  
    NSString *hConstrain = [NSString stringWithFormat:@"H:|-0-[_collectionView]-0-|"];
    NSString *vConstrain = [NSString stringWithFormat:@"V:|-20-[_collectionView(==%f)]", 480.0];
    
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView);
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:hConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:vConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
    

    [self addSubview:_nowBarView];
    //add the nowBar and collection view to subviews
//    [self addSubview:_collectionView];
//    [self addSubview:_nowBarView];
        
    
     
    return self;
}





@end

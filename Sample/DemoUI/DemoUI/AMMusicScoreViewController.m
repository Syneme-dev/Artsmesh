//
//  AMMusicScoreViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMusicScoreViewController.h"
#import "AMMusicScoreItem.h"
#import "UIFramework/AMCollectionView.h"
#import "UIFramework/NSView_Constrains.h"

NSString * const AMMusicScoreItemType = @"com.artmesh.musicscore";

@interface AMMusicScoreViewController ()
{
    NSMutableArray*     musicScoreItems;
    AMCollectionView    *_collectionView;
}

@end

@implementation AMMusicScoreViewController

- (void) awakeFromNib
{
    NSRect rect = NSMakeRect(0, 0, self.view.bounds.size.width, 480);
    _collectionView = [[AMCollectionView alloc] initWithFrame:rect];
    _collectionView.itemGap = 10;
    
    [self.view addSubview:_collectionView];
    
    NSString *hConstrain = [NSString stringWithFormat:@"H:|-0-[_collectionView]-0-|"];
    NSString *vConstrain = [NSString stringWithFormat:@"V:|-20-[_collectionView(==%f)]", 480.0];
    
    [_collectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(_collectionView);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:hConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:vConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        musicScoreItems = [[NSMutableArray alloc] init];
    }
    return self;
}


- (IBAction)addMusicScoreItem:(id)sender
{
    __block NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:[NSImage imageTypes]];
    
    [panel beginSheetModalForWindow:[self.view window]
                  completionHandler:^(NSInteger result){
                      if(result == NSOKButton){
                          NSImage* image = [[NSImage alloc]
                                            initWithContentsOfURL:[panel URL]];
                          
                          [musicScoreItems addObject:image];
                          
                      }
                      
                      panel = nil;
                      dispatch_async(dispatch_get_main_queue(), ^{
                          
                          [_collectionView removeAllItems];
                          
                          for (NSImage *image in musicScoreItems) {
                              NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
                              imageView.image = image;
                              imageView.imageScaling = NSImageScaleNone;
                              [_collectionView addViewItem:imageView];
                          }
                      });
                  }];
}



@end

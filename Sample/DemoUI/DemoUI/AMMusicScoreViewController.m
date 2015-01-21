//
//  AMMusicScoreViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMusicScoreViewController.h"
#import "AMMusicScoreItem.h"

@interface AMMusicScoreViewController ()<NSCollectionViewDelegate>
{
    NSMutableArray*  musicScoreItems;
}
@property (weak) IBOutlet NSCollectionView* collectionView;
@end

@implementation AMMusicScoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        musicScoreItems = [[NSMutableArray alloc] init];
        self.collectionView.delegate = self;
        [self.collectionView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
        

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
                          
                          AMMusicScoreItem *item = [[AMMusicScoreItem alloc] init];
                          //   NSImage *image = [[NSWorkspace sharedWorkspace]iconForFile:fullPath];
                          item.image = image;
                          item.name = @" ";
                          [musicScoreItems addObject:item];
                          
                          
                          
                      }
                      panel = nil;
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [_collectionView setContent:musicScoreItems];
                      });
                  }];

}

@end

@implementation AMMusicScoreBox
- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this NSBox
    return nil;
}
@end

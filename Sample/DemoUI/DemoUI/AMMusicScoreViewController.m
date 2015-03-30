//
//  AMMusicScoreViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMusicScoreViewController.h"
//#import "UIFramework/AMCollectionViewCell.h"
#import "AMScoreCollectionCell.h"
#import "AMScoreCollectionView.h"
#import "UIFramework/NSView_Constrains.h"
#import "UIFramework/AMButtonHandler.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"

NSString * const AMMusicScoreItemType = @"com.artmesh.musicscore";

@interface AMMusicScoreViewController () <AMCheckBoxDelegeate, NSTextFieldDelegate>
{
    NSMutableArray*             musicScoreItems;
    AMScoreCollectionView*      _collectionView;
}
@property (weak) IBOutlet AMCheckBoxView *pageModeCheck;
@property (weak) IBOutlet AMCheckBoxView *scrollModeCheck;
@property (weak) IBOutlet AMFoundryFontView *ppsField;


@end

@implementation AMMusicScoreViewController

- (void) awakeFromNib
{
    [AMButtonHandler changeTabTextColor:self.removeScoreBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.loadScoreBtn toColor:UI_Color_blue];
    
    NSRect rect = NSMakeRect(0, 0, self.view.bounds.size.width, 480);
    _collectionView = [[AMScoreCollectionView alloc] initWithFrame:rect];
    _collectionView.itemGap = 10;
    _collectionView.selectable = YES;
    
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
    
    

    self.pageModeCheck.delegate = self;
    [self.pageModeCheck setChecked:NO];
    [self.pageModeCheck setTitle:@"Page Mode"];
    
    self.scrollModeCheck.delegate = self;
    [self.scrollModeCheck setChecked:YES];
    [self.scrollModeCheck setTitle:@"Scroll Mode"];
    
    self.ppsField.delegate = self;
    
    [self onChecked:self.scrollModeCheck];
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

- (IBAction)removeMusicScoreItem:(id)sender {
    [_collectionView removeSelectedItem];
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
                          
                            for (NSImage *image in musicScoreItems)
                            {
                              AMScoreCollectionCell *imageCell = [[AMScoreCollectionCell alloc] initWithFrame:NSMakeRect(0, 0, image.size.width, image.size.height)];
                              imageCell.image = image;
                              imageCell.imageScaling = NSImageScaleNone;
                              [_collectionView addViewItem:imageCell];
                              imageCell = nil;
                          }
                          
                          [musicScoreItems removeAllObjects];
                      });
                  }];
}

//Don't allow pageMode and scrollMode CheckBox both on at the same time.
- (void) onChecked:(AMCheckBoxView *)sender
{
    if(sender == self.scrollModeCheck)
    {
        if ([self.pageModeCheck checked]) {
            [self.pageModeCheck setChecked:NO];
        }
        if ([sender checked]) {
            [_collectionView setMode:0];
            self.ppsField.stringValue = [NSString stringWithFormat:@"%.0f",
                                         _collectionView.scrollDelta];
        }
    }
    else if (sender == self.pageModeCheck) {
        if ([self.scrollModeCheck checked]) {
            [self.scrollModeCheck setChecked:NO];
        }
        if ([sender checked]) {
            [_collectionView setMode:1];
            self.ppsField.stringValue = [NSString stringWithFormat:@"%.0f",
                                         _collectionView.timeInterval];
        }
    }
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    if ([self.scrollModeCheck checked]) {
        _collectionView.scrollDelta = [self.ppsField intValue];
    }
    else if([self.pageModeCheck checked]){
        _collectionView.timeInterval = [self.ppsField intValue];
    }
}




@end

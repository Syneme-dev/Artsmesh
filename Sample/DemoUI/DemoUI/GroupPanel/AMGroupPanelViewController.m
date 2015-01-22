//
//  AMGroupPanelViewController.m
//  DemoUI
//
//  Created by Wei Wang on 6/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "NSView_Constrains.h"


@interface AMGroupPanelViewController ()<NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (weak) IBOutlet NSButton *archiveBtn;
@property (weak) IBOutlet NSButton *liveBtn;
@property (weak) IBOutlet NSButton *localBtn;
@property (weak) IBOutlet NSTabView *groupTabView;

@end

@implementation AMGroupPanelViewController
{
    NSViewController* _detailViewController;
    NSMutableArray *_tabControllers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    [AMButtonHandler changeTabTextColor:self.archiveBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.liveBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.localBtn toColor:UI_Color_blue];
}

-(void)registerTabButtons
{
    //super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.localBtn];
    [self.tabButtons addObject:self.liveBtn];
    [self.tabButtons addObject:self.archiveBtn];
    self.showingTabsCount=3;
}

-(void)viewDidLoad
{
    [self loadTabViews];
}

-(void)loadTabViews
{
    for (NSTabViewItem* tabItem in [self.groupTabView tabViewItems]) {
        
        /*Here we use the class name to load the controller so the
        tab identifier must equal to the tabview's subview controller's name*/
    
        if (_tabControllers == nil) {
            _tabControllers = [[NSMutableArray alloc] init];
        }
        
        NSString *tabViewControllerName = tabItem.identifier;
        id obj = [[NSClassFromString(tabViewControllerName) alloc] init];
        if ([obj isKindOfClass:[NSViewController class]]) {
            NSViewController *controller = (NSViewController *)obj;
            
            [tabItem.view addFullConstrainsToSubview:controller.view];
            [_tabControllers addObject:controller];
        }
    }
}


- (IBAction)archiveBtnClick:(id)sender
{
    [self.groupTabView selectTabViewItemWithIdentifier:@"AMArchiveGroupViewController"];
}


- (IBAction)liveBtnClick:(id)sender
{
    [self.groupTabView selectTabViewItemWithIdentifier:@"AMLiveGroupViewController"];
}


- (IBAction)localBtnClick:(id)sender
{
    [self.groupTabView selectTabViewItemWithIdentifier:@"AMLocalGroupViewController"];
}


-(void)dealloc
{

}

@end

//
//  AMStaticGroupDataSource.m
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupDataSource.h"
#import "AMStaticGroupOutlineCellViewController.h"
#import "AMStaticGroupOutlineCellView.h"
#import "AMGroupOutlineRowView.h"

@implementation AMStaticGroupDataSource

-(void)doubleClickOutlineView:(id)sender
{
    if([sender isKindOfClass:[NSOutlineView class]]){
        NSOutlineView* ov = (NSOutlineView*)sender;
        NSInteger selected = [ov selectedRow];
        
        if (selected < 0){
            return;
        }
        
        AMStaticGroupOutlineCellView *selectedCellView = [ov viewAtColumn:0 row:selected makeIfNecessary:YES];
        [selectedCellView.infoBtn performClick:selectedCellView.infoBtn];
    }
}

-(void)reloadGroups
{
//    AMStatusNetModule* module = [[AMStatusNetModule alloc] init];
//    
//    [module getGroupsOnStatusNet:@"http://artsmesh.io/api/statusnet/groups/list_all.json" completionBlock:^(NSData* response, NSError* error){
//        if (error ==nil && response != nil) {
//            NSArray* staticGroups  = [AMStatusNetGroupParser parseStatusNetGroups:response];
//            NSMutableArray* staticGroupControllers = [[NSMutableArray alloc] init];
//            
//            for (AMStatusNetGroup* group in staticGroups) {
//                AMStaticGroupOutlineCellViewController* staticGroupController = [[AMStaticGroupOutlineCellViewController alloc] initWithNibName:@"AMStaticGroupOutlineCellViewController" bundle:nil];
//                staticGroupController.staticGroup = group;
//                
//                [staticGroupControllers addObject:staticGroupController];
//            }
//            
//            self.staticGroups = staticGroupControllers;
//        }
//    }];
}


- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return  [self.staticGroups count];
    }else{
        return  0;
    }
    
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    long i =  [self outlineView:outlineView numberOfChildrenOfItem:item];
    return i > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if(index < [self.staticGroups count])
    {
        return self.staticGroups[index];
    }
    
    return nil;
}


- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    if ([item isKindOfClass:[AMStaticGroupOutlineCellViewController class]]) {
        AMStaticGroupOutlineCellViewController* groupController = (AMStaticGroupOutlineCellViewController*)item;
        [groupController updateUI];
        [groupController setTrackArea];
        
        return groupController.view;
    }

    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    if ([item isKindOfClass:[NSViewController class]]) {
        NSViewController* controller = (NSViewController*) item;
        NSView* cellView = controller.view;
        
        return cellView.frame.size.height;
    }
    
    return 0.0;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    AMGroupOutlineRowView* rowView = [[AMGroupOutlineRowView alloc] init];
    return rowView;
}

@end

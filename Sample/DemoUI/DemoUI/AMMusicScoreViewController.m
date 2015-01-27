//
//  AMMusicScoreViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMMusicScoreViewController.h"
#import "AMMusicScoreItem.h"

NSString * const AMMusicScoreItemType = @"com.artmesh.musicscore";

@interface AMMusicScoreViewController ()<NSCollectionViewDelegate>
{
    NSMutableArray*     musicScoreItems;
}
@property (weak) IBOutlet NSScrollView *scrollView;
@property (weak) IBOutlet NSCollectionView* collectionView;
@end

@implementation AMMusicScoreViewController

- (void) awakeFromNib
{
     self.collectionView.delegate = self;
    [self.collectionView setDraggingSourceOperationMask:NSDragOperationMove forLocal:YES];
    [self.collectionView registerForDraggedTypes:@[AMMusicScoreItemType]];
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
                          
                          AMMusicScoreItem *item = [[AMMusicScoreItem alloc] init];
                          item.image = image;
                          item.name = @" ";
                          item.size = [image size];
                          [musicScoreItems addObject:item];        
                      }
                      panel = nil;
                      
                      dispatch_async(dispatch_get_main_queue(), ^{
                          [_collectionView setContent:musicScoreItems];
                          [self arrangeItems];
                      });
                  }];
    }

- (void) arrangeItems
{
    NSArray* array = [_collectionView content];
    int deltaX = 0;

    for (int index = 0; index < [array count]; index++)
    {
        AMMusicScoreItem* msItem = [musicScoreItems  objectAtIndex:index];
        NSCollectionViewItem* cvItem = [_collectionView itemAtIndex:index];
        NSView* itemView = [cvItem view];
        NSRect itemRect= [itemView frame];
        itemRect.size.width  = msItem.size.width;
        itemRect.size.height = msItem.size.height;
        
        itemRect.origin.x += deltaX;
        
        deltaX += msItem.size.width;
        [itemView setFrame:itemRect];
    }
    
    if([array count] > 0){
        NSRect collectRect = [_collectionView frame];
        collectRect.size.width = deltaX;
       [self.scrollView.contentView setFrame:collectRect];
        
     /*
        NSSize scrollViewSize = [NSScrollView frameSizeForContentSize:collectRect.size
                                              horizontalScrollerClass:nil
                                                verticalScrollerClass:nil
                                                           borderType:_collectionView.enclosingScrollView.borderType
                                                          controlSize:NSRegularControlSize
                                                        scrollerStyle:_collectionView.enclosingScrollView.scrollerStyle];
      */
    }
    
   
    
}


// This method is called after it has been determined that a drag should begin, but before the drag has been started.
// To refuse the drag, return NO. To start the drag, declare the pasteboard types that you support with -
//  [NSPasteboard declareTypes:owner:], place your data for the items at the given indexes on the pasteboard,
// and return YES from the method. The drag image and other drag related information will be set up and
// provided by the view once this call returns YES. You need to implement this method for your collection view
// to be a drag source.
// -------------------------------------------------------------------------------
//	collectionView:writeItemsAtIndexes:indexes:pasteboard
//
//	Collection view drag and drop
//  User must click and hold the item(s) to perform a drag.
// -------------------------------------------------------------------------------
- (BOOL)collectionView:(NSCollectionView *)cv writeItemsAtIndexes:(NSIndexSet *)indexes toPasteboard:(NSPasteboard *)pasteboard
{
  
    NSData *indexData = [NSKeyedArchiver archivedDataWithRootObject:indexes];
    [pasteboard setData:indexData forType:AMMusicScoreItemType];
    // Here we temporarily store the index of the Cell,
    // being dragged to pasteboard.
    
    return YES;
}



/* This method is used by the collection view to determine a valid drop target. Based on the mouse position, the collection view will suggest a proposed index and drop operation. These values are in/out parameters and can be changed by the delegate to retarget the drop operation. The collection view will propose NSCollectionViewDropOn when the dragging location is closer to the middle of the item than either of its edges. Otherwise, it will propose NSCollectionViewDropBefore. You may override this default behavior by changing proposedDropOperation or 0. This method must return a value that indicates which dragging operation the data source will perform. It must return something other than NSDragOperationNone to accept the drop.
 
 Note: to receive drag messages, you must first send -registerForDraggedTypes: to the collection view with the drag types you want to support (typically this is done in -awakeFromNib). You must implement this method for your collection view to be a drag destination.*/
- (NSDragOperation)collectionView:(NSCollectionView *)collectionView
                     validateDrop:(id <NSDraggingInfo>)draggingInfo
                    proposedIndex:(NSInteger *)proposedDropIndex
                    dropOperation:(NSCollectionViewDropOperation *)proposedDropOperation
{
/*    
    NSPasteboard *pBoard = [draggingInfo draggingPasteboard];
    NSData *indexData = [pBoard dataForType:AMMusicScoreItemType];
    NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:indexData];
    NSInteger draggedCell = [indexes firstIndex];
    
    if(*proposedDropIndex == draggedCell)
    {
        return NSDragOperationNone;
    }
 */
    
    return NSDragOperationMove;
}




/* This method is called when the mouse is released over a collection view that previously decided to allow a drop via the above validateDrop method. At this time, the delegate should incorporate the data from the dragging pasteboard and update the collection view's contents. You must implement this method for your collection view to be a drag destination.
 
 Multi-image drag and drop: If draggingInfo.animatesToDestination is set to YES, you should enumerate and update the dragging items with the proper image components and frames so that they dragged images animate to the proper locations.
 */
//You have only implemented the delegate methods but there s no logic in some of the methods.
//For example to drag around a Collection Item I would add below logic :
- (BOOL)collectionView:(NSCollectionView *)collectionView
            acceptDrop:(id <NSDraggingInfo>)draggingInfo
                 index:(NSInteger)index
         dropOperation:(NSCollectionViewDropOperation)dropOperation
{
    NSPasteboard *pBoard = [draggingInfo draggingPasteboard];
    NSData *indexData = [pBoard dataForType:AMMusicScoreItemType];
    NSIndexSet *indexes = [NSKeyedUnarchiver unarchiveObjectWithData:indexData];
    NSInteger draggedCell = [indexes firstIndex];
    // Now we know the Original Index (draggedCell) and the
    // index of destination (index). Simply swap them in the collection view array.
    if(draggedCell != index){
        [musicScoreItems exchangeObjectAtIndex:index withObjectAtIndex:draggedCell];
        [collectionView setContent:musicScoreItems];
    }
    
    return YES;
}


/* Allows the delegate to construct a custom dragging image for the items being dragged. 'indexes' contains the indexes of the items being dragged. 'event' is a reference to the  mouse down event that began the drag. 'dragImageOffset' is an in/out parameter. This method will be called with dragImageOffset set to NSZeroPoint, but it can be modified to re-position the returned image. A dragImageOffset of NSZeroPoint will cause the image to be centered under the mouse. You can safely call -[NSCollectionView draggingImageForItemsAtIndexes:withEvent:offset:] from within this method. You do not need to implement this method for your collection view to be a drag source.

- (NSImage *)collectionView:(NSCollectionView *)collectionView draggingImageForItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event offset:(NSPointPointer)dragImageOffset
{
    
}
 */

// The return value indicates whether the collection view can attempt to initiate a drag for the given event and items.
// If the delegate does not implement this method, the collection view will act as if it returned YES.
- (BOOL)collectionView:(NSCollectionView *)collectionView canDragItemsAtIndexes:(NSIndexSet *)indexes withEvent:(NSEvent *)event
{
    return YES;
}

@end

@implementation AMMusicScoreBox
- (NSView *)hitTest:(NSPoint)aPoint
{
    // don't allow any mouse clicks for subviews in this NSBox
    return nil;
}
@end

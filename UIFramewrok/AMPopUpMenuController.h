//
//  AMPopUpMenuController.h
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AMPopUpMenuDelegate;

@interface AMPopUpMenuController : NSViewController

@property id<AMPopUpMenuDelegate> delegate;

-(void)addItemWithTitle:(NSString*)title;
-(void)insertItemWithTitle:(NSString*)title atIndex:(NSInteger)index;
-(void)removeAllItems;
-(void)addItemsWithTitles:(NSArray*)titles;

-(void)selectItemAtInedex:(NSUInteger)index;
-(NSUInteger)itemCount;

@end


@protocol AMPopUpMenuDelegate <NSObject>

-(void)itemSelected:(NSString*)itemTitle;
-(CGFloat)popupItemWidth;
-(CGFloat)popupItemHeight;

@end


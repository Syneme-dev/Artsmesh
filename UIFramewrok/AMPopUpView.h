//
//  AMPopUpView.h
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AMPopUpViewDelegeate;

@interface AMPopUpView : NSControl

@property NSFont* font;
@property NSColor* textColor;
@property NSColor* backgroupColor;
@property NSColor* mouseOverColor;
@property CGFloat itemHeight;
@property CGFloat itemWidth;

@property id<AMPopUpViewDelegeate> delegate;

-(NSString*)stringValue;

-(void)addItemWithTitle:(NSString*)title;
-(void)insertItemWithTitle:(NSString*)title atIndex:(NSInteger)index;
-(void)removeAllItems;
-(void)addItemsWithTitles:(NSArray*)titles;

-(void)selectItemAtIndex:(NSUInteger)index;
-(void)selectItemWithTitle:(NSString*)title;
-(NSUInteger)itemCount;

@end

@protocol AMPopUpViewDelegeate <NSObject>

-(void)itemSelected:(AMPopUpView*)sender;

@end

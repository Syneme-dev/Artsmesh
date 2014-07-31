//
//  AMPopUpMenuController.m
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMPopUpMenuController.h"
#import "AMPopUpMenuItem.h"

@interface AMPopUpMenuController ()<AMPopUpMenuItemDelegeate>

@end

@implementation AMPopUpMenuController
{
    NSMutableArray* _menuItems;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(NSMutableArray*)menuItems
{
    if (_menuItems == nil) {
        _menuItems = [[NSMutableArray alloc] init];
    }
    
    return _menuItems;
}

-(void)addItemWithTitle:(NSString*)title
{
    NSUInteger index = [[self menuItems] count];
    [self insertItemWithTitle:title atIndex:index];
}

-(void)insertItemWithTitle:(NSString*)title atIndex:(NSInteger)index
{
    CGFloat height = 30.0f;
    CGFloat width = 100.0f;
    if (self.delegate != nil) {
        height = [self.delegate popupItemHeight];
        width = [self.delegate popupItemWidth];
    }
    
    NSRect rect = NSMakeRect(0, 0, width, height);
    AMPopUpMenuItem* newItem = [[AMPopUpMenuItem alloc] initWithFrame:rect];
    newItem.title = title;
    newItem.delegate = self;
    
    NSUInteger maxIndex = [[self menuItems] count];
    if (maxIndex > index) {
        index = maxIndex;
    }
    
    [[self menuItems] insertObject:newItem atIndex:index];
    [self.view addSubview:newItem];
    
    NSRect menuRect = self.view.frame;
    menuRect.size.height = (index + 1) * height;
    menuRect.size.width = width;
    [self.view setFrame:menuRect];
    
    NSUInteger i = 0;
    for (AMPopUpMenuItem* item in [self menuItems]){
        NSRect itemRect = NSMakeRect(0, height*i, width, height);
        [item setFrame:itemRect];
        i++;
    }
}

-(void)removeAllItems
{
    for (AMPopUpMenuItem* item in [self menuItems]) {
        [item removeFromSuperview];
    }
    
    [[self menuItems] removeAllObjects];
}

-(void)addItemsWithTitles:(NSArray*)titles
{
    for (NSString* t in titles) {
        [self addItemWithTitle:t];
    }
}

-(void)itemSelected:(AMPopUpMenuItem *)sender
{
    [self.delegate itemSelected:sender.title];
}

-(void)selectItemAtInedex:(NSUInteger)index
{
    AMPopUpMenuItem* item = [[self menuItems] objectAtIndex:index];
    if (item != nil) {
        [item performSelector:@selector(mouseDown:) withObject:nil];
    }
}

-(NSUInteger)itemCount
{
    return [[self menuItems] count];
}

@end

//
//  AMUserGroupViewController.h
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AMUserGroupOutlineNode;
@protocol UserGroupChangeHandler;


@interface AMUserGroupViewController : NSViewController<UserGroupChangeHandler>

@property (weak) IBOutlet NSOutlineView *userGroupOutline;

@property (strong) IBOutlet NSTreeController *treeViewController;


@property NSMutableArray* groups;
//KVO things
-(NSUInteger)countOfGroups;
-(AMUserGroupOutlineNode*)objectInGroupsAtIndex:(NSUInteger)index;
-(void)addGroupsObject:(AMUserGroupOutlineNode *)object;
-(void)insertObject:(AMUserGroupOutlineNode *)object inGroupsAtIndex:(NSUInteger)index;
-(void)replaceObjectInGroupsAtIndex:(NSUInteger)index withObject:(id)object;
-(void)removeObjectFromGroupsAtIndex:(NSUInteger)index;
-(void)removeGroupsObject:(AMUserGroupOutlineNode *)object;

@end

//
//  AMUserGroupOutlineNode.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUserGroupOutlineNode : NSObject

@property NSString* name;
@property NSMutableArray* children;
@property BOOL isLeaf;
@property AMUserGroupOutlineNode* parent;

-(id)initWithName:(NSString*)name isGroup:(BOOL)bGroup;


//for Cocoa bandings by outlineView must compliant with KVC
-(NSInteger)countOfChildren;

-(AMUserGroupOutlineNode*)objectInChildrenAtIndex:(NSUInteger)index;

-(void)addChildrenObject:(AMUserGroupOutlineNode *)object;

-(void)insertObject:(AMUserGroupOutlineNode *)object inChildrenAtIndex:(NSUInteger)index;

-(void)removeObjectFromChildrenAtIndex:(NSUInteger)index;

-(void)removeChildrenObject:(AMUserGroupOutlineNode*)object;

-(void)replaceObjectInChildrenAtIndex:(NSUInteger)index withObject:(id)object;

@end

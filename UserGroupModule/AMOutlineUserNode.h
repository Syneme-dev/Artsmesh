//
//  AMUser.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMOutlineUserNode : NSObject

@property NSString* name;
@property NSMutableArray* children;
@property BOOL isLeaf;
@property AMOutlineUserNode* parent;

-(id)initWithName:(NSString*)name isGroup:(BOOL)bGroup;


//for Cocoa bandings by outlineView must compliant with KVC
-(NSInteger)countOfChildren;

-(AMOutlineUserNode*)objectInChildrenAtIndex:(NSUInteger)index;

-(void)addChildrenObject:(AMOutlineUserNode *)object;

-(void)insertObject:(AMOutlineUserNode *)object inChildrenAtIndex:(NSUInteger)index;

-(void)removeObjectFromChildrenAtIndex:(NSUInteger)index;

-(void)removeChildrenObject:(AMOutlineUserNode*)object;

-(void)replaceObjectInChildrenAtIndex:(NSUInteger)index withObject:(id)object;

@end

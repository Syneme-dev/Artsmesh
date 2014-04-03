//
//  AMUserGroupNode.h
//  AMMesher
//
//  Created by Wei Wang on 4/2/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUserGroupNode : NSObject

@property NSString* name;
@property NSMutableArray* children;
@property BOOL isLeaf;
@property AMUserGroupNode* parent;

-(id)initWithName:(NSString*)name isGroup:(BOOL)bGroup;

//for Cocoa bandings by outlineView must compliant with KVC
-(NSInteger)countOfChildren;
-(AMUserGroupNode*)objectInChildrenAtIndex:(NSUInteger)index;
-(void)addChildrenObject:(AMUserGroupNode *)object;
-(void)insertObject:(AMUserGroupNode *)object inChildrenAtIndex:(NSUInteger)index;
-(void)removeObjectFromChildrenAtIndex:(NSUInteger)index;
-(void)removeChildrenObject:(AMUserGroupNode*)object;
-(void)replaceObjectInChildrenAtIndex:(NSUInteger)index withObject:(id)object;

@end

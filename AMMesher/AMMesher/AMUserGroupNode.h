//
//  AMUserGroupNode.h
//  AMMesher
//
//  Created by Wei Wang on 4/2/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUserGroupNode : NSObject

@property NSString* nodeName;
@property NSMutableArray* children;
@property AMUserGroupNode* parent;
@property BOOL isLeaf;

+(BOOL)compareField:(AMUserGroupNode*)node1
          withGroup:(AMUserGroupNode*)node2
      withFiledName:(NSString*)fieldname
    differentFields:(NSMutableDictionary*)fields;

//for Cocoa bandings by outlineView must compliant with KVC
-(NSInteger)countOfChildren;
-(AMUserGroupNode*)objectInChildrenAtIndex:(NSUInteger)index;
-(void)addChildrenObject:(AMUserGroupNode *)object;
-(void)insertObject:(AMUserGroupNode *)object inChildrenAtIndex:(NSUInteger)index;
-(void)removeObjectFromChildrenAtIndex:(NSUInteger)index;
-(void)removeChildrenObject:(AMUserGroupNode*)object;
-(void)replaceObjectInChildrenAtIndex:(NSUInteger)index withObject:(id)object;

@end

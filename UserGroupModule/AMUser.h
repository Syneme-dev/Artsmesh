//
//  AMUser.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUser : NSObject

@property NSString* name;
@property NSMutableArray* children;
@property BOOL isLeaf;
@property AMUser* parent;

-(id)initWithName:(NSString*)name isGroup:(BOOL)bGroup;


//for Cocoa bandings by outlineView must compliant with KVC
-(NSInteger)countOfChildren;

-(AMUser*)objectInChildrenAtIndex:(NSUInteger)index;

-(void)addChildrenObject:(AMUser *)object;

-(void)insertObject:(AMUser *)object inChildrenAtIndex:(NSUInteger)index;

-(void)removeObjectFromChildrenAtIndex:(NSUInteger)index;

-(void)removeChildrenObject:(AMUser*)object;

-(void)replaceObjectInChildrenAtIndex:(NSUInteger)index withObject:(id)object;

@end

//
//  AMUserGroupNode.m
//  AMMesher
//
//  Created by Wei Wang on 4/2/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUserGroupNode.h"

@implementation AMUserGroupNode

-(id)initWithName:(NSString*)name isGroup:(BOOL)bGroup
{
    if(self = [super init])
    {
        self.name = name;
        self.parent = nil;
        if(bGroup)
        {
            self.children = [[NSMutableArray alloc] init];
            self.isLeaf = NO;
        }
        else
        {
            self.isLeaf = YES;
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark KVO
-(NSInteger)countOfChildren
{
    return (self.children == nil)? -1 : [self.children count];
}

-(AMUserGroupNode*)objectInChildrenAtIndex:(NSUInteger)index
{
    if(self.children == nil)
    {
        return nil;
    }
    
    return [self.children objectAtIndex:index];
}

-(void)insertObject:(AMUserGroupNode *)object inChildrenAtIndex:(NSUInteger)index
{
    if (self.children != nil) {
        [self willChangeValueForKey:@"children"];
        [self.children insertObject:object atIndex:index ];
        [self didChangeValueForKey:@"children"];
    }
}

-(void)removeObjectFromChildrenAtIndex:(NSUInteger)index
{
    if(self.children != nil)
    {
        [self willChangeValueForKey:@"children"];
        [self.children removeObjectAtIndex:index];
        [self didChangeValueForKey:@"children"];
    }
    
}

-(void)replaceObjectInChildrenAtIndex:(NSUInteger)index withObject:(id)object
{
    if(self.children != nil)
    {
        [self willChangeValueForKey:@"children"];
        [self.children replaceObjectAtIndex:index withObject:object  ];
        [self didChangeValueForKey:@"children"];
    }
}

-(void)addChildrenObject:(AMUserGroupNode *)object
{
    if(self.children != nil)
    {
        [self willChangeValueForKey:@"children"];
        [self.children addObject:object  ];
        [self didChangeValueForKey:@"children"];
    }
}

-(void)removeChildrenObject:(AMUserGroupNode*)object
{
    if(self.children != nil)
    {
        [self willChangeValueForKey:@"children"];
        [self.children removeObject:object  ];
        [self didChangeValueForKey:@"children"];
    }
}

@end

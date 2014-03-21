//
//  AMUser.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMOutlineUserNode.h"

@implementation AMOutlineUserNode

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


-(NSInteger)countOfChildren
{
    return (self.children == nil)? -1 : [self.children count];
}

-(AMOutlineUserNode*)objectInChildrenAtIndex:(NSUInteger)index
{
    if(self.children == nil)
    {
        return nil;
    }
    
    return [self.children objectAtIndex:index];
}

-(void)insertObject:(AMOutlineUserNode *)object inChildrenAtIndex:(NSUInteger)index
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

-(void)addChildrenObject:(AMOutlineUserNode *)object
{
    if(self.children != nil)
    {
        [self willChangeValueForKey:@"children"];
        [self.children addObject:object  ];
        [self didChangeValueForKey:@"children"];
    }
}

-(void)removeChildrenObject:(AMOutlineUserNode*)object
{
    if(self.children != nil)
    {
        [self willChangeValueForKey:@"children"];
        [self.children removeObject:object  ];
        [self didChangeValueForKey:@"children"];
    }
}

//- (id)valueForUndefinedKey:(NSString *)key
//{
//    NSLog(@"%@\n", key);
//    return nil;
//}



@end

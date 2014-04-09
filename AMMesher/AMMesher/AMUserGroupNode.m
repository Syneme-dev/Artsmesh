//
//  AMUserGroupNode.m
//  AMMesher
//
//  Created by Wei Wang on 4/2/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUserGroupNode.h"

@implementation AMUserGroupNode

+(BOOL)compareField:(AMUserGroupNode*)node1
          withGroup:(AMUserGroupNode*)node2
      withFiledName:(NSString*)fieldname
    differentFields:(NSMutableDictionary*)fieldsAndNewVal
{
    NSString* fieldVal1 = [node1 valueForKey:fieldname];
    NSString* fieldVal2 = [node2 valueForKey:fieldname];
    
    if (fieldVal1 == nil && fieldVal2 == nil)
    {
        return YES;
    }
    
    if (fieldVal1 == nil && fieldVal2 != nil)
    {
        [fieldsAndNewVal setObject:fieldVal2 forKey:fieldname];
        return NO;
    }
    
    if (fieldVal1 != nil && fieldVal2 == nil)
    {
        [fieldsAndNewVal setObject:fieldVal2 forKey:fieldname];
        return NO;
    }
    
    if (![fieldVal1 isEqualToString:fieldVal2])
    {
        [fieldsAndNewVal setObject:fieldVal2 forKey:fieldname];
        return NO;
    }
    
    return YES;
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

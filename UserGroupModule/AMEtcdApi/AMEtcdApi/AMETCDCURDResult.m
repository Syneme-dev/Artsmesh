//
//  AMETCDCURDResult.m
//  HttpAndJson
//
//  Created by 王 为 on 2/28/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMETCDCURDResult.h"

@implementation AMETCDNode
@end

@implementation AMETCDCURDResult

-(id)initWithData: (NSData*)data
{
    if(self = [super init])
    {
        if(data == nil)
        {
            self.errorRes = YES;
            self.errDescription = @"data is nil";
            return self;
        }
        
        NSError *jsonParsingError = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&jsonParsingError];
        if(jsonParsingError != nil)
        {
            self.errorRes = YES;
            self.errDescription = @"JSON parse error";
            return self;
        }
        
        if(![objects isKindOfClass:[NSDictionary class]])
        {
            self.errorRes = YES;
            self.errDescription = @"JSON parse error";
            return self;
        }
        
        id action_obj = [objects valueForKey:@"action"];
        id node_obj = [objects valueForKey:@"node"];
        id prevnode_obj = [objects valueForKey:@"prevNode"];
        
        if(action_obj != nil && node_obj != nil)
        {
            if([action_obj isKindOfClass:[NSString class] ])
            {
                self.action = action_obj;
            }
            
            if([node_obj isKindOfClass:[NSDictionary class]])
            {
                self.node = [[AMETCDNode alloc] init];
                
                self.node.value = [node_obj valueForKey:@"value"];
                self.node.createdIndex = [[node_obj valueForKey:@"createdIndex"] intValue];
                self.node.modifiedIndex = [[node_obj valueForKey:@"modifiedIndex"] intValue];
                self.node.key = [node_obj valueForKey:@"key"];
            }
            
            if(prevnode_obj != nil && [prevnode_obj isKindOfClass:[NSDictionary class]])
            {
                self.prevNode = [[AMETCDNode alloc ] init];
                
                self.prevNode.key = [prevnode_obj valueForKey:@"key"];
                self.prevNode.value = [prevnode_obj valueForKey:@"value"];
                self.prevNode.createdIndex = [[prevnode_obj valueForKey:@"createdIndex"] intValue];
                self.prevNode.modifiedIndex = [[prevnode_obj valueForKey:@"modifiedIndex"] intValue];
            }
            
            
            self.errorRes = NO;
        }
        else
        {
            self.errorRes = YES;
            self.errDescription = @"the json parse result is not correct, maybe request failed!";
            return self;
        }
    }
    
    return self;
}


@end

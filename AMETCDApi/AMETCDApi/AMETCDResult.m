//
//  AMETCDCURDResult.m
//  HttpAndJson
//
//  Created by 王 为 on 2/28/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMETCDResult.h"

@implementation AMETCDNode
@end

@implementation AMETCDResult


//Normal Format:
//{
//    "action": "delete",
//    "node": {
//        "createdIndex": 30,
//        "dir": true,
//        "key": "/foo_dir",
//        "modifiedIndex": 31
//    },
//    "prevNode": {
//        "createdIndex": 30,
//        "key": "/foo_dir",
//        "dir": true,
//        "modifiedIndex": 30
//    }
//}

//Error Format:
//        {
//            "errorCode": 207,
//            "message": "Index or value is required",
//            "cause": "Renew",
//        }

//Dir Format
//{
//    "action": "get",
//    "node": {
//        "dir": true,
//        "key": "/",
//        "nodes": [
//                  {
//                      "createdIndex": 2,
//                      "dir": true,
//                      "key": "/foo_dir",
//                      "modifiedIndex": 2,
//                      "nodes": [
//                                {
//                                    "createdIndex": 2,
//                                    "key": "/foo_dir/foo",
//                                    "modifiedIndex": 2,
//                                    "value": "bar"
//                                }
//                                ]
//                  }
//                  ]
//    }
//}
-(AMETCDNode*) recursivelyParseNode:(id)nodeObj
{
    AMETCDNode* node = [[AMETCDNode alloc]init];
    node.key = [nodeObj valueForKey:@"key"];
    
    id isDir = [nodeObj valueForKey:@"dir"];
    if ( isDir == nil)
    {
        //a node
        node.value = [nodeObj valueForKey:@"value"];
        node.createdIndex = [[nodeObj valueForKey:@"createdIndex"] intValue];
        node.modifiedIndex = [[nodeObj valueForKey:@"modifiedIndex"] intValue];
        node.ttl = [[nodeObj valueForKey:@"ttl"]intValue];
        node.expiration = [nodeObj valueForKey:@"expiration"];
    }
    else
    {
        //a dir
        node.isDir = YES;
        
        NSMutableArray* nodes = [[NSMutableArray alloc] init];
        
        id nodesObj = [nodeObj valueForKey:@"nodes"];
        if ([nodesObj isKindOfClass:[NSArray class]])
        {
            for(id obj in nodesObj)
            {
                AMETCDNode* node = [self recursivelyParseNode:obj];
                [nodes addObject:node];
            }
            
            node.nodes = nodes;
        }
        
        node.createdIndex = [[nodeObj valueForKey:@"createdIndex"] intValue];
        node.modifiedIndex = [[nodeObj valueForKey:@"modifiedIndex"] intValue];
    }
    
    return node;
}

-(id)initWithData: (NSData*)data
{
    if(self = [super init])
    {
        self.errCode = 0;
        
        if(data == nil)
        {
            self.errCode = -1;
            self.errMessage= @"the given data is nil";
            self.cause = @"need JSON data";
            return self;
        }
        
        NSError *jsonParsingError = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&jsonParsingError];
        if(jsonParsingError != nil)
        {
            self.errCode = -1;
            self.errMessage = @"data incorrect";
            self.cause = @"JSON parse error";
            return self;
        }
        
        if(![objects isKindOfClass:[NSDictionary class]])
        {
            self.errCode = -1;
            self.errMessage = @"data incorrect";
            self.cause = @"JSON parse error";
            return self;
        }
        
        
        // first error procedure:
        id errCode = [objects valueForKey:@"errorCode"];
        if(errCode != nil)
        {
            id message = [objects valueForKey:@"message"];
            id cause = [objects valueForKey:@"cause"];
            
            self.errCode = [errCode intValue];
            self.errMessage = message;
            self.cause = cause;
            
            return self;
        }
        
        //results:
        id action = [objects valueForKey:@"action"];
        if(action != nil)
        {
            self.action = action;
            
            id node_obj = [objects valueForKey:@"node"];
            if(node_obj != nil)
            {
                self.node = [self recursivelyParseNode:node_obj];
            }
            
            id prevnode_obj = [objects valueForKey:@"prevNode"];
            if(prevnode_obj != nil)
            {
                self.prevNode = [self recursivelyParseNode:prevnode_obj];
            }
        }
    }
    
    return self;
}

@end




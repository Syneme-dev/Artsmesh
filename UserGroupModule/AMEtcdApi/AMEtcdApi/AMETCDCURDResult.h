//
//  AMETCDCURDResult.h
//  HttpAndJson
//
//  Created by 王 为 on 2/28/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Foundation/Foundation.h>


//{
//    "action": "set",
//    "node": {
//        "createdIndex": 7,
//        "key": "/foo",
//        "modifiedIndex": 7,
//        "value": "bar"
//    },
//    "prevNode": {
//        "createdIndex": 6,
//        "key": "/foo",
//        "modifiedIndex": 6,
//        "value": "bar"
//    }
//}

@interface AMETCDNode : NSObject

@property int createdIndex;
@property NSString* key;
@property int modifiedIndex;
@property NSString* value;

@end

@interface AMETCDCURDResult : NSObject

@property BOOL errorRes;
@property NSString* errDescription;
@property NSString* action;
@property AMETCDNode* node;
@property AMETCDNode* prevNode;

-(id)initWithData: (NSData*)data;

@end

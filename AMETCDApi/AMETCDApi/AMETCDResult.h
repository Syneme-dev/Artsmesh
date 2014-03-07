//
//  AMETCDCURDResult.h
//  HttpAndJson
//
//  Created by 王 为 on 2/28/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMETCDNode : NSObject

@property NSString* key;
@property NSString* value;
@property int createdIndex;
@property int modifiedIndex;
@property NSString* expiration;
@property int ttl;
@property BOOL isDir;
@property NSArray* nodes;

@end


@interface AMETCDResult : NSObject

@property NSString* action;
@property AMETCDNode* node;
@property AMETCDNode* prevNode;
@property int errCode;
@property NSString* errMessage;
@property NSString* cause;

-(id)initWithData: (NSData*)data;

@end

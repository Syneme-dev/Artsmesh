//
//  AMGroupPanelModel.m
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelModel.h"

@implementation AMGroupPanelModel

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

+(id)sharedGroupModel
{
    static AMGroupPanelModel* model = nil;
    @synchronized(self){
        if (model == nil){
            model = [[self alloc] initModel];
        }
    }
    return model;
}


-(id)initModel
{
    if (self = [super init]){
    }
    
    return self;
}

@end

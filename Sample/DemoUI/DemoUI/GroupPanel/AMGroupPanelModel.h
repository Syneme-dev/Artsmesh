//
//  AMGroupPanelModel.h
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMesher/AMAppObjects.h"

typedef enum {
    DetailPanelHide,
    DetailPanelUser,
    DetailPanelGroup
}DetailPanelState;

@interface AMGroupPanelModel : NSObject

@property AMGroup* selectedGroup;
@property AMUser* selectedUser;
@property DetailPanelState detailPanelState;

+(id)sharedGroupModel;

@end

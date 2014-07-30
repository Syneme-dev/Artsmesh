//
//  AMGroupPanelModel.h
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMCoreData/AMCoreData.h"

typedef enum {
    DetailPanelHide,
    DetailPanelUser,
    DetailPanelGroup,
    DetailPanelStaticGroup,
    DetailPanelStaticUser,
}DetailPanelState;

@interface AMGroupPanelModel : NSObject

@property AMLiveGroup* selectedGroup;
@property AMLiveUser* selectedUser;
@property DetailPanelState detailPanelState;
@property AMStaticGroup* selectedStaticGroup;
@property AMStaticUser* selectedStaticUser;

+(AMGroupPanelModel*)sharedGroupModel;

@end

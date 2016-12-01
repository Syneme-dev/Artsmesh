//
//  AMSyphonUtility.h
//  Artsmesh
//
//  Created by 翟英威 on 25/11/2016.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Syphon/Syphon.h>
@interface AMSyphonUtility : NSObject
//Get a array of all syphon devices' name
+(NSArray *) getSyphonDeviceList;

@end

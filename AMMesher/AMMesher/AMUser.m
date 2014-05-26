//
//  AMUser.m
//  AMMesher
//
//  Created by Wei Wang on 5/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUser.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AMUserPortMap

-(NSDictionary*)jsonDict{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.portName forKey:@"PortName"];
    [dict setObject:self.internalPort forKey:@"InternalPort"];
    [dict setObject:self.natMapPort forKey:@"NATMapPort"];
    
    return dict;
}

-(NSString*)contentStr{
    NSString* contentStr = [NSString stringWithFormat:@"%@%@%@",
                            self.portName,
                            self.internalPort,
                            self.natMapPort];
    return contentStr;
}

-(AMUserPortMap*)copy{
    AMUserPortMap* copyPortMap = [[AMUserPortMap alloc] init];
    copyPortMap.portName = self.portName;
    copyPortMap.internalPort = self.internalPort;
    copyPortMap.natMapPort = self.natMapPort;
    
    return copyPortMap;
}

@end

@implementation AMUser

-(id)init{
    
    if(self = [super init]){
        self.userid = [AMUser createUserId];
        self.groupName = @"Artsmesh";
        self.domain = @"";
        self.location = @"";
        self.groupName = @"";
        self.publicIp = @"";
        self.privateIp = @"";
        self.localLeader = @"";
        self.portMaps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(NSString*)jsonString{
   
    NSData* encodedData = [self jsonData];
    return [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
}

-(NSData*)jsonData{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.userid forKey:@"UserId"];
    [dict setObject:self.nickName forKey:@"NickName"];
    [dict setObject:self.domain forKey:@"Domain"];
    [dict setObject:self.location forKey:@"Location"];
    [dict setObject:self.groupName forKey:@"GroupName"];
    [dict setObject:self.publicIp forKey:@"PublicIp"];
    [dict setObject:self.privateIp forKey:@"PrivateIp"];
    [dict setObject:self.localLeader forKey:@"LocalLeader"];
    
    NSMutableArray* portMapsJsonStr = [[NSMutableArray alloc] init];
    for(AMUserPortMap* pm in self.portMaps) {
        NSDictionary* dict = [pm jsonDict];
        [portMapsJsonStr addObject:dict];
    }
    
    [dict setObject:portMapsJsonStr forKey:@"PortMaps"];
    return [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];

}

-(NSString*)md5String
{
    NSMutableString* portMapStr = [[NSMutableString alloc] init];
    
    for(AMUserPortMap* pm in self.portMaps ) {
        [portMapStr appendString:[pm contentStr]];
    }
    
    NSString* contentMd5Str = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",
                               self.userid,
                               self.nickName,
                               self.domain,
                               self.location,
                               self.groupName,
                               self.publicIp,
                               self.privateIp,
                               self.localLeader,
                               portMapStr];
    
    const char *cstr = [contentMd5Str UTF8String];
    unsigned char result[16];
    CC_MD5(cstr, strlen(cstr), result);
    
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString*) createUserId
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    
    // If needed, here is how to get a representation in bytes, returned as a structure
    // typedef struct {
    //   UInt8 byte0;
    //   UInt8 byte1;
    //   …
    //   UInt8 byte15;
    // } CFUUIDBytes;
    //CFUUIDBytes bytes = CFUUIDGetUUIDBytes(uuidObject);
    
    CFRelease(uuidObject);
    
    return uuidStr;
}

-(AMUser*)copy{

    AMUser* copyUser = [[AMUser alloc ] init];
    copyUser.userid = self.userid;
    copyUser.nickName = self.nickName;
    copyUser.domain = self.domain;
    copyUser.location = self.location;
    copyUser.groupName = self.groupName;
    copyUser.publicIp = self.publicIp ;
    copyUser.privateIp  = self.privateIp;
    copyUser.localLeader = self.localLeader;
    
    for(AMUserPortMap* pm in self.portMaps){
        [copyUser.portMaps addObject:[pm copy]];
    }
    
    return copyUser;
}

@end



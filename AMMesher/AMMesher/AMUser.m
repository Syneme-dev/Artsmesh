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

+(AMUserPortMap*)portMapFromJsonData:(id) object{
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AMUserPortMap* portMap = [[AMUserPortMap alloc] init];
    portMap.portName= [object valueForKey:@"PortName"];
    portMap.internalPort = [object  valueForKey:@"InternalPort"];
    portMap.natMapPort = [object valueForKey:@"NATMapPort"];

    return portMap;
}

@end

@implementation AMUser

-(id)init{
    
    if(self = [super init]){
        self.userid = [AMUser createUserId];
        self.groupName = @"";
        self.domain = @"";
        self.location = @"";
        self.groupName = @"";
        self.publicIp = @"";
        self.privateIp = @"";
        self.localLeader = @"";
        self.nickName = @"default";
        self.description = @"default";
        self.portMaps = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(NSDictionary*)jsonDict{
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
    
    return dict;
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

+(AMUser*)userFromJsonData:(id) object{
    
    if (![object isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AMUser* user = [[AMUser alloc] init];
    user.userid = [object valueForKey:@"UserId"];
    user.nickName = [object  valueForKey:@"NickName"];
    user.domain = [object valueForKey:@"Domain"];
    user.location = [object valueForKey:@"Location"];
    user.groupName  = [object valueForKey:@"GroupName"];
    user.publicIp = [object valueForKey:@"PublicIp"];
    user.privateIp = [object valueForKey:@"PrivateIp"];
    user.localLeader =  [object valueForKey:@"LocalLeader"];
    
    id portMaps = [object valueForKey:@"PortMaps"];
    if ([portMaps isKindOfClass:[NSArray class]]) {
        for(id portMapData in portMaps){
            AMUserPortMap* pm = [AMUserPortMap portMapFromJsonData:portMapData];
            if(pm != nil){
                [user.portMaps addObject:pm];
            }
        }
    }
    
    return user;
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

@implementation AMUserUDPRequest

-(NSString*)jsonString{
    
    NSData* encodedData = [self jsonData];
    return [[NSString alloc] initWithData:encodedData encoding:NSUTF8StringEncoding];
}

-(NSData*)jsonData{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.version forKey:@"Version"];
    [dict setObject:self.action forKey:@"Action"];
    [dict setObject:self.userid forKey:@"UserId"];
    
    if (self.userContent != nil) {
        [dict setObject:[self.userContent jsonDict]  forKey:@"UserContent"];
        [dict setObject:self.contentMd5 forKey:@"UserContentMd5"];
    }
   
    return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
}

@end

@implementation AMUserUDPResponse

+(AMUserUDPResponse*)responseFromJsonData:(NSData*) data{
    NSError *jsonParsingError = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&jsonParsingError];
    if(jsonParsingError != nil){
        return nil;
    }
    
    if (![objects isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AMUserUDPResponse* response = [[AMUserUDPResponse alloc] init];
    response.action = [objects valueForKey:@"Action"];
    response.version = [objects  valueForKey:@"Version"];
    response.contentMd5 = [objects valueForKey:@"UserContentMd5"];
    response.isSucceeded = [[objects valueForKey:@"IsSucceeded"] boolValue];
    
    return response;
}

@end

@implementation AMUserRESTResponse

-(id)init{
    if (self = [super init]) {
        self.version = 0;
        self.userlist = [[NSMutableArray alloc] init];
    }
    
    return self ;
}

+(AMUserRESTResponse*)responseFromJsonData:(NSData*) data{
    NSError *jsonParsingError = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&jsonParsingError];
    if(jsonParsingError != nil){
        return nil;
    }
    
    if (![objects isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    AMUserRESTResponse* response = [[AMUserRESTResponse alloc] init];
    response.version = [objects valueForKey:@"Version"];
    
    id userlistArr = [objects valueForKey:@"UserListData"];
    if ([userlistArr isKindOfClass:[NSArray class]]) {
        for(id userData in userlistArr){
            
            AMUser* user = [AMUser userFromJsonData:userData];
            if (user != nil) {
                [response.userlist addObject:user];
            }
        }
    }
    
    return response;
}

@end







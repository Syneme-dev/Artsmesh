//
//  AMStatusNet.m
//  AMStatusNet
//
//  Created by Wei Wang on 7/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStatusNet.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMNetworkUtils/AMNetworkUtils.h"

@interface AMStatusNet()

@property NSString* userName;
@property NSString* password;

@end

@implementation AMStatusNet
{
    NSOperationQueue* _httpRequestQueue;
    NSTask *_task;
    NSFileHandle *_pipeIn;
    NSString* _result;
}

+(AMStatusNet*)shareInstance
{
    static AMStatusNet* sharedStatusNet = nil;
    @synchronized(self){
        if (sharedStatusNet == nil){
            sharedStatusNet = [[self alloc] privateInit];
        }
    }
    return sharedStatusNet;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

-(AMStatusNet*)privateInit
{
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    self.homePage = [defaults stringForKey:Preference_Key_StatusNet_URL];
    self.userName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    self.password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    
    //init NSOperationQueue
    _httpRequestQueue = [[NSOperationQueue alloc] init];
    _httpRequestQueue.name = @"StatusNetRequstQueue";
    _httpRequestQueue.maxConcurrentOperationCount = 1;
    
    return self;
}

-(void)loadGroups
{
    //synchronize get all static user and groups
    //then post a notification;
    if (self.homePage == nil || [self.homePage isEqualToString:@""])
    {
        return;
    }
    
    if (self.userName == nil || [self.userName isEqualToString:@""])
    {
        return;
    }
    
    if (self.password == nil || [self.password isEqualToString:@""])
    {
        return;
    }
    
    AMHttpAsyncRequest* req = [[AMHttpAsyncRequest alloc] init];
    req.baseURL = self.homePage;
    req.requestPath = @"/api/statusnet/groups/list_all.json";
    req.httpMethod = @"GET";
    req.requestCallback = ^(NSData* response, NSError* error, BOOL isCancel){
        if (isCancel == YES) {
            return;
        }
        
        if (error != nil) {
            NSLog(@"error happened when register group:%@", error.description);
            return;
        }
        
        NSAssert(response, @"response should not be nil without error");
        NSLog(@"get statusnet user goups return........................");
        
        NSError *err = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:response options:0 error:&err];
        if(err != nil){
            NSString* errInfo = [NSString stringWithFormat:@"parse Json error:%@", err.description];
            NSAssert(NO, errInfo);
        }
        
        NSArray* result = (NSArray*)objects;
        NSMutableArray* staticGroups = [[NSMutableArray alloc] init];
        for(id object in result){
            if ([object isKindOfClass:[NSDictionary class]]) {
                AMStaticGroup* group = [AMStaticGroup staticGroupFromDict:object];
                [self getStaticUserByGroup:group];
                [staticGroups addObject:group];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [AMCoreData shareInstance].staticGroups = staticGroups;
            [[AMCoreData shareInstance] broadcastChanges:AM_STATIC_GROUP_CHANGED];
        });
    };
    
    [_httpRequestQueue addOperation:req];
    return;
}


-(void)getStaticUserByGroup:(AMStaticGroup*)group
{

    AMHttpSyncRequest* unregReq = [[AMHttpSyncRequest alloc] init];
    unregReq.baseURL = self.homePage;
    unregReq.requestPath = [NSString stringWithFormat:@"/api/statusnet/groups/membership/%@.json", group.nickname];
    unregReq.httpMethod = @"GET";
    NSData* response = [unregReq sendRequest];
    if (response != nil) {
        NSError *err = nil;
        id objects = [NSJSONSerialization JSONObjectWithData:response options:0 error:&err];
        if(err != nil){
            NSLog(@"parse Json error:%@", err.description);
            return;
        }
        
        if ([objects isKindOfClass:[NSArray class]]) {
            NSArray* result = (NSArray*)objects;
            NSMutableArray* users = [[NSMutableArray alloc] init];
            for (id userobj in result) {
                if ([userobj isKindOfClass:[NSDictionary class]]) {
                    AMStaticUser* newUser = [AMStaticUser staticUserFromDict:userobj];
                    [users addObject:newUser];
                }
            }
            
            group.users = users;
        }
    }
}


-(BOOL)quickRegisterAccount:(NSString*)account password:(NSString*)password
{
    return YES;
}

-(BOOL)registerAccount:(AMStaticUser*)user password:(NSString*)password
{
    return YES;
}

-(BOOL)loginAccount:(NSString*)account password:(NSString*)password
{
    return YES;
}

-(BOOL)followGroup:(NSString*)groupName
{
    return YES;
}

-(BOOL)createGroup:(NSString*)groupName
{
    return YES;
}

-(BOOL)postMessageToStatusNet:(NSString*)status
{
    if (self.homePage == nil || [self.homePage isEqualToString:@""])
    {
        return NO;
    }
    
    if (self.userName == nil || [self.userName isEqualToString:@""])
    {
        return NO;
    }
    
    if (self.password == nil || [self.password isEqualToString:@""])
    {
        return NO;
    }
    
    //curl -m 10 -u wangwei:wangwei1982 'http://syneme-asia.ccom.edu.cn/statusnet/index.php/api/statuses/update.xml'  -d status='xxxxcccc'  -D /dev/stdout -o /dev/null 2>/dev/null | head -1 | awk '{print $2}'
    
    NSString* commandStr = [NSString stringWithFormat:@"curl -m 10 -u %@:%@ \'%@/api/statuses/update.xml\'  -d status=\'%@\'  -D /dev/stdout -o /dev/null 2>/dev/null | head -1 | awk '{print $2}'", self.userName, self.password, self.homePage, status];
    
    return [self runTask:commandStr];
}

- (void)cancelTask
{
    if (_task) {
        @try {
            _pipeIn.readabilityHandler = nil;
            [_task interrupt];
        }
        @catch (NSException *exception) {
            // ignore
        }
        @finally {
            _task = nil;
            _pipeIn = nil;
        }
    }
}

-(BOOL)runTask:(NSString *)command
{
    [self cancelTask];
    
    _task = [[NSTask alloc] init];
    _task.launchPath = @"/bin/bash";
    _task.arguments = @[@"-c", command];
    
    NSPipe *pipe = [NSPipe pipe];
    _task.standardOutput = pipe;
    _task.standardError = pipe;
    [_task launch];
    
    _pipeIn = [pipe fileHandleForReading];
    NSData *data = [_pipeIn readDataToEndOfFile];
    NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if([result isEqualToString:@"200\n"])
    {
        return YES;
    }
    
    return NO;
}


@end

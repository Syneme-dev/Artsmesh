//
//  AMQueryGroupsOperation.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMQueryGroupsOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMUser.h"
#import "AMGroup.h"

@implementation AMQueryGroupsOperation
{
    AMETCD* _etcdApi;
}


-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if(self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        self.usergroups = [[NSMutableArray alloc]init];
        self.delegate = delegate;
        
        _isResultOK = NO;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Querying user group information...");
    
    int retry = 0;
    
    NSString* rootDir = @"/Groups/";
    
    for (retry =0; retry < 3; retry++)
    {
        if(self.isCancelled)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(QueryGroupsOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
        
        AMETCDResult* res = [_etcdApi listDir:rootDir recursive:YES];
        if(res != nil && res.errCode == 0)
        {
            [self parseQueryResult:res];
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(QueryGroupsOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(QueryGroupsOperationDidFinish:) withObject:self waitUntilDone:NO];
}


-(void)parseQueryResult:(AMETCDResult*)res
{
    for (AMETCDNode* groupNode in res.node.nodes)
    {
        NSArray* pathes = [groupNode.key componentsSeparatedByString:@"/"];
        if([pathes count] < 3)
        {
            continue;
        }
        
        AMGroup* newGroup = [[AMGroup alloc] init];
        newGroup.children = [[NSMutableArray alloc] init];
        newGroup.name = [pathes objectAtIndex:2];
        
        for (AMETCDNode* groupPropertyNode in groupNode.nodes)
        {
            NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
            if([pathes count] < 4)
            {
                continue;
            }
            
            NSString* groupProperty = [pathes objectAtIndex:3];
            if([groupProperty isEqualToString:@"Users"])
            {
                //set group users
                for(AMETCDNode* userNode in groupPropertyNode.nodes)
                {
                    NSArray* pathes = [userNode.key componentsSeparatedByString:@"/"];
                    if([pathes count] < 5)
                    {
                        continue;
                    }
                    
                    AMUser* newUser = [[AMUser alloc] init];
                    newUser.name = [pathes objectAtIndex:4];
                    newUser.groupName = newGroup.name;
                    
                    for (AMETCDNode* userPorpertyNode in userNode.nodes)
                    {
                        NSArray* pathes = [userPorpertyNode.key componentsSeparatedByString:@"/"];
                        if([pathes count] < 6)
                        {
                            continue;
                        }
                        
                        NSString* userProperty = [pathes objectAtIndex:5];
                        [newUser setValue:userPorpertyNode.value forKey:userProperty];
                    }
                    
                    newUser.parent = newGroup;
                    [newGroup.children addObject:newUser];
                }
            }
            else
            {
                //set group other properties
                [newGroup setValue:groupPropertyNode.value forKey:groupProperty];
            }
        }
        
        [self.usergroups addObject:newGroup];
    }
}


@end
